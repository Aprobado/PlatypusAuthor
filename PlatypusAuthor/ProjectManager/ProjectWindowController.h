//
//  ProjectWindowController.h
//  PlatypusNetwork
//
//  Created by Raphael on 16.07.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectWindowDelegate.h"
#import "AuthorService.h"
#import "FileBrowserController.h"

@interface ProjectWindowController : NSWindowController <NSWindowDelegate, NSOutlineViewDelegate, NSTableViewDelegate> {
    id<ProjectWindowDelegate> delegate;
}

- (void)setupProjectAtPath:(NSURL *)path;
- (void)saveCurrentFile;

- (NSString *)getProjectPath;

@property id<ProjectWindowDelegate> delegate;
@property FileBrowserController *fileBrowserController;
@property (weak) IBOutlet NSToolbarItem *uploadButton;

@end
