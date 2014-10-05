//
//  Tag.m
//  PlatypusNetwork
//
//  Created by Raphael on 02.10.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "Tag.h"

@implementation Tag

- (NSString *)description
{
    return [NSString stringWithFormat:@"(tag name: %@, with type: %@ and attribute: %u)", _name, _type, _attribute];
}

@end
