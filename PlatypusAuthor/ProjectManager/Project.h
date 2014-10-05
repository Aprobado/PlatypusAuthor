//
//  Project.h
//  PlatypusNetwork
//
//  Created by Raphael on 23.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Project : NSObject

@property NSString* name;
@property (readonly) NSString* path;
@property (readonly) NSString* folderName;
//@property (readonly) NSString* automaticIndexPath;
//@property (readonly) NSString* htmlFolderPath;

- (void)setProjectPath:(NSString *)newPath;

// working with xml
- (NSXMLDocument *)getXmlListOfFilesInProject;
- (NSData *)getDataOfXmlListOfFilesInProject;
- (BOOL)createXmlListOfFilesInProject;

// working with Array of Dictionaries
- (NSArray *)getArrayOfFiles;
- (NSData *)getArrayOfFilesAsNSData;
- (BOOL)createTextFileIndex;

@end
