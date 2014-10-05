//
//  ManualServerWindowDelegate.h
//  PlatypusNetwork
//
//  Created by Raphael on 04.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ManualServerWindowDelegate

- (void)createConnectionForHost:(NSString *)host OnPort:(UInt16)port WithName:(NSString *)name;

@end