//
//  TextHighlighter.m
//  PlatypusNetwork
//
//  Created by Raphael on 03.10.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "TextHighlighter.h"
#import "AutomatParser.h"
#import "AutomatToken.h"

@implementation TextHighlighter

NSString *automatTagsExpression = @"(\#[^.# ]+\\{)|(\.[^.# ]+\\{)|\\}";

+ (void)highlightAutomatText:(NSTextView *)textView {
    NSArray *tokens = [AutomatParser getOccurencesOfRegularExpression:automatTagsExpression inString:[textView string]];
    
    for(AutomatToken *token in tokens) {
        [textView setTextColor:[NSColor orangeColor] range:token.range];
     }
}

+ (void)highlightAutomatText:(NSTextView *)textView InRange:(NSRange)range {
    NSArray *tokens = [AutomatParser getOccurencesOfRegularExpression:automatTagsExpression inString:[textView string] withRange:range];
    
    for(AutomatToken *token in tokens) {
        [textView setTextColor:[NSColor orangeColor] range:token.range];
    }
}

@end
