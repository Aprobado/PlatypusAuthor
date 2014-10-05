//
//  FileBrowserController.h
//  PlatypusNetwork
//
//  Created by Raphael on 18.07.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OutlineView/MyScrollViewDelegate.h"
#import "MyFileManagerDelegate.h"

@interface FileBrowserController : NSViewController <NSOutlineViewDataSource, MyScrollViewDelegate, MyFileManagerDelegate>

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil AndRootFolder:(NSString *)rootFolder;

- (void)changeRootFolderPath:(NSString *)root;
- (NSString *)getHtmlFileOfAutomatFileAtPath:(NSString *)path;
- (void)generateHtmlFromAutomatFileAtPath:(NSString *)path;

- (void)createNewFileOfType:(NSString *)type;
- (void)deleteSelectedFiles;

@property (weak) IBOutlet NSOutlineView *outlineView;
@property NSString *rootFolderPath;

@end
