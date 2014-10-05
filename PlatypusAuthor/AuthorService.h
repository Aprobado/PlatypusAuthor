//
//  AuthorService.h
//  PlatypusNetwork
//
//  Created by Raphael on 26.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthorServiceDelegate.h"
#import "ServerBrowserDelegate.h"
#import "UploaderDelegate.h"
#import "Views/TargetsWindowControllerDelegate.h"
#import "Project.h"
#import "ManualServerWindowDelegate.h"

@interface AuthorService : NSObject<NSNetServiceDelegate, ServerBrowserDelegate, UploaderDelegate, TargetsWindowControllerDelegate, ManualServerWindowDelegate> {
    id<AuthorServiceDelegate> delegate;
}

- (NSString *)computerName;
//- (NSMutableArray *)getListeningDevices;
- (void)uploadProjectToTargets:(Project *)project;
- (void)addUploadObserver:(id)observer;
- (void)removeUploadObserver:(id)observer;

- (void)openTargetsWindow;
- (void)openManualServerWindow;

@property BOOL canUpload;

@property(nonatomic, retain) id<AuthorServiceDelegate> delegate;

@end
