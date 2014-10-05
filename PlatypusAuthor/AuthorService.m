//
//  AuthorService.m
//  PlatypusNetwork
//
//  Created by Raphael on 26.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "AuthorService.h"
#import "ReceiveServer.h"
#import "ServerBrowser.h"
#import "Uploader.h"

#import "Network/Targets/Targets.h"
#import "Network/Targets/NetServiceTarget.h"
#import "Network/Targets/HostTarget.h"
#import "Network/Targets/ApplicationTarget.h"

#import "TargetsWindowController.h"
#import "Views/ManualServerWindow.h"

@interface AuthorService ()

// main Bonjour service.
// Used only to advertise the fact that there's a PlatypusAuthor app running
@property NSNetService *authorService;
@property ServerBrowser *serverBrowser;
@property NSMutableArray *uploaders;
@property NSString *computerNameString;

@property Targets *targets;
@property TargetsWindowController *targetsWindow;
@property ManualServerWindow *manualServerWindow;

@end

@implementation AuthorService

@synthesize delegate;
@synthesize canUpload;
@synthesize authorService, serverBrowser, uploaders;
@synthesize computerNameString;

@synthesize targets, targetsWindow;
@synthesize manualServerWindow;

- (NSString *)computerName {
    if (computerNameString == nil) {
        // get computer name (not localized) without extension ".local"
        NSString *cpuName;
        NSRange dotPos =[[[NSHost currentHost] name] rangeOfString:@"."];
        
        if (dotPos.location != NSNotFound) {
            cpuName = [[[NSHost currentHost] name] substringToIndex:dotPos.location];
        }
        else {
            cpuName = [[NSHost currentHost] name];
        }
        
        // get uuid prefix from userdefaults
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *uuidStr = [userDefaults stringForKey:@"prefixUUID"];
        
        if (uuidStr == nil) {
            // create new uuid prefix and save it to NSUserDefaults
            CFUUIDRef   uuid;
            
            uuid = CFUUIDCreate(NULL);
            assert(uuid != NULL);
            uuidStr = CFBridgingRelease( CFUUIDCreateString(NULL, uuid) );
            CFRelease(uuid);
            
            uuidStr = [uuidStr substringToIndex:8];
            
            [userDefaults setObject:uuidStr forKey:@"prefixUUID"];
            [userDefaults synchronize];
        }
        
        computerNameString = [NSString stringWithFormat:@"%@_%@", uuidStr, cpuName];
    }
    
    return computerNameString;
}

- (id)init {
    self = [super init];
    
    uploaders = [[NSMutableArray alloc] init];
    targets = [[Targets alloc] init];
    
    NSString *computerName = [self computerName];
    
    authorService = [[NSNetService alloc] initWithDomain:@"local." type:@"_PlatypusAuthor._tcp." name:computerName port:28473];
    authorService.delegate = self;
    [authorService publishWithOptions:NSNetServiceNoAutoRename];
    
    serverBrowser = [[ServerBrowser alloc] init];
    serverBrowser.delegate = self;
    NSString *type = [NSString stringWithFormat:@"_Platypus-%@._tcp.", computerName];
    NSLog(@"browsing for type : %@", type);
    [serverBrowser startBrowsingForServicesOfType:type InDomain:@"local."];
    
    self.canUpload = true;
    
    return self;
}

- (void)addUploadObserver:(id)observer {
    [self addObserver:observer forKeyPath:NSStringFromSelector(@selector(canUpload)) options:0 context:NULL];
}

- (void)removeUploadObserver:(id)observer {
    @try {
        [self removeObserver:observer forKeyPath:NSStringFromSelector(@selector(canUpload))];
    }
    @catch (NSException * __unused exception) {
    
    }
}

- (void)uploadProjectToTargets:(Project *)project {
    if (!canUpload) {
        NSLog(@"An upload is already in process");
        return;
    }
    // upload to netServices
    for (NetServiceTarget *target in [targets netServiceTargets]) {
        if (target.active) {
            Uploader *uploader = [[Uploader alloc] initWithProject:project ForDeviceService:target.netService WithDelegate:self];
            [uploader sendFileIndexOfProject];
            [uploaders addObject:uploader];
            self.canUpload = NO;
        }
    }
    // to hosts created manually
    for (HostTarget *target in [targets hostTargets]) {
        if (target.active) {
            // create an uploader with host and port
            Uploader *uploader = [[Uploader alloc] initWithProject:project ForHost:target.host AndPort:target.port WithDelegate:self];
            // it should start itself automatically when the server is done with setup
            //[uploader sendFileIndexOfProject];
            [uploaders addObject:uploader];
            self.canUpload = NO;
        }
    }
    // to browsers present on the system
    for (ApplicationTarget *target in [targets applicationTargets]) {
        if (target.active) {
            NSString *indexPath = [NSString stringWithFormat:@"%@%@", [project path], @"/index.html"];
            [[NSWorkspace sharedWorkspace] openFile:indexPath withApplication:target.name];
        }
    }
}

- (void)openTargetsWindow {
    if (targetsWindow == nil) {
        targetsWindow = [[TargetsWindowController alloc] initWithWindowNibName:@"TargetsWindow"];
        targetsWindow.delegate = self;
    }
    if (authorService != nil) {
        targetsWindow.targets = [targets getAllTargets];
    }
    [targetsWindow showWindow:self];
}

- (void)openManualServerWindow {
    if (manualServerWindow == nil) {
        manualServerWindow = [[ManualServerWindow alloc] initWithWindowNibName:@"ManualServerWindow"];
        manualServerWindow.delegate = self;
    }
    [manualServerWindow showWindow:self];
}

#pragma mark * NSNetServiceDelegate implementation

- (void)netService:(NSNetService *)sender
     didNotPublish:(NSDictionary *)errorDict {
    // it's better to know if there's a problem
    NSLog(@"Author Service registration failed");
}

#pragma mark * ServerBrowserDelegate implementation

- (void)updateServerList {
    NSLog(@"Server list updated!: %@", serverBrowser.servers);
    
    [targets updateNetServiceTargetsWithArray:serverBrowser.servers];
    
    if (targetsWindow != nil) {
        // make a big array with everything
        // TODO: create a nicer way to show the different targets and separate them by type
        targetsWindow.targets = [targets getAllTargets];
        NSLog(@"all targets: %@", targetsWindow.targets);
        // NSLog(@"targets updated: %@", targetsWindow.targets);
    }
    
    [delegate updateServerList];
}

#pragma mark * UploaderDelegate implementation

- (NSString *)getComputerName {
    return [self computerName];
}

- (void)uploadOfUploader:(Uploader *)uploader EndedWithStatus:(NSString *)status {
    NSLog(@"uploader ended its task with status: %@", status);
    
    if ([status isEqualToString:@"Timeout, no response from device."] || [status isEqualToString:@"Stream open error"]) {
        NSString *host = [uploader getTargetHost];
        if (host != nil) {
            // this host is not available anymore, erase it from targets.
            [targets removeHostFromTargets:host];
            if (targetsWindow != nil) {
                targetsWindow.targets = [targets getAllTargets];
            }
        }
    }
    
    [uploaders removeObject:uploader];
    NSLog(@"active uploaders: %@", uploaders);
    if ([uploaders count] == 0) {
        self.canUpload = YES;
    }
}

#pragma mark * TargetsWindowControllerDelegate implementation

- (void)switchClicked {
    [targets targetStateChanged];
}

- (void)dealloc {
    [serverBrowser stop];
}

#pragma mark * ManualServerWindowDelegate implementation

- (void)createConnectionForHost:(NSString *)host OnPort:(UInt16)port WithName:(NSString *)name {
    [targets addHostTargetWithName:name Address:host AndPort:port];
    if (targetsWindow != nil) {
        targetsWindow.targets = [targets getAllTargets];
        // NSLog(@"targets updated: %@", targetsWindow.targets);
    }
}

@end
