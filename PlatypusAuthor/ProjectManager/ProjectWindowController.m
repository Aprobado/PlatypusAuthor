//
//  ProjectWindowController.m
//  PlatypusNetwork
//
//  Created by Raphael on 16.07.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "ProjectWindowController.h"

#import "FileSystemItem.h"
#import "TextViewController.h"
#import "PreviewWebViewController.h"
#import "Project.h"
#import "MyFileManager.h"

@interface ProjectWindowController ()

@property (strong) NSSplitView *splitView;

@property TextViewController *textViewController;
@property PreviewWebViewController *webViewController;
@property (nonatomic)  Project *project;

@end

@implementation ProjectWindowController

@synthesize delegate;
@synthesize fileBrowserController, textViewController, webViewController, project, splitView;

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.window.delegate = self;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeKeyWindow) name:NSWindowDidBecomeKeyNotification object:nil];
}

- (NSString *)getProjectNameAtPath:(NSString *)projectPath {
    NSString *title = @"Projet sans nom";
    
    //NSString *indexPath = [projectPath stringByAppendingPathComponent:@"HTML"];
    // only if there's an index.html... could be in a page.html
    // I need to find a better solution
    NSString *htmlFile = [projectPath stringByAppendingPathComponent:@"page.html"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:htmlFile]) {
        htmlFile = [projectPath stringByAppendingPathComponent:@"index.html"];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:htmlFile]) {
        NSString *htmlContent = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        NSRange titleTag = [htmlContent rangeOfString:@"<title>"];
        if (titleTag.location == NSNotFound) return title;
        NSRange titleEndTag = [htmlContent rangeOfString:@"</title>"];
        if (titleEndTag.location == NSNotFound) return title;
        NSRange titleRange = NSMakeRange(NSMaxRange(titleTag), titleEndTag.location - NSMaxRange(titleTag));
        if (titleRange.length < 1) return title;
        title = [htmlContent substringWithRange:titleRange];
    }
    
    NSLog(@"title of book (at path %@): %@", projectPath, title);
    return title;
}

- (void)setupProjectAtPath:(NSURL *)URLpath {
    
    // set project
    
    project = [[Project alloc] init];
    NSString *stringURL = [URLpath path];
    //NSRange nameRange = [stringURL rangeOfString:@"/" options:NSBackwardsSearch];
    //NSString *projectName = [stringURL substringFromIndex:nameRange.location+1];
    NSString *projectName = [self getProjectNameAtPath:stringURL];
    project.name = projectName;
    [project setProjectPath:stringURL];
    
    // set split view
    
    splitView = [[NSSplitView alloc] initWithFrame:[[self.window contentView] bounds]];
    [splitView setDividerStyle:NSSplitViewDividerStyleThin];
    [splitView setVertical:YES];
    
    // set browser outlineView
    
    fileBrowserController = [[FileBrowserController alloc] initWithNibName:@"FileBrowser" bundle:nil AndRootFolder:[project path]];
    [splitView addSubview:[fileBrowserController view]];
    [fileBrowserController.outlineView expandItem:[fileBrowserController.outlineView itemAtRow:0]];
    [fileBrowserController.outlineView setDelegate:self];
    
    // set text view
    
    textViewController = [[TextViewController alloc] initWithNibName:@"TextView" bundle:nil];
    [splitView addSubview:[textViewController view]];
    [textViewController setupSettings];
    //[textViewController loadProjectIndex:project];
    
    // set web view
    
    webViewController = [[PreviewWebViewController alloc] initWithNibName:@"PreviewWebView" bundle:nil];
    [splitView addSubview:[webViewController view]];
    
    // assign splitView to the project window
    
    [splitView adjustSubviews];
    [self.window setContentView:splitView];
    [self.window setTitle:[NSString stringWithFormat:@"Project - %@", projectName]];
    
}

- (BOOL)loadContentAtPath:(NSString *)path {
    if ([textViewController loadTextFromFile:path]) {
        if ([[path pathExtension] isEqualToString:@"html"]) {
            [webViewController loadWithStringPath:path];
        } else if ([[path pathExtension] isEqualToString:@"automat"]) {
            NSString *htmlFilePath = [fileBrowserController getHtmlFileOfAutomatFileAtPath:path];
            [webViewController loadWithStringPath:htmlFilePath];
        }
        return YES;
    }
    return NO;
}

- (NSString *)getProjectPath {
    return [project path];
}

- (void)saveCurrentFile {
    [textViewController saveCurrentFile];
    if ([[[textViewController currentFile] pathExtension] isEqualTo:@"automat"]) {
        [fileBrowserController generateHtmlFromAutomatFileAtPath:[textViewController currentFile]];
    }
    [webViewController reload];
}

// we observe the upload state of the AuthorService object to enable/disable the upload button
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"canUpload"]) {
        [_uploadButton setEnabled:[object canUpload]];
    }
}

- (BOOL)executeTerminalCommand:(NSArray *)command From:(NSString *)directoryPath WithLaunchPath:(NSString *)launchPath {
    // NSLog(@"executing: %@", command);
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:launchPath];
    [task setArguments:command];
    [task setCurrentDirectoryPath:directoryPath];
    [task launch];
    
    [task waitUntilExit];
    
    return YES;
}

#pragma mark * Button Actions

- (IBAction)uploadToDevices:(id)sender {
    if (delegate == nil) return;
    [delegate uploadToTargets:project];
}

- (IBAction)gitCommit:(id)sender {
    NSString *launchPath = @"/usr/bin/git";
    
    // creating a new .git repo for current project
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[project path] stringByAppendingPathComponent:@".git"]]) {
        
        [self executeTerminalCommand:@[@"init"]
                                From:[project path]
                      WithLaunchPath:launchPath];
        
        [self executeTerminalCommand:@[@"add", @"."]
                                From:[project path]
                      WithLaunchPath:launchPath];
        
        [self executeTerminalCommand:@[@"commit", @"-m", @"First commit"]
                                From:[project path]
                      WithLaunchPath:launchPath];
    }
    
    // commit changes with user defined message
    else {
        // open alert with editable text field the commit message
        NSAlert *alert = [NSAlert alertWithMessageText:@"Commit message."
                                         defaultButton:@"Commit"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@""];
        
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
        [input setStringValue:@""];
        [alert setAccessoryView:input];
        
        NSString *message = @"";
        NSInteger button = [alert runModal];
        if (button == NSAlertDefaultReturn) {
            [input validateEditing];
            message = [input stringValue];
            
            [self executeTerminalCommand:@[@"add", @"-A"]
                                    From:[project path]
                          WithLaunchPath:launchPath];
            
            [self executeTerminalCommand:@[@"commit", @"-m", message]
                                    From:[project path]
                           WithLaunchPath:launchPath];
        }
    }
}

#pragma mark * NSWindowDelegate implementation

- (void)windowWillClose:(NSNotification *)notification {
    [delegate closingWindow:self];
}

#pragma mark * NSOutlineViewDelegate implemetation

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    // show the selected object in the views
    NSOutlineView *outlineView = (NSOutlineView *)notification.object;
    NSInteger selectedRow = [outlineView selectedRow];
    
    if (selectedRow == -1) return;
    
    id item = [outlineView itemAtRow:selectedRow];
    
    if ([outlineView isExpandable:item]) {
        if ([outlineView isItemExpanded:item]) {
            [outlineView collapseItem:item];
        } else {
            [outlineView expandItem:item];
            /*
            if ([item numberOfChildren] > 0) {
                NSInteger rowToSelect = [outlineView rowForItem:item]+1;
                [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowToSelect] byExtendingSelection:NO];
            }
            */
        }
        [outlineView deselectRow:[outlineView rowForItem:item]];
        //[outlineView deselectAll:nil];
        return;
    }
    
    NSString *fileName = [item relativePath];
    //NSString *fileName = [item relativePath];
    if ([[fileName pathExtension] isEqualToString:@"html"] || [[fileName pathExtension] isEqualToString:@"automat"] || [[fileName pathExtension] isEqualToString:@"css"] || [[fileName pathExtension] isEqualToString:@"js"]) {
        
        NSString *path = [item fullPath];
        
        [self loadContentAtPath:path];
    }
    
    if ([MyFileManager fileAtPathIsAnImage:[item fullPath]]) {
        [webViewController loadWithStringPath:[item fullPath]];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([item isRoot]) return NO;
    else return YES;
}

- (void)textDidEndEditing:(NSNotification *)aNotification {
    NSLog(@"%@", aNotification);
}


// This is temporary. shouldSelectItem is called twice when selecting another item in outlineview.
// The interface shouldn't be stopped by alerts popping everytime we change selection.
// We should add a "dirty" state for files, save temporary files and save everything when
// closing project, or saving manually (refresh) or uploading to devices.
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return YES;
}

#pragma mark * NSWindow Notifications

- (void)didBecomeKeyWindow {
    [[fileBrowserController outlineView] reloadData];
}

@end
