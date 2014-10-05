//
//  ServerBrowser.m
//  PlatypusNetwork
//
//  Created by Raphael on 27.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "ServerBrowser.h"

@interface ServerBrowser ()

@property NSNetServiceBrowser* browser;

@end

@implementation ServerBrowser

@synthesize delegate;
@synthesize browser, servers;

- (id)init {
    servers = [[NSMutableArray alloc] init];
    return self;
}

- (BOOL)startBrowsingForServicesOfType:(NSString *)type InDomain:(NSString *)domain {
    // Restarting?
    if ( browser != nil ) {
        [self stop];
    }
    
    browser = [[NSNetServiceBrowser alloc] init];
    if( !browser ) {
        return NO;
    }
    
    browser.delegate = self;
    [browser searchForServicesOfType:type inDomain:domain];
    
    return YES;
}

- (void)stop {
    if ( browser == nil ) {
        return;
    }
    
    [browser stop];
    browser = nil;
    
    [servers removeAllObjects];
}

#pragma mark * NSNetServiceBrowserDelegate Method Implementations

// New service was found
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    // Make sure that we don't have such service already (why would this happen? not sure)
    if ( ! [servers containsObject:netService] ) {
        // Add it to our list
        [servers addObject:netService];
    }
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    
    // Sort alphabetically and let our delegate know
    // [self sortServers]; // no sorting for now
    
    [delegate updateServerList];
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    // Remove from list
    [servers removeObject:netService];
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    
    // Sort alphabetically and let our delegate know
    // [self sortServers]; // no sorting for now
    
    [delegate updateServerList];
}

@end
