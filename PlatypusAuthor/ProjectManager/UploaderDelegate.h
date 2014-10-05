//
//  UploaderDelegate.h
//  PlatypusNetwork
//
//  Created by Raphael on 28.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Uploader;

@protocol UploaderDelegate

- (NSString *)getComputerName;
- (void)uploadOfUploader:(Uploader *)uploader EndedWithStatus:(NSString *)status;

@end