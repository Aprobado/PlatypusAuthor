//
//  NSPair.h
//  PlatypusNetwork
//
//  Created by Raphael on 02.10.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPair : NSObject

#pragma mark - properties
@property (nonatomic, retain) id a;
@property (nonatomic, retain) id b;

#pragma mark - methods
- (NSPair *)initWithA:(id) A B:(id) B;
- (NSString *)description;

@end
