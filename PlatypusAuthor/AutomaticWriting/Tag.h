//
//  Tag.h
//  PlatypusNetwork
//
//  Created by Raphael on 02.10.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>

enum TagAttribute {
    ID,
    CLASS,
    NONE
};

@interface Tag : NSObject

@property NSString *automatTag;
@property NSString *name;
@property NSString *type;
@property enum TagAttribute attribute;

- (NSString *)description;

@end
