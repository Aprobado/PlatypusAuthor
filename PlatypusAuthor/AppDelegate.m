//
//  AppDelegate.m
//  PlatypusNetwork
//
//  Created by Raphael on 19.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "AppDelegate.h"
#import "AuthorService.h"
#import "Views/TargetsWindowController.h"
#import "ProjectWindowController.h"
#import "FileBrowserController.h"
#import "TextViewController.h"
#import "PreviewWebViewController.h"
#import "Project.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property NSMutableArray *projectsWindow;
@property AuthorService *authorService;

@end

@implementation AppDelegate

@synthesize window, authorService, projectsWindow;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupTemplatesMenu];
    
    // Insert code here to initialize your application
    projectsWindow = [[NSMutableArray alloc] init];
    
    // create the authorService
    if (authorService == nil) {
        authorService = [[AuthorService alloc] init];
        authorService.delegate = self;
    }
    
    NSString *projectPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"projectPath"];
    /*
    // erase all the preferences
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    */
    if (projectPath != nil) {
        NSURL *projectUrl = [NSURL URLWithString:projectPath];
        [self openProjectAtPath:projectUrl];
    } else {
        // show an open window
        [self openProject:nil];
    }
}

- (IBAction)openTargetsWindow:(id)sender {
    [authorService openTargetsWindow];
}
- (IBAction)openManualServerWindow:(id)sender {
    [authorService openManualServerWindow];
}

- (void)setupTemplatesMenu {
    NSString *templatesPath = [[NSBundle mainBundle] pathForResource:@"Templates" ofType:@""];
    NSArray *templates = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:templatesPath error:nil];
    NSMenu *newFileMenu = [[[[[NSApp mainMenu] itemWithTitle:@"File"] submenu] itemWithTitle:@"New Project"] submenu];
    
    int index = 0;
    for (NSString *template in templates) {
        NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:template action:@selector(createNewProject:) keyEquivalent:@""];
        mi.representedObject = [templatesPath stringByAppendingPathComponent:template];
        
        [newFileMenu addItem:mi];
        
        if (index == 0) {
            mi.keyEquivalent = @"N";
            [newFileMenu addItem:[NSMenuItem separatorItem]];
        }
        index ++;
    }
}

- (BOOL)folderAtURLIsValidForNewProject:(NSURL *)url {
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
    if (isDirectory) {
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil] ;
        if ([files count] == 0) return YES;
    }
    return NO;
}

- (void)createNewProject:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    // representedObject is the full template path
    NSLog(@"create new project with project: %@", [item representedObject]);
    
    NSArray *paths = selectNewProjectFolder();
    if(paths)
    {
        NSURL *path = [paths objectAtIndex:0];
        NSString *pathString = [path path];
        if ([self folderAtURLIsValidForNewProject:path]) {
            NSLog(@"copy files from %@ to %@", [item representedObject], pathString);
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *files = [fileManager contentsOfDirectoryAtPath:[item representedObject] error:nil];
            
            for (NSString *file in files) {
                NSError *error;
                NSString *fileSource = [[item representedObject] stringByAppendingPathComponent:file];
                NSString *fileDestination = [pathString stringByAppendingPathComponent:file];
                if (![[NSFileManager defaultManager] copyItemAtPath:fileSource toPath:fileDestination error:&error]) {
                    NSLog(@"%@", error);
                }
            }
            
            [self openProjectAtPath:path];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:@"This Folder is not empty. Create and/or select a new folder to generate the project." defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
        }
    }
}

static NSArray *selectNewProjectFolder()
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setTitle:@"Choose project folder"];
    [panel setCanCreateDirectories:YES];
    [panel setFloatingPanel:YES];
    [panel defaultButtonCell].title = @"Create";
    
    NSInteger result = [panel runModal];
    if(result == NSOKButton)
    {
        return [panel URLs];
    }
    return nil;
}

- (ProjectWindowController *)isProjectAtPathAlreadyOpen:(NSURL *)path {
    for (ProjectWindowController *project in projectsWindow) {
        if ([[project getProjectPath] isEqualToString:[path path]]) {
            return project;
        }
    }
    return nil;
}

- (IBAction)openProject:(id)sender {
    // open the project folder
    NSArray * paths = selectProjectFolder();
    if(paths)
    {
        NSURL *path = [paths objectAtIndex:0];
        ProjectWindowController *projectAlreadyOpened = [self isProjectAtPathAlreadyOpen:path];
        if (projectAlreadyOpened != nil) {
            // make it key window
            [[projectAlreadyOpened window] makeKeyAndOrderFront:[projectAlreadyOpened window]];
        } else {
            [self openProjectAtPath:path];
        }
    }
}

- (void)openProjectAtPath:(NSURL *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[path path]]) {
        if ([self folderAtPathIsAValidProject:path]) {
            ProjectWindowController *projectWindow = [[ProjectWindowController alloc] initWithWindowNibName:@"ProjectWindow"];
            [projectWindow setupProjectAtPath:path];
            projectWindow.delegate = self;
            [[projectWindow window] makeKeyAndOrderFront:[projectWindow window]];
            
            [authorService addUploadObserver:projectWindow];
            
            [projectsWindow addObject:projectWindow];
            NSLog(@"Window added: %@", projectsWindow);
            
            // record the opened project in preferences
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *pathString = [path absoluteString];
            [userDefaults setValue:pathString forKey:@"projectPath"];
            [userDefaults synchronize];
            
        } else {
            // error, folder is not a valid project. Show an alert.
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"This folder is not a valid project";
            [alert addButtonWithTitle:@"Ok"];
            [alert runModal];
        }
    } else {
        [self openProject:nil];
    }
}

- (BOOL)stringIsPresent:(NSString *)str inArray:(NSArray *)array {
    for (NSString *element in array) {
        if ([str isEqualToString:element]) return YES;
    }
    return NO;
}

- (BOOL)folderAtPathIsAValidProject:(NSURL *)path {
    // no requirements are needed to be a valid project, for now
    /*
    // check book folder
    NSString *pathString = [path path];
    NSError *error = nil;
    NSArray *contentOfDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathString error:&error];
    if (![self stringIsPresent:@"HTML" inArray:contentOfDirectory]) {
        NSLog(@"HTML folder not present, this is not a project folder");
        return NO;
    }
    if (![self stringIsPresent:@"Automat" inArray:contentOfDirectory]) {
        NSLog(@"Automat folder not present, this is not a project folder");
        return NO;
    }
    
    // check HTML folder
    pathString = [pathString stringByAppendingPathComponent:@"HTML"];
    contentOfDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathString error:&error];
    if (![self stringIsPresent:@"index.html" inArray:contentOfDirectory]) {
        NSLog(@"no index.html file in HTML folder. This is not a project folder");
        return NO;
    }
    */
    return YES;
}

- (BOOL)KeyWindowIsAProjectWindow {
    // we must have a key window to create a file
    if ([NSApp keyWindow] == nil) return NO;
    // this window must be a project window
    if (![[[[NSApp keyWindow] windowController] className] isEqualToString:@"ProjectWindowController"]) return NO;
    
    return YES;
}

- (IBAction)createNewFile:(id)sender {
    if (![self KeyWindowIsAProjectWindow]) return;
    
    ProjectWindowController *controller = (ProjectWindowController *)[[NSApp keyWindow] windowController];
    
    NSMenuItem *item = (NSMenuItem *)sender;
    [[controller fileBrowserController] createNewFileOfType:[item title]];
}

- (IBAction)deleteFile:(id)sender {
    if (![self KeyWindowIsAProjectWindow]) return;
    
    ProjectWindowController *controller = (ProjectWindowController *)[[NSApp keyWindow] windowController];
    [[controller fileBrowserController] deleteSelectedFiles];
}

- (IBAction)saveCurrentFile:(id)sender {
    for (ProjectWindowController *projectWindow in projectsWindow) {
        if ([[projectWindow window] isKeyWindow]) {
            [projectWindow saveCurrentFile];
        }
    }
}

static NSArray *selectProjectFolder()
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setFloatingPanel:YES];
    NSInteger result = [panel runModal];
    if(result == NSOKButton)
    {
        return [panel URLs];
    }
    return nil;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark * AuthorServiceDelegate implementation

- (void)updateServerList {
    
}

#pragma mark * ProjectWindowDelegate implementation

- (void)closingWindow:(ProjectWindowController *)projectWindow {
    [authorService removeUploadObserver:projectWindow];
    [projectsWindow removeObject:projectWindow];
    NSLog(@"Window removed: %@", projectsWindow);
}

- (void)uploadToTargets:(Project *)project {
    assert(project != nil);
    [authorService uploadProjectToTargets:project];
}



@end
