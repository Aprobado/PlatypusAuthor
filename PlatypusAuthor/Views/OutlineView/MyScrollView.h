//
//  MyScrollView.h
//  PlatypusNetwork
//
//  Created by Raphael on 29.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyScrollViewDelegate.h"

@interface MyScrollView : NSScrollView {
    id<MyScrollViewDelegate> delegate;
}

- (void)registerForDragAndDrop:(id)_delegate;

@property(nonatomic, retain) id<MyScrollViewDelegate> delegate;

@end
