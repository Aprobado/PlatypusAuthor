//
//  FileSystemItem.m
//  PlatypusNetwork
//
//  Created by Raphael on 18.07.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "FileSystemItem.h"

// A category on NSNetService that's used to sort NSNetService objects by their name.
@interface FileSystemItem (FileSystemItemAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(FileSystemItem *)item;
@end

@implementation FileSystemItem (FileSystemItemAdditions)
- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(FileSystemItem *)item {
    return [[self relativePath] localizedCaseInsensitiveCompare:[item relativePath]];
}
@end

@implementation FileSystemItem

// A leaf node has an empty array of children
// this static array is always the same and always empty
// every leaf node point to this NSArray instance.
static NSMutableArray *leafNode = nil;

- (void)initialize {
    if (self == [FileSystemItem class]) {
        leafNode = [[NSMutableArray alloc] init];
    }
}

- (id)initWithPath:(NSString *)path parent:(FileSystemItem *)parentItem {
    self = [super init];
    if (self) {
        relativePath = [path copy];
        parent = parentItem;
    }
    return self;
}

- (BOOL)isRoot {
    return (parent == NULL);
}

- (BOOL)isDirectory {
    return ([self numberOfChildren] > -1);
}

- (FileSystemItem *)getParent {
    return parent;
}

- (BOOL)isFileInChildren:(NSString *)path {
    for (FileSystemItem *item in children) {
        if ([[item relativePath] isEqualToString:path]) {
            return YES;
        }
    }
    return NO;
}

- (void)cleanChildren {
    NSArray *tmp = [children copy];
    for (FileSystemItem *item in tmp) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[item fullPath]]) {
            [children removeObject:item];
        }
    }
}

- (void)sortChildren {
    [children sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}

// Creates, caches, and returns the array of children
// Loads children incrementally
- (void)reloadChildren {
    if (children == nil) children = [[NSMutableArray alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [self fullPath];
    BOOL isDir, valid;
    
    valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
    
    if (valid && isDir) {
        [self cleanChildren];
        
        NSArray *array = [fileManager contentsOfDirectoryAtPath:fullPath error:NULL];
        
        NSUInteger numChildren, i;
        
        numChildren = [array count];
        //children = [[NSMutableArray alloc] initWithCapacity:numChildren];
        //NSMutableArray *childrenArray = [[NSMutableArray alloc] init];
        
        for (i = 0; i < numChildren; i++)
        {
            // ignore files with no name and invisible files like .DS_Store
            NSString *fileName = [array objectAtIndex:i];
            if ([fileName length] < 1) continue;
            if ([[fileName substringToIndex:1] isEqual: @"."]) continue;
            
            if (![self isFileInChildren:fileName]) {
                FileSystemItem *newChild = [[FileSystemItem alloc]
                                            initWithPath:[array objectAtIndex:i] parent:self];
                [children addObject:newChild];
            }
        }
        
        [self sortChildren];
    }
    else {
        children = leafNode;
    }
}

- (NSArray *)children {
    if (children == nil) {
        [self reloadChildren];
    }
    return children;
}
/*
- (FileSystemItem *)getChildWithFullPath:(NSString *)path {
    for (FileSystemItem *item in children) {
        if ([[item fullPath] isEqualToString:path]) return item;
    }
    return nil;
}
*/
- (FileSystemItem *)getChildOfItem:(FileSystemItem *)item AtPath:(NSString *)pathComponent {
    if ([item numberOfChildren] > 0) {
        for (FileSystemItem *tmpItem in [item children]) {
            if ([[[tmpItem relativePath] lastPathComponent] isEqualToString:pathComponent]) return tmpItem;
        }
    }
    
    return nil;
}

- (FileSystemItem *)getItemWithPath:(NSString *)path {
    // can only work if we're searching from rootItem
    FileSystemItem *rootItem = self;
    while (![rootItem isRoot]) {
        rootItem = [rootItem getParent];
    }
    
    NSString *relativeItemPath = [path stringByReplacingOccurrencesOfString:[rootItem fullPath] withString:@""];
    NSArray *pathComponents = [relativeItemPath pathComponents];
    FileSystemItem *returningItem = rootItem;
    
    for (NSString *component in pathComponents) {
        if ([component isEqualToString:@"/"]) continue; // we don't consider a "/" to be a path component
        returningItem = [self getChildOfItem:returningItem AtPath:component];
        if (returningItem == nil) return nil;
    }
    
    return returningItem;
}

- (NSString *)relativePath {
    return relativePath;
}


- (NSString *)fullPath {
    // If no parent, return our own relative path
    if (parent == nil) {
        return relativePath;
    }
    
    // recurse up the hierarchy, prepending each parent’s path
    return [[parent fullPath] stringByAppendingPathComponent:relativePath];
}


- (FileSystemItem *)childAtIndex:(NSUInteger)n {
    return [[self children] objectAtIndex:n];
}


- (NSInteger)numberOfChildren {
    [self reloadChildren];
    NSArray *tmp = [self children];
    return (tmp == leafNode) ? (-1) : [tmp count];
}

@end
