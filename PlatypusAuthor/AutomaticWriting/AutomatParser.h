//
//  AutomatParser.h
//  PlatypusAuthor
//
//  Created by Raphael on 27.04.14.
//  Copyright (c) 2014 HEAD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutomatParser : NSObject

+ (NSString *)automatToHtmlWithString:(NSString *)automatText;
+ (NSString *)automatFileToHtml:(NSString *)file;

+ (NSArray *)getOccurencesOfRegularExpression:(NSString *)expression inString:(NSString *)string;
+ (NSArray *)getOccurencesOfRegularExpression:(NSString *)expression inString:(NSString *)string withRange:(NSRange)range;

@end
