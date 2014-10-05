//
//  TargetsWindowController.m
//  PlatypusNetwork
//
//  Created by Raphael on 25.08.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "TargetsWindowController.h"

@interface TargetsWindowController ()

@property NSMutableDictionary *treeData;

@end

@implementation TargetsWindowController

@synthesize targets;
@synthesize delegate;

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
        targets = [[NSMutableArray alloc] init];
        
        //[targets addObject:[NSDictionary dictionaryWithObject:@"first element" forKey:@"name"]];
        //[targets addObject:[NSDictionary dictionaryWithObject:@"second element" forKey:@"name"]];
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)switchClicked:(id)sender {
    [delegate switchClicked];
}

@end
