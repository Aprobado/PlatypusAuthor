//
//  PreviewWebViewController.m
//  PlatypusNetwork
//
//  Created by Raphael on 29.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "PreviewWebViewController.h"

@interface PreviewWebViewController ()

@end

@implementation PreviewWebViewController

@synthesize webView, statusLabel;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(scrollDetected)
                                                     name:NSViewFrameDidChangeNotification
                                                   object:webView];
    }
    return self;
}

- (void)loadWithStringPath:(NSString *)path {
    statusLabel.stringValue = path;
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self loadRequest:req];
}

- (void)loadRequest:(NSURLRequest *)request {
    [[webView mainFrame] loadRequest:request];
}

- (void)reload {
    [webView reload:nil];
}

- (void)scrollDetected {
    [statusLabel setPreferredMaxLayoutWidth:[webView frame].size.width];
}

@end
