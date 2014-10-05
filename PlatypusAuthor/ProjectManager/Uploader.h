//
//  FileSender.h
//  PlatypusNetwork
//
//  Created by Raphael on 24.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploaderDelegate.h"
#import "ReceiveServerDelegate.h"
#import "SenderDelegate.h"
#import "Project.h"

@interface Uploader : NSObject<ReceiveServerDelegate, SenderDelegate> {
    
    id<UploaderDelegate> delegate;
}

- (instancetype)initWithProject:(Project *)_project ForDeviceService:(NSNetService *)service WithDelegate:(id)_delegate;
- (instancetype)initWithProject:(Project *)_project ForDeviceService:(NSNetService *)service;
- (instancetype)initWithProject:(Project *)_project ForHost:(NSString *)_host AndPort:(UInt16)_port WithDelegate:(id)_delegate;

-(void)stop;

- (void)sendFileIndexOfProject;
- (void)sendFilesInArray:(NSArray *)array;
- (void)sendNextFileInQueue;

- (NSString *)getTargetHost;

@property(nonatomic, retain) id<UploaderDelegate> delegate;

@end
