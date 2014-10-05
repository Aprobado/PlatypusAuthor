//
//  FileSystemItem.h
//  PlatypusNetwork
//
//  Created by Raphael on 18.07.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileSystemItem : NSObject
{
    NSString *relativePath;
    FileSystemItem *parent;
    NSMutableArray *children;
}

- (id)initWithPath:(NSString *)path parent:(FileSystemItem *)parentItem;
- (BOOL)isRoot;
- (BOOL)isDirectory;
- (FileSystemItem *)getParent;
- (void)reloadChildren;
- (NSInteger)numberOfChildren;// Returns -1 for leaf nodes
- (FileSystemItem *)childAtIndex:(NSUInteger)n; // Invalid to call on leaf nodes
//- (FileSystemItem *)getChildWithFullPath:(NSString *)path; // might be deprecated
- (FileSystemItem *)getItemWithPath:(NSString *)path;
- (NSString *)fullPath;
- (NSString *)relativePath;

@end
