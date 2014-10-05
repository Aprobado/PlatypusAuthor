//
//  Targets.h
//  PlatypusNetwork
//
//  Created by Raphael on 04.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Targets : NSObject

// GENERAL
- (void)targetStateChanged;

// SETTERS
- (void)updateNetServiceTargetsWithArray:(NSArray *)netServices;
- (void)addHostTargetWithName:(NSString *)name Address:(NSString *)address AndPort:(UInt16)port;
- (void)removeHostFromTargets:(NSString *)host;

// GETTERS
// includes netServices and hosts targets
- (NSArray *)getDevices;
- (NSArray *)getApplications;
- (NSArray *)getAllTargets;

@property NSMutableArray *netServiceTargets;
@property NSMutableArray *hostTargets;
@property NSMutableArray *applicationTargets;

@end
