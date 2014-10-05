//
//  textViewController.m
//  PlatypusNetwork
//
//  Created by Raphael on 19.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "TextViewController.h"
#import "MyFileManager.h"
#import "TextHighlighter.h"

@interface TextViewController ()

@property BOOL textModified;

@end

@implementation TextViewController

@synthesize textView;
@synthesize currentFile, textModified;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        textView = [[NSTextView alloc] init];
    }
    return self;
}

- (void)setupSettings {
    [textView setAutomaticQuoteSubstitutionEnabled:NO];
}

- (void)textDidChange:(NSNotification *)aNotification {
    // set textModified to true only if we're editing an existing file.
    if (currentFile != NULL) {
        textModified = YES;
        
        // get the modified range
        NSInteger rangeBegining = [[[textView selectedRanges] objectAtIndex:0] rangeValue].location-20;
        if (rangeBegining < 0) rangeBegining = 0;
        NSInteger rangeEnding = rangeBegining+40;
        if (rangeEnding > [[textView string] length]-1) rangeEnding = [[textView string] length]-1;
        
        while (rangeBegining > 0 &&
               ![[[textView string] substringWithRange:NSMakeRange(rangeBegining, 1)] isEqualTo:@" "] &&
               ![[[textView string] substringWithRange:NSMakeRange(rangeBegining, 1)] isEqualTo:@"\n"]) {
            rangeBegining --;
        }
        while (rangeEnding-1 < [[textView string] length]-1 &&
               ![[[textView string] substringWithRange:NSMakeRange(rangeEnding, 1)] isEqualTo:@" "] &&
               ![[[textView string] substringWithRange:NSMakeRange(rangeEnding, 1)] isEqualTo:@"\n"]) {
            rangeEnding ++;
        }
        
        // a range around the text modification to avoid scanning the whole file
        NSRange range = NSMakeRange(rangeBegining, rangeEnding - rangeBegining);
        
        // setting the text in black before highlighting the parts we want
        [textView setTextColor:[NSColor blackColor] range:range];
        
        // highlight automat language elements
        [TextHighlighter highlightAutomatText:textView InRange:range];
    }
}

- (void)loadProjectIndex:(Project *)project {
    //[self loadTextFromFile:[project automaticIndexPath]];
}

- (BOOL)loadTextFromFile:(NSString *)filePath {
    if (textModified) {
        if (![self fileChangeConfirmation]) {
            return NO;
        }
    }
    
    currentFile = [filePath copy];
    NSString *text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    // lock or unlock the textView
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    if (attributes != nil) {
        if ([[attributes objectForKey:NSFileImmutable] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            textView.textColor = [NSColor grayColor];
            [textView setEditable:NO];
        } else {
            textView.textColor = [NSColor blackColor];
            [textView setEditable:YES];
        }
    }
    textView.string = text;
    // set the font of the textView when editing the text
    [textView setFont:[NSFont fontWithName:@"Courier" size:12]];
    // set the font of the whole text that's already there
    [[textView textStorage] setFont:[NSFont fontWithName:@"Courier" size:12]];
    
    if ([[filePath pathExtension] isEqualTo:@"automat"]) {
        [TextHighlighter highlightAutomatText:textView];
    }
    
    textModified = NO;
    
    return YES;
}

- (BOOL)saveCurrentFile {
    if ([[textView string] writeToFile:currentFile atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        textModified = NO;
        return YES;
    } else {
        NSLog(@"couldn't save file... weird...");
        return NO;
    }
}

// returns yes if user confirms file change
- (BOOL)fileChangeConfirmation {
    NSAlert *alert = [NSAlert alertWithMessageText:@"File has been modified, do you want to save it?"
                                     defaultButton:@"Save"
                                   alternateButton:@"Don't save"
                                       otherButton:@"Cancel"
                         informativeTextWithFormat:@""];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setIcon:[NSImage imageNamed:NSImageNameApplicationIcon]];
    
    switch ([alert runModal]) {
        case NSAlertDefaultReturn:
            // button Save
            [self saveCurrentFile];
            return YES;
            break;
        case NSAlertAlternateReturn:
            // button Don't save
            return YES;
            break;
        case NSAlertOtherReturn:
            // button Cancel
            return NO;
            break;
            
        default:
            break;
    }
    
    return NO;
}

- (NSString*)getTextFromTextView {
    return [textView string];
}

@end
