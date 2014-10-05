//
//  ManualServerWindow.h
//  PlatypusNetwork
//
//  Created by Raphael on 04.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "../Network/ReceiveServerDelegate.h"
#import "ManualServerWindowDelegate.h"

@interface ManualServerWindow : NSWindowController <ReceiveServerDelegate> {
    id<ManualServerWindowDelegate> delegate;
}

@property (nonatomic, retain) id<ManualServerWindowDelegate> delegate;

@end
