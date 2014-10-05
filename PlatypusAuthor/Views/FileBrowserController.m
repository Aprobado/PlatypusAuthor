//
//  FileBrowserController.m
//  PlatypusNetwork
//
//  Created by Raphael on 18.07.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "FileBrowserController.h"
#import "MyFileManager.h"
#import "FileSystemItem.h"
#import "MyScrollView.h"

@interface FileBrowserController ()

@property MyFileManager *myFileManager;
@property FileSystemItem *rootItem;

@end

@implementation FileBrowserController

@synthesize myFileManager, rootFolderPath, rootItem;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil AndRootFolder:(NSString *)rootFolder
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        rootFolderPath = rootFolder;
        
        // we're retaining the root element of the outline view here.
        rootItem = [[FileSystemItem alloc] initWithPath:rootFolderPath parent:nil];
        
        myFileManager = [[MyFileManager alloc] init];
        myFileManager.rootFolderPath = rootFolder;
        myFileManager.delegate = self;
    }
    return self;
}

- (void)awakeFromNib {
    [_outlineView setDataSource:self];
    MyScrollView *scrollView = (MyScrollView *)[[_outlineView superview] superview];
    [scrollView registerForDragAndDrop:self];
}


- (void)changeRootFolderPath:(NSString *)root {
    rootFolderPath = root;
    myFileManager.rootFolderPath = root;
    rootItem = [[FileSystemItem alloc] initWithPath:root parent:nil];
    NSLog(@"changing root foler to: %@", root);
}

- (NSString *)getHtmlFileOfAutomatFileAtPath:(NSString *)path {
    return [myFileManager getHtmlFileOfAutomatFileAtPath:path];
}
- (void)generateHtmlFromAutomatFileAtPath:(NSString *)path {
    [myFileManager generateHtmlFromAutomatFileAtPath:path];
}

#pragma mark * File Management with MyFileManager object

- (void)createNewFileOfType:(NSString *)type {
    [myFileManager createNewFileOfType:type];
}

- (void)deleteSelectedFiles {
    NSIndexSet *selectedItems = [_outlineView selectedRowIndexes];
    
    [selectedItems enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        FileSystemItem *selectedItem = [_outlineView itemAtRow:idx];
        if (selectedItem != nil) {
            if (![selectedItem isRoot]) {
                [myFileManager deleteFile:[selectedItem fullPath]];
            }
        }
    }];
    
    // play "drag to trash" sound
    NSSound *systemSound = [[NSSound alloc] initWithContentsOfFile:@"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/dock/drag to trash.aif" byReference:YES];
    if (systemSound) {
        [systemSound play];
    }
    
    [_outlineView reloadData];
}

#pragma mark * NSOutlineViewDataSource implementation

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    // getting number of children of item reloads the data
    [(FileSystemItem *)item reloadChildren];
    return (item == nil) ? 1 : [item numberOfChildren];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? YES : ([item numberOfChildren] != -1);
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return rootItem;
    }
    else {
        return [(FileSystemItem *)item childAtIndex:index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if (item == nil) return @"project root";
    
    if ([(FileSystemItem *)item isRoot]) {
        //return @"PROJET";
        return [[item relativePath] lastPathComponent];
    }
    return [item relativePath];
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    [myFileManager renameFile:[item fullPath] To:object];
    [_outlineView reloadData];
}

#pragma mark * MyScrollViewDelegate implementation

// handles drag and drop of files in view
- (void)onFilesDrop:(NSArray *)files {
    [myFileManager copyFilesFromArray:files];
}

#pragma mark * MyFileManagerDelegate implementation

- (void)onFilesAdded:(NSArray *)files {
    // select files in outlineView
    
    // reload the outlineView
    [_outlineView reloadData];
    // unselect everything
    [_outlineView deselectAll:nil];
    
    // select the newly created files
    for (NSString *filePath in files) {
        NSLog(@"searching for item with path:%@", filePath);
        FileSystemItem *itemToSelect = [rootItem getItemWithPath:filePath];
        NSLog(@"itemtoselect:%@", [itemToSelect fullPath]);
        
        if (itemToSelect != nil) {
            // open parent items
            FileSystemItem *item = itemToSelect;
            while (![item isRoot]) {
                item = [item getParent];
                [_outlineView expandItem:item];
            }
            NSInteger row = [_outlineView rowForItem:itemToSelect];
            
            // add item to selection
            [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:YES];
        }
    }
}

@end
