//
//  Project.m
//  PlatypusNetwork
//
//  Created by Raphael on 23.06.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "Project.h"

@implementation Project

@synthesize name, path, folderName;//, htmlFolderPath, automaticIndexPath;

- (void)setProjectPath:(NSString *)newPath {
    path = newPath;
    folderName = [path lastPathComponent];
    
    // We don't use HTML folder anymore.
    // The Automat folder is created only if we create a new .automat file
    /*
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    
    // if folders "HTML" and "Automat" don't exist, it means it's a new project.
    // Create them
    htmlFolderPath = [path stringByAppendingPathComponent:@"HTML"];
    if (![filemgr fileExistsAtPath:htmlFolderPath]) {
        [filemgr createDirectoryAtPath:htmlFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
        NSString *indexPath = [htmlFolderPath stringByAppendingPathComponent:@"index.html"];
        NSString *htmlDefaultContent = @"<html><head></head><body><h1>New empty project</h1></body></html>";
        [htmlDefaultContent writeToFile:indexPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSString *automaticWritingFolderPath = [path stringByAppendingPathComponent:@"Automat"];
    if (![filemgr fileExistsAtPath:automaticWritingFolderPath]) {
        [filemgr createDirectoryAtPath:automaticWritingFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    automaticIndexPath = [automaticWritingFolderPath stringByAppendingPathComponent:@"index.automat"];
    */
}

- (void)addFilesInFolderPath:(NSString *)folderPath ToXmlElement:(NSXMLElement *)xmlParent {
    
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *file in content) {
        // ignore invisible files
        if ([file characterAtIndex:0] == [@"." characterAtIndex:0]) continue;
        
        NSString *filePath = [folderPath stringByAppendingPathComponent:file];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        if (isDirectory) {
            // if it's a directory, add files recursively in new node
            NSXMLElement *child = (NSXMLElement *)[NSXMLNode elementWithName:@"folder"];
            [child addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:file]];
            [xmlParent addChild:child];
            [self addFilesInFolderPath:filePath ToXmlElement:child];
        }
        else {
            // add file to the xml
            NSXMLElement *elem = (NSXMLElement *)[NSXMLNode elementWithName:@"file"];
            
            // set name attribute
            [elem addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:file]];
            
            // set date attribute
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            NSDate *date = attributes[NSFileModificationDate];
            NSString *dateString = [NSDateFormatter localizedStringFromDate:date
                                                                  dateStyle:NSDateFormatterShortStyle
                                                                  timeStyle:NSDateFormatterMediumStyle];
            [elem addAttribute:[NSXMLNode attributeWithName:@"date" stringValue:dateString]];
            
            [xmlParent addChild:elem];
        }
    }
}

- (NSXMLDocument *)getXmlListOfFilesInProject {
    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"folder"];
    [root addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:@"HTML"]];
    
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    
    [self addFilesInFolderPath:path ToXmlElement:root];
    
    [root addChild:[NSXMLNode commentWithStringValue:@"Hello world!"]];
    
    return xmlDoc;
}

- (NSData *)getDataOfXmlListOfFilesInProject {
    NSXMLDocument *xmlDoc = [self getXmlListOfFilesInProject];
    return [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
}

- (BOOL)createXmlListOfFilesInProject {
    NSData *xmlData = [self getDataOfXmlListOfFilesInProject];
    NSString *filePath = [path stringByAppendingPathComponent:@"/fileIndex.xml"];
    
    if (![xmlData writeToFile:filePath atomically:YES]) {
        NSLog(@"Could not write document out...");
        return NO;
    }
    return YES;
}

- (void)addFilesInFolderPath:(NSString *)folderPath ToArray:(NSMutableArray *)array {
    NSString *absolutePath = [path stringByAppendingPathComponent:folderPath];
    
    NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absolutePath error:nil];
    
    for (NSString *file in content) {
        // ignore invisible files
        if ([file characterAtIndex:0] == [@"." characterAtIndex:0]) continue;
        // ignore automat directory
        if ([file isEqualTo:@"automat"]) continue;
        
        NSString *fileRelativePath = [folderPath stringByAppendingPathComponent:file];
        NSString *fileAbsolutePath = [absolutePath stringByAppendingPathComponent:file];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:fileAbsolutePath isDirectory:&isDirectory];
        
        if (isDirectory) {
            [self addFilesInFolderPath:fileRelativePath ToArray:array];
        }
        else {
            // get date attribute
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileAbsolutePath error:nil];
            NSDate *date = attributes[NSFileModificationDate];
            
            // add the Book name before the relative path
            NSString *fileRelativePathInBook = [folderName stringByAppendingPathComponent:fileRelativePath];
            
            // create dictionary for file
            NSDictionary *dico = [NSDictionary dictionaryWithObjectsAndKeys:fileRelativePathInBook, @"path", date , @"date", nil];
            
            // add file to the array
            [array addObject:dico];
        }
    }
}

- (NSArray *)getArrayOfFiles {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    // folder path is relative to the project folder
    [self addFilesInFolderPath:@"" ToArray:array];
    return array;
}

- (NSData *)getArrayOfFilesAsNSData {
    NSArray *array = [self getArrayOfFiles];
    //NSLog(@"files in project: %@", array);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    
    return data;
}

- (BOOL)createTextFileIndex {
    NSArray *array = [self getArrayOfFiles];
    NSString *filePath = [path stringByAppendingPathComponent:@"/fileIndex.txt"];
    
    if (![array writeToFile:filePath atomically:YES]) {
        NSLog(@"Could not write document out...");
        return NO;
    }
    return YES;
}

@end
