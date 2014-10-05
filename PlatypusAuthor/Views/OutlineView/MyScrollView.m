//
//  MyScrollView.m
//  PlatypusNetwork
//
//  Created by Raphael on 29.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "MyScrollView.h"

@implementation MyScrollView

@synthesize delegate;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)registerForDragAndDrop:(id)_delegate {
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType, NSFilenamesPboardType, nil]];
    delegate = _delegate;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        if (sourceDragMask & NSDragOperationGeneric) {
            return NSDragOperationGeneric;
        }
    }
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        if (sourceDragMask & NSDragOperationLink) {
            // we get links, but we're going to copy files
            // so we show a "copy icon"
            return NSDragOperationCopy; // "copy icon"
            //return NSDragOperationLink; // "alias/link icon"
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSLog(@"perform drag and drop operation");
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSColorPboardType] ) {
        NSLog(@"NSColorPboardType object dropped");
        // Only a copy operation allowed so just copy the data
        //NSColor *newColor = [NSColor colorFromPasteboard:pboard];
        //[self setColor:newColor];
    } else if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        NSLog(@"NSFilenamesPboardType object(s) dropped: %@", files);
        
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
        if (sourceDragMask & NSDragOperationLink) {
            [delegate onFilesDrop:files];
            //[self addLinkToFiles:files];
        } else {
            //[self addDataFromFiles:files];
        }
        
    }
    return YES;
}

@end
