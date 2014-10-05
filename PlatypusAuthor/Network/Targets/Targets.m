//
//  Targets.m
//  PlatypusNetwork
//
//  Created by Raphael on 04.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "Targets.h"
#import "NetServiceTarget.h"
#import "HostTarget.h"
#import "ApplicationTarget.h"

#define SAFARI      @"Safari"
#define FIREFOX     @"Firefox"
#define CHROME      @"Google Chrome"
#define OPERA       @"Opera"

@interface Targets()

@property NSArray *allowedTargets;

@end


@implementation Targets

@synthesize netServiceTargets, hostTargets, applicationTargets;
@synthesize allowedTargets;

- (instancetype)init {
    self = [super init];
    
    netServiceTargets = [[NSMutableArray alloc] init];
    hostTargets = [[NSMutableArray alloc] init];
    applicationTargets = [[NSMutableArray alloc] init];
    
    // get allowed targets from the preferences
    allowedTargets = [[NSUserDefaults standardUserDefaults] arrayForKey:@"allowedTargets"];
    NSLog(@"allowed targets at initialization: %@", allowedTargets);
    
    [self getAvailableApplications];
    
    return self;
}

#pragma mark *** GENERAL METHODS ***

- (BOOL)isTargetAllowed:(NSString *)targetName {
    if (allowedTargets == nil) return NO;
    
    for (NSString *target in allowedTargets) {
        if ([targetName isEqualToString:target]) {
            // target found in allowed targets
            return YES;
        }
    }
    // target not found
    return NO;
}

- (void)targetStateChanged {
    // save the changes in the preferences
    NSMutableArray *allowedTargetsToSave = [[NSMutableArray alloc] init];
    NSArray *allTargets = @[netServiceTargets, hostTargets, applicationTargets];
    
    for (NSMutableArray *targets in allTargets) {
        for (Target *target in targets) {
            if (target.active){
                //NSString *deviceName = [target.name substringFromIndex:8];
                [allowedTargetsToSave addObject:target.name];
            }
        }
    }
    // record the allowed devices in preferences
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:allowedTargetsToSave forKey:@"allowedTargets"];
    [userDefaults synchronize];
}

#pragma mark *** SETTER METHODS ***

#pragma mark * Set NSNetService targets

- (void)updateNetServiceTargetsWithArray:(NSArray *)netServices {
    // refresh the allowed list
    allowedTargets = [[NSUserDefaults standardUserDefaults] arrayForKey:@"allowedTargets"];
    [netServiceTargets removeAllObjects];
    
    for (NSNetService *service in netServices) {
        // name without the 8 first UUID characters
        NSString *serviceName = [[service name] substringFromIndex:8];
        
        NetServiceTarget *target = [[NetServiceTarget alloc] init];
        target.name = serviceName;
        target.netService = service;
        
        if ([self isTargetAllowed:serviceName]) {
            // add the service activated
            target.active = YES;
        } else {
            // add the service deactivated
            target.active = NO;
        }
        [netServiceTargets addObject:target];
    }
}

#pragma mark * Set Host targets

- (BOOL)hostAlreadyExists:(NSString *)host {
    for (HostTarget *target in hostTargets) {
        if ([host isEqualToString:target.host]) return YES;
    }
    return NO;
}

- (void)updateHostTargetAtAddress:(NSString *)address WithName:(NSString *)name AndPort:(UInt16)port {
    for (HostTarget *target in hostTargets) {
        if ([address isEqualToString:target.host]) {
            target.name = name;
            target.port = port;
        }
    }
}

- (void)addHostTargetWithName:(NSString *)name Address:(NSString *)address AndPort:(UInt16)port {
    if ([self hostAlreadyExists:address]) {
        [self updateHostTargetAtAddress:address WithName:name AndPort:port];
    }
    else { // create a new one
        HostTarget *target = [[HostTarget alloc] init];
        target.name = name;
        target.active = YES;
        target.host = address;
        target.port = port;
        [hostTargets addObject:target];
    }
}

- (HostTarget *)getHostInHostTargets:(NSString *)host {
    for (HostTarget *target in hostTargets) {
        if ([host isEqualToString:target.host]) {
            return target;
        }
    }
    return nil;
}

- (void)removeHostFromTargets:(NSString *)host {
    HostTarget *removedHost = [self getHostInHostTargets:host];
    if (removedHost != nil) [hostTargets removeObject:removedHost];
}

#pragma mark * Set Application targets

- (void)getAvailableApplications {
    NSArray *appArray = @[ SAFARI, FIREFOX, CHROME, OPERA ];
    
    for (NSString *appName in appArray) {
        [self tryAddApplicationInTargets:appName];
    }
}
- (void)tryAddApplicationInTargets:(NSString *)appName {
    // add application if it is installed
    if ([[NSWorkspace sharedWorkspace] fullPathForApplication:appName] != nil) {
        ApplicationTarget *app = [[ApplicationTarget alloc] init];
        app.name = appName;
        app.active = [self isTargetAllowed:appName];
        app.applicationName = appName;
        [applicationTargets addObject:app];
    }
}

#pragma mark *** GETTER METHODS ***

- (NSArray *)getDevices {
    // adding the hostTargets to netServicesTargets permits to make them appear together
    // in the interface. Only one place for all devices.
    return [netServiceTargets arrayByAddingObjectsFromArray:hostTargets];
}

- (NSArray *)getApplications {
    return applicationTargets;
}

- (NSArray *)getAllTargets {
    NSArray *allTargets = [self getDevices];
    return [allTargets arrayByAddingObjectsFromArray:applicationTargets];
}

@end
