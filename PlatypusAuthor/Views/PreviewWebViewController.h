//
//  PreviewWebViewController.h
//  PlatypusNetwork
//
//  Created by Raphael on 29.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface PreviewWebViewController : NSViewController

- (void)loadWithStringPath:(NSString *)path;
- (void)loadRequest:(NSURLRequest *)request;
- (void)reload;

@property (strong) IBOutlet WebView *webView;
@property (weak) IBOutlet NSTextField *statusLabel;

@end
