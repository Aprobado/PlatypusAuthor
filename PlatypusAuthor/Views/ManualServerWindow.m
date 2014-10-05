//
//  ManualServerWindow.m
//  PlatypusNetwork
//
//  Created by Raphael on 04.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "ManualServerWindow.h"
#import "../Network/ReceiveServer.h"
#import "../Network/NetworkUtilities.h"

NSUInteger const defaultPort = 40905;

@interface ManualServerWindow ()

@property ReceiveServer *server;
@property (weak) IBOutlet NSTextField *textField;

@end

@implementation ManualServerWindow

@synthesize server, textField;
@synthesize delegate;

- (instancetype)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    server = [[ReceiveServer alloc] init];
    server.delegate = self;
    
    [server startServerWithType:nil AndName:nil OnPort:defaultPort];
}

- (void)serverDidStartOnPort:(NSUInteger)port {
    NSString *ipAddress = [NetworkUtilities getIPAddress:YES];
    [textField setStringValue:[NSString stringWithFormat:@"Server %@\nis listening on port %lu", ipAddress, (unsigned long)port]];
}

- (void)receivedDataAtPath:(NSString*)path {
    
}

// we should only receive infos of an iPad requesting file sharing
// when we receive that, we create an Uploader that will automatically send its infos (port) back to the device
- (void)receivedData:(NSData*)data {
    NSRange range = NSMakeRange(0, sizeof(UInt16));
    // get first UInt16: port
    UInt16 port = 0;
    [data getBytes:&port range:range];
    
    // get next UInt32: size of NSString *host
    range = NSMakeRange(sizeof(UInt16), sizeof(UInt32));
    UInt32 sizeOfHost = 0;
    [data getBytes:&sizeOfHost range:range];
    
    NSRange hostRange = NSMakeRange(range.location+range.length, sizeOfHost);
    NSData *hostStringData = [data subdataWithRange:hostRange];
    
    NSRange nameRange = NSMakeRange(hostRange.location+hostRange.length, data.length-(hostRange.location+hostRange.length));
    NSData *nameStringData = [data subdataWithRange:nameRange];
    
    NSString *host = [[NSString alloc] initWithData:hostStringData encoding:NSUTF8StringEncoding];
    NSString *name = [[NSString alloc] initWithData:nameStringData encoding:NSUTF8StringEncoding];
    
    if (host != nil && port != 0) {
        NSLog(@"host %@:%@ is available on port %hu", name, host, port);
    }
    
    [delegate createConnectionForHost:host OnPort:port WithName:name];
}

@end
