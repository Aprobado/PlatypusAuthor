//
//  MyFileManager.h
//  PlatypusNetwork
//
//  Created by Raphael on 30.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "MyFileManagerDelegate.h"

@interface MyFileManager : NSObject {
    id<MyFileManagerDelegate> delegate;
}

//- (NSDictionary *)getFileInfos:(NSString *)path;
//- (NSString *)validDestinationPathForFile:(NSString *)path;

// static methods
+ (BOOL)fileAtPathIsAnImage:(NSString *)path;
+ (BOOL)fileAtPathIsAnAudiovisualContent:(NSString *)path;
+ (BOOL)fileAtPathIsATextFile:(NSString *)path;

// public methods
- (void)createNewFileOfType:(NSString *)type;
- (void)copyFilesFromArray:(NSArray *)files;
- (void)deleteFile:(NSString *)filePath;
- (void)renameFile:(NSString *)filePath To:(NSString *)newName;
- (void)moveFile:(NSString *)filePath To:(NSString *)folderPath;

- (NSString *)getHtmlFileOfAutomatFileAtPath:(NSString *)path;
- (BOOL)generateHtmlFromAutomatFileAtPath:(NSString *)path;

@property(nonatomic, retain) id<MyFileManagerDelegate> delegate;
@property NSString *rootFolderPath;

@end
