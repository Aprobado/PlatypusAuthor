//
//  NSPair.m
//  PlatypusNetwork
//
//  Created by Raphael on 02.10.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "NSPair.h"

@implementation NSPair

#pragma mark - synthesizes
@synthesize a, b;

#pragma mark - methods

- (NSPair *)initWithA:(id) A B:(id) B
{
    self = [super init];
    
    if (self) {
        a = A;
        b = B;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(a: %@, b:%@)",a,b];
}

@end
