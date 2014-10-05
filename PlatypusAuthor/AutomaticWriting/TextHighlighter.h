//
//  TextHighlighter.h
//  PlatypusNetwork
//
//  Created by Raphael on 03.10.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface TextHighlighter : NSObject

+ (void)highlightAutomatText:(NSTextView *)textView;
+ (void)highlightAutomatText:(NSTextView *)textView InRange:(NSRange)range;

@end
