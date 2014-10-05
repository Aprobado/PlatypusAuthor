//
//  MyFileManagerDelegate.h
//  PlatypusNetwork
//
//  Created by Raphael on 30.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyFileManagerDelegate

- (void)onFilesAdded:(NSArray *)files;

@end