//
//  ProjectWindowDelegate.h
//  PlatypusNetwork
//
//  Created by Raphael on 16.07.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectWindowController;
@class Project;

@protocol ProjectWindowDelegate

- (void)closingWindow:(ProjectWindowController *)projectWindow;
- (void)uploadToTargets:(Project *)project;

@end