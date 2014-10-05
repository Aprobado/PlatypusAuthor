//
//  FileSender.m
//  PlatypusNetwork
//
//  Created by Raphael on 24.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "Uploader.h"
#import "ReceiveServer.h"
#import "Sender.h"
#import "SenderDelegate.h"
#import "Project.h"
#import "NetworkUtilities.h"

#import "AuthorService.h"

@interface Uploader ()

@property ReceiveServer *receiveServer;
@property Sender *sender;
@property NSString *destinationName;

@property NSMutableArray *queue;
@property (weak) Project *project;
@property BOOL endingMessageSent;

@property NSTimer *timer; // timeout if the device does not respond

@end

@implementation Uploader

@synthesize delegate;
@synthesize receiveServer, sender, destinationName, queue, project, endingMessageSent;
@synthesize timer;

- (instancetype)initWithProject:(Project *)_project ForDeviceService:(NSNetService *)service WithDelegate:(id)_delegate {
    delegate = _delegate;
    return [self initWithProject:_project ForDeviceService:service];
}

- (instancetype)initWithProject:(Project *)_project ForDeviceService:(NSNetService *)service {
    endingMessageSent = NO;
    destinationName = [service name];
    
    project = _project;
    
    receiveServer = [[ReceiveServer alloc] init];
    receiveServer.delegate = self;
    
    NSString *name = [NSString stringWithFormat:@"%@%@", [delegate getComputerName], [service name]];
    NSLog(@"[%@] Server started with type: %@ and name: %@", destinationName, @"_PlatypusAuthorTransfer._tcp.", name);
    [receiveServer startServerWithType:@"_PlatypusAuthorTransfer._tcp." AndName:name];
    
    NSLog(@"[%@] Sending to service of type: %@ and name: %@", destinationName, [service type], [service name]);
    sender = [[Sender alloc] initWithNetService:service];
    sender.delegate = self;
    
    return self;
}

- (instancetype)initWithProject:(Project *)_project ForHost:(NSString *)_host AndPort:(UInt16)_port WithDelegate:(id)_delegate {
    endingMessageSent = NO;
    destinationName = _host;
    
    delegate = _delegate;
    
    project = _project;
    
    sender = [[Sender alloc] initWithHost:_host AndPort:_port];
    sender.delegate = self;
    
    receiveServer = [[ReceiveServer alloc] init];
    receiveServer.delegate = self;
    [receiveServer startServerWithType:nil AndName:nil];
    
    return self;
}

-(void)stop {
    NSLog(@"[%@] Uploader will stop server", destinationName);
    [self stopTimer];
    [receiveServer stopServer:@"uploader stopped"];
}

- (void)startTimer {
    if (timer != nil) {
        [self stopTimer];
    }
    
    timer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}
- (void)stopTimer {
    if (timer != nil) {
        //NSLog(@"timer stopped identity: %@", timer);
        [timer invalidate];
        timer = nil;
    }
}

#pragma mark * Sending methods

// STARTING POINT OF AN UPLOADER WITH HOST
// send informations to the host so that it can answer to the correct port
- (void)sendHostInfo:(UInt16)port {
    assert(project != nil); // project must not be nil
    
    // add the header
    // ID 0 means we're sending the file index
    UInt8 blockID = 3;
    NSMutableData* dataWithHeader = [NSMutableData dataWithBytes:&blockID length:sizeof(UInt8)];
    // add the port (UInt16)
    [dataWithHeader appendData:[NSData dataWithBytes:&port length:sizeof(UInt16)]];
    // add size of host string (UInt32)
    //NSString *address = [NetworkUtilities getIPAddress:YES];
    //NSData *addressData = [address dataUsingEncoding:NSUTF8StringEncoding];
    //UInt32 addressDataSize = [addressData length];
    //[dataWithHeader appendData:[NSData dataWithBytes:&addressDataSize length:sizeof(UInt32)]];
    // add host string
    //[dataWithHeader appendData:addressData];
    // add name string?
    
    [self.sender startSendData:dataWithHeader];
    
    [self startTimer];
}

// STARTING POINT OF AN UPLOADER WITH NETSERVICE
// send an Array of all the files in the html folder
// each array entry is an NSDictionary with a "path" key and a "date" key
// we should get back the list of files we have to send
- (void)sendFileIndexOfProject {
    assert(project != nil); // project must not be nil
    
    // add the header
    // ID 0 means we're sending the file index
    UInt8 blockID = 0;
    NSMutableData* dataWithHeader = [NSMutableData dataWithBytes:&blockID length:sizeof(UInt8)];
    [dataWithHeader appendData:[project getArrayOfFilesAsNSData]];
    
    [self.sender startSendData:dataWithHeader];
    
    [self startTimer];
}

- (void)timeout:(NSTimer *)_timer {
    NSLog(@"the mtfkr timer identity: %@", _timer);
    [self stop];
    //if (endingMessageSent) return; // we're done, don't timeout me if you're not invalidated somehow
    [delegate uploadOfUploader:self EndedWithStatus:@"Timeout, no response from device."];
}
- (NSString *)getTargetHost {
    return [sender host];
}

- (void)sendNextFileInQueue {
    // send only if there's an element in queue... no duh
    if ([queue count] > 0) {
        NSString *path = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        
        //NSLog(@"[%@] sending file \"%@\"", destinationName, path);
        NSString *filePathInProject = [NSString stringWithFormat:@"Books/%@/%@", project.folderName, path];
        NSLog(@"Sending file: %@", filePathInProject);
        
        //NSString *fileAbsolutePath = [project.htmlFolderPath stringByAppendingPathComponent:path];
        NSString *fileAbsolutePath = [project path];
        
        // ID 1 means we're sending a file
        UInt8 blockID = 1;
        // string path data
        NSData* pathStringData = [filePathInProject dataUsingEncoding:NSUTF8StringEncoding];
        // size of the path string we're sending
        UInt32 pathStringSize = (UInt32)pathStringData.length;
        
        NSMutableData* data = [NSMutableData dataWithBytes:&blockID length:sizeof(UInt8)];
        [data appendBytes:&pathStringSize length:sizeof(UInt32)];
        [data appendData:pathStringData];
        [data appendData:[NSData dataWithContentsOfFile:fileAbsolutePath]];
        
        [sender startSendData:data];
    } else {
        // queue is empty, tell Platypus we're done
        // ID 2 means we're done
        UInt8 blockID = 2;
        NSMutableData* data = [NSMutableData dataWithBytes:&blockID length:sizeof(UInt8)];
        NSLog(@"[%@] ended the update of the project \"%@\"", destinationName, project.name);
        //[data appendData:[project.name dataUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"[%@] sending project name data. Its size: %lu", destinationName, (unsigned long)[data length]);
        endingMessageSent = YES;
        [sender startSendData:data];
    }
}

- (void)sendFilesInArray:(NSArray *)array {
    assert(project != nil); // project must not be nil
    
    queue = [array mutableCopy];
    [self sendNextFileInQueue];
}

#pragma mark implementation of SenderDelegate callbacks

- (void)sendDidStopWithStatus:(NSString *)statusString{
    if (statusString == nil) {
        // file was sent correctly
        // NSLog(@"Network Sending stopped with status: Send succeeded");
        if (endingMessageSent) {
            [self stop];
            [delegate uploadOfUploader:self EndedWithStatus:[NSString stringWithFormat:@"[%@] Upload ended successfully", destinationName]];
        }
    } else {
        [self stop];
        [delegate uploadOfUploader:self EndedWithStatus:statusString];
        NSLog(@"[%@] Network Sending stopped with status: %@", destinationName, statusString);
    }
}

#pragma mark * Receiving methods

#pragma mark ReceiveServerDelegate methods implementation

- (void)serverDidStartOnPort:(NSUInteger)port {
    if (receiveServer.netService == nil) {
        [self sendHostInfo:port];
    }
}

- (void)receivedDataAtPath:(NSString *)path {
    // not used
    // would give path to a temp file
}

- (void)receivedData:(NSData *)data {
    [self stopTimer];
    
    // get the block id
    NSRange range = NSMakeRange(0, sizeof(UInt8));
    // convert to UInt8
    UInt8 blockID;
    [data getBytes:&blockID range:range];
    
    NSData* dataWithoutHeader = [data subdataWithRange:NSMakeRange(sizeof(UInt8), data.length - sizeof(UInt8))];
    
    switch (blockID) {
        case 10: {
            // list of the files needed to update the book
            // it is an array of NSString with the filepathes
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:dataWithoutHeader];
            
            if (array != NULL) {
                // if the array is empty, stop the uploader
                if ([array count] == 0) {
                    [self stop];
                    [delegate uploadOfUploader:self EndedWithStatus:@"No update was needed"];
                    // we don't want the timer to resume
                    return;
                } else {
                    // send the files
                    NSLog(@"[%@] got the data back: %@", destinationName, array);
                    [self sendFilesInArray:array];
                }
            } else {
                NSLog(@"[%@] Data couldn't be converted to array from data block with ID 0.", destinationName);
            }
            break;
        }
        case 11: {
            // we received a response from Platypus
            BOOL success;
            [dataWithoutHeader getBytes:&success];
            if (success) {
                NSLog(@"[%@] File transfered successfully", destinationName);
            } else {
                NSLog(@"[%@] Error during file transfer. Maybe send file again?", destinationName);
            }
            [self sendNextFileInQueue];
            break;
        }
        case 12: {
            // a manual host connection has been confirmed by a device,
            // begin the sending of files
            [self sendFileIndexOfProject];
            break;
        }
        default:
            break;
    }
    
    [self startTimer];
}

@end
