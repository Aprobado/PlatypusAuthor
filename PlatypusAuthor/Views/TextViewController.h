//
//  textViewController.h
//  PlatypusNetwork
//
//  Created by Raphael on 19.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Project.h"

@interface TextViewController : NSViewController

- (void)setupSettings;
- (void)loadProjectIndex:(Project *)project;
- (BOOL)loadTextFromFile:(NSString *)filePath;
- (BOOL)saveCurrentFile;
- (NSString*)getTextFromTextView;

@property IBOutlet NSTextView *textView;
@property NSString *currentFile;

@end
