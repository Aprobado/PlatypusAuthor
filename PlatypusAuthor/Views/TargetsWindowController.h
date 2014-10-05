//
//  TargetsWindowController.h
//  PlatypusNetwork
//
//  Created by Raphael on 25.08.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TargetsWindowControllerDelegate.h"

@interface TargetsWindowController : NSWindowController {
    id<TargetsWindowControllerDelegate> delegate;
}

@property NSArray *targets;
@property (weak) IBOutlet NSTableView *targetsTableView;
@property(nonatomic, retain) id<TargetsWindowControllerDelegate> delegate;

@end
