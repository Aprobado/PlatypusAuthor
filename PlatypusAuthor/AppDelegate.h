//
//  AppDelegate.h
//  PlatypusNetwork
//
//  Created by Raphael on 19.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectWindowDelegate.h"
#import "AuthorServiceDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, ProjectWindowDelegate, AuthorServiceDelegate>

@end

