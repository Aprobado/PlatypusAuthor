//
//  AutomatToken.m
//  PlatypusNetwork
//
//  Created by Raphael on 02.10.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "AutomatToken.h"

@implementation AutomatToken

- (NSString *)description {
    return [NSString stringWithFormat: @"Token string: %@, with range: {%lu, %lu}", _string, (unsigned long)_range.location, (unsigned long)_range.length];
}

@end
