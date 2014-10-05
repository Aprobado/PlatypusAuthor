//
//  MyFileManager.m
//  PlatypusNetwork
//
//  Created by Raphael on 30.09.14.
//  Copyright (c) 2014 Aprobado. All rights reserved.
//

#import "MyFileManager.h"
#import "AutomatParser.h"

@implementation MyFileManager

@synthesize delegate;
@synthesize rootFolderPath;

- (NSDictionary *)getFileInfos:(NSString *)path {
    NSString *directory;
    NSString *name;
    NSString *extension;
    
    directory = [path stringByDeletingLastPathComponent];
    name = [[path lastPathComponent] stringByDeletingPathExtension];
    extension = [path pathExtension];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", directory, @"directory", name, @"name", extension, @"extension", nil];
}

- (void)lockFileAtPath:(NSString *)path {
    NSDictionary *lockFile = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSFileImmutable];
    [[NSFileManager defaultManager] setAttributes:lockFile ofItemAtPath:path error:nil];
}
- (void)unlockFileAtPath:(NSString *)path {
    NSDictionary *lockFile = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:NSFileImmutable];
    [[NSFileManager defaultManager] setAttributes:lockFile ofItemAtPath:path error:nil];
}

- (NSString *)getHtmlFileOfAutomatFileAtPath:(NSString *)path {
    NSString *fileName = [[path lastPathComponent] stringByDeletingPathExtension];
    NSString *htmlFilePath = [NSString stringWithFormat:@"%@/%@.%@", [self htmlDirectory], fileName, @"html"];
    
    return htmlFilePath;
}

#pragma mark * File Type Tests

+ (BOOL)fileAtPathIsAnImage:(NSString *)path {
    BOOL result = NO;
    
    CFStringRef fileExtension = (__bridge CFStringRef) [path pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        result = YES;
    } else {
        result = NO;
    }
    CFRelease(fileUTI);
    return result;
}
+ (BOOL)fileAtPathIsAnAudiovisualContent:(NSString *)path {
    BOOL result = NO;
    
    CFStringRef fileExtension = (__bridge CFStringRef) [path pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeAudiovisualContent)) {
        result = YES;
    } else {
        result = NO;
    }
    CFRelease(fileUTI);
    return result;
}
+ (BOOL)fileAtPathIsATextFile:(NSString *)path {
    BOOL result = NO;
    
    CFStringRef fileExtension = (__bridge CFStringRef) [path pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
        result = YES;
    } else {
        result = NO;
    }
    CFRelease(fileUTI);
    return result;
}

#pragma mark * File Modification

- (void)renameFile:(NSString *)filePath To:(NSString *)newName {
    // it's not permitted to add path components
    // we can't change the path of a file from the file browser for now.
    newName = [newName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    
    // it's not permitted to change a file extension
    if (![[filePath pathExtension] isEqualTo:[newName pathExtension]]) {
        newName = [[newName stringByDeletingPathExtension] stringByAppendingPathExtension:[filePath pathExtension]];
    }
    
    NSString *newPath = [[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
        NSLog(@"file with same name already exists");
        return;
    }
    
    // if it's an automat file, modify the corresponding html file
    if ([[newPath pathExtension] isEqualTo:@"automat"]) {
        NSString *htmlFilePath = [self getHtmlFileOfAutomatFileAtPath:filePath];
        NSString *htmlNewFilePath = [self getHtmlFileOfAutomatFileAtPath:newPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:htmlNewFilePath]) {
            NSLog(@"html file with same name already exists");
            return;
        }
        
        // modify html file name by moving file
        NSError *error;
        [self unlockFileAtPath:htmlFilePath];
        [[NSFileManager defaultManager] moveItemAtPath:htmlFilePath toPath:htmlNewFilePath error:&error];
        if (error != nil) NSLog(@"%@", error);
        else {
            [self lockFileAtPath:htmlNewFilePath];
        }
    }
    
    // modify file name by moving file
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newPath error:&error];
    if (error != nil) NSLog(@"%@", error);
}

- (void)moveFile:(NSString *)filePath To:(NSString *)folderPath {
    // could be used if we implement moving outlineView items by dragging
}

#pragma mark * File Creation

- (void)createDirectoryAtPath:(NSString *)directoryPath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)createNewFileOfType:(NSString *)type {
    // first we need to define the directory where it has to be created
    NSString *directory;
    NSString *defaultFileToCopy;
    NSString *destinationPath;
    
    if ([type isEqualToString:@"Automatic Writing"]) {
        directory = [self automatDirectory];
        defaultFileToCopy = [self automatDefaultFile];
        destinationPath = [self validDestinationPathForFile:[self automatFileDestination:nil]];
    }
    else if ([type isEqualToString:@"HTML"]) {
        directory = [self htmlDirectory];
        defaultFileToCopy = [self htmlDefaultFile];
        destinationPath = [self validDestinationPathForFile:[self htmlFileDestination:nil]];
    }
    else if ([type isEqualToString:@"css"]) {
        directory = [self cssDirectory];
        defaultFileToCopy = [self cssDefaultFile];
        destinationPath = [self validDestinationPathForFile:[self cssFileDestination:nil]];
    }
    else if ([type isEqualToString:@"javascript"]) {
        directory = [self javascriptDirectory];
        defaultFileToCopy = [self javascriptDefaultFile];
        destinationPath = [self validDestinationPathForFile:[self javascriptFileDestination:nil]];
    } else {
        NSLog(@"Error: we can only create new Automatic Writing, HTML, css and javascript files");
        return;
    }
    
    [self createDirectoryAtPath:directory];
    
    if ([self createFileAtPath:destinationPath FromFile:defaultFileToCopy]) {
        NSArray *files = [NSArray arrayWithObject:destinationPath];
        // tell delegate
        [delegate onFilesAdded:files];
    }
}

- (void)copyFilesFromArray:(NSArray *)files {
    NSMutableArray *filesCopied = [[NSMutableArray alloc] init];
    
    for (NSString *file in files) {
        
        if ([MyFileManager fileAtPathIsAnImage:file]) {
            // NSLog(@"It's an image");
            [self createDirectoryAtPath:[self imageDirectory]];
            NSString *destination = [self validDestinationPathForFile:[self imageFileDestination:[file lastPathComponent]]];
            if ([self createFileAtPath:destination FromFile:file]) {
                [filesCopied addObject:destination];
            }
        }
        else if ([MyFileManager fileAtPathIsAnAudiovisualContent:file]) {
            NSLog(@"Dropping a movie or audio file, we don't manage that for now");
        }
        else if ([MyFileManager fileAtPathIsATextFile:file]) {
            NSLog(@"Dropping a text file, we don't manage that for now");
            NSString *destination;
            NSString *fileName = [file lastPathComponent];
            
            if ([[file pathExtension] isEqualToString:@"html"] || [[file pathExtension] isEqualToString:@"htm"]) {
                [self createDirectoryAtPath:[self htmlDirectory]];
                destination = [self validDestinationPathForFile:[self htmlFileDestination:fileName]];
            }
            else if ([[file pathExtension] isEqualToString:@"css"]) {
                [self createDirectoryAtPath:[self cssDirectory]];
                destination = [self validDestinationPathForFile:[self cssFileDestination:fileName]];
            }
            else if ([[file pathExtension] isEqualToString:@"js"]) {
                [self createDirectoryAtPath:[self javascriptDirectory]];
                destination = [self validDestinationPathForFile:[self javascriptFileDestination:fileName]];
            }
            else if ([[file pathExtension] isEqualToString:@"automat"]) {
                [self createDirectoryAtPath:[self automatDirectory]];
                destination = [self validDestinationPathForFile:[self automatFileDestination:fileName]];
            }
            
            if ([self createFileAtPath:destination FromFile:file]) {
                [filesCopied addObject:destination];
            }
        }
    }
    
    [delegate onFilesAdded:[NSArray arrayWithArray:filesCopied]];
}

// be sure to have a valid path before creating / copying the file
- (BOOL)createFileAtPath:(NSString *)destinationPath FromFile:(NSString *)sourcePath {
    return [self createFileAtPath:destinationPath FromFile:sourcePath LockFile:NO];
}
- (BOOL)createFileAtPath:(NSString *)destinationPath FromFile:(NSString *)sourcePath LockFile:(BOOL)lock {
    
    NSError *error;
    if ([[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error]) {
        
        // if we created an automat file, we need the html equivalent
        if ([[destinationPath pathExtension] isEqualToString:@"automat"]) {
            [self generateHtmlFromAutomatFileAtPath:destinationPath];
        }
        
        if (lock) {
            [self lockFileAtPath:destinationPath];
        }
        
        return YES;
        
    } else {
        NSLog(@"%@", error);
        return NO;
    }
}

- (BOOL)generateHtmlFromAutomatFileAtPath:(NSString *)path {
    NSString *convertedAutomatFile = [AutomatParser automatFileToHtml:path];
    if (convertedAutomatFile == nil) return NO;
    
    NSString *htmlFilePath = [self getHtmlFileOfAutomatFileAtPath:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:htmlFilePath]) {
        [self unlockFileAtPath:htmlFilePath];
    }
    
    NSError *error;
    [convertedAutomatFile writeToFile:htmlFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error !=  nil) {
        NSLog(@"Error writing converted automat file:  %@", error);
        return NO;
    }
    [self lockFileAtPath:htmlFilePath];
    
    return YES;
}

#pragma mark * File Deletion

- (void)deleteFile:(NSString *)filePath {
    
    // if file is locked, don't trash the file
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    if (attributes != nil) {
        if ([[attributes objectForKey:NSFileImmutable] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            return;
        }
    }
    
    // if we're trashing an automat file...
    if ([[filePath pathExtension] isEqualToString:@"automat"]) {
        // ... delete the corresponding html file
        NSString *htmlFilePath = [self getHtmlFileOfAutomatFileAtPath:filePath];
        
        [self unlockFileAtPath:htmlFilePath];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:htmlFilePath];
        
        NSError *error;
        if (![[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:nil error:nil]) {
            NSLog(@"%@", error);
        }
    }
    
    NSError *error;
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    if (![[NSFileManager defaultManager] trashItemAtURL:url resultingItemURL:nil error:&error]) {
        NSLog(@"%@", error);
    }
}

#pragma mark * Utilities for managing files with same name

- (NSString *)suffixeOfNextFileForFile:(NSDictionary *)fileInfos {
    
    NSInteger index = 1;
    NSString *suffixe = @"";
    while ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@%@.%@", [fileInfos objectForKey:@"directory"], [fileInfos objectForKey:@"name"], suffixe, [fileInfos objectForKey:@"extension"]]]) {
        index ++;
        suffixe = [NSString stringWithFormat:@"%d", (int)index];
    }
    
    return suffixe;
}

- (NSString *)validDestinationPathForFile:(NSString *)filePath {
    NSDictionary *fileInfos = [self getFileInfos:filePath];
    
    NSString *suffixe = @"";
    if ([[[fileInfos objectForKey:@"directory"] lastPathComponent] isEqualToString:@"automat"]) {
        // automat files generate html files. So we need to check if html pages exist instead of automat pages.
        NSString *htmlFilePath = [self getHtmlFileOfAutomatFileAtPath:filePath];
        NSDictionary *htmlInfos = [self getFileInfos:htmlFilePath];
        suffixe = [self suffixeOfNextFileForFile:htmlInfos];
    } else {
        suffixe = [self suffixeOfNextFileForFile:fileInfos];
    }
    
    return [NSString stringWithFormat:@"%@/%@%@.%@",
            [fileInfos objectForKey:@"directory"],
            [fileInfos objectForKey:@"name"],
            suffixe,
            [fileInfos objectForKey:@"extension"]];
}

#pragma mark * Default files destinations

- (NSString *)automatFileDestination:(NSString *)fileName {
    if (fileName == nil || [fileName isEqualToString:@""]) {
        fileName = [[self automatDefaultFile] lastPathComponent];
    }
    return [[self automatDirectory] stringByAppendingPathComponent:fileName];
}
- (NSString *)cssFileDestination:(NSString *)fileName {
    if (fileName == nil || [fileName isEqualToString:@""]) {
        fileName = [[self cssDefaultFile] lastPathComponent];
    }
    return [[self cssDirectory] stringByAppendingPathComponent:fileName];
}
- (NSString *)javascriptFileDestination:(NSString *)fileName {
    if (fileName == nil || [fileName isEqualToString:@""]) {
        fileName = [[self javascriptDefaultFile] lastPathComponent];
    }
    return [[self javascriptDirectory] stringByAppendingPathComponent:fileName];
}
- (NSString *)htmlFileDestination:(NSString *)fileName {
    if (fileName == nil || [fileName isEqualToString:@""]) {
        fileName = [[self htmlDefaultFile] lastPathComponent];
    }
    return [[self htmlDirectory] stringByAppendingPathComponent:fileName];
}
- (NSString *)imageFileDestination:(NSString *)fileName {
    if (fileName == nil || [fileName isEqualToString:@""]) {
        fileName = @"unnamed image";
    }
    return [[self imageDirectory] stringByAppendingPathComponent:fileName];
}

#pragma mark * Default directories for files

- (NSString *)automatDirectory {
    return [[self rootFolderPath] stringByAppendingPathComponent:@"automat"];
}
- (NSString *)cssDirectory {
    return [[self rootFolderPath] stringByAppendingPathComponent:@"css"];
}
- (NSString *)javascriptDirectory {
    return [[self rootFolderPath] stringByAppendingPathComponent:@"lib"];
}
- (NSString *)htmlDirectory {
    return [self rootFolderPath];
}
- (NSString *)imageDirectory {
    return [[self rootFolderPath] stringByAppendingPathComponent:@"images"];
}

#pragma mark * Paths for default files

- (NSString *)automatDefaultFile {
    return [[NSBundle mainBundle] pathForResource:@"page" ofType:@".automat" inDirectory:@"DefaultFiles"];
}
- (NSString *)cssDefaultFile {
    return [[NSBundle mainBundle] pathForResource:@"default" ofType:@".css" inDirectory:@"DefaultFiles"];
}
- (NSString *)javascriptDefaultFile {
    return [[NSBundle mainBundle] pathForResource:@"script" ofType:@".js" inDirectory:@"DefaultFiles"];
}
- (NSString *)htmlDefaultFile {
    return [[NSBundle mainBundle] pathForResource:@"page" ofType:@".html" inDirectory:@"DefaultFiles"];
}

@end
