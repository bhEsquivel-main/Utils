//
//  SaveFile.m
//  
//
//  Created by Bernard Hommer Esquivel on 3/12/13.
//
//

#import "SaveFile.h"

@implementation SaveFile
static SaveFile* _savedFile = nil;
@synthesize jsonSerialized =_jsonSerialized;


+(SaveFile*)sharedInstance{
    if(_savedFile == nil){
        _savedFile = [[[self class]alloc]init];
    }
    return _savedFile;
}


- (id) init
{
    if ((self = [super init])) {
        _jsonSerialized = nil;
    }
    return  self;
}

#pragma mark
#pragma mark SAVE/LOAD

-(void) loadState{
    @synchronized([SaveFile class]) {
        [_savedFile release];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        NSString *cachesDirectory = [libraryDirectory stringByAppendingFormat:@"/Caches"];
        NSString *filePath = [cachesDirectory stringByAppendingPathComponent:SAVE_STATE_FILENAME];
//        _savedFile = [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] retain];
        _savedFile = [[NSData dataWithContentsOfFile:filePath] retain];
    }
}

-(void) saveState{
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *cachesDirectory = [libraryDirectory stringByAppendingFormat:@"/Caches"];
    NSString *filePath = [cachesDirectory stringByAppendingPathComponent:SAVE_STATE_FILENAME];
    [_jsonSerialized writeToFile:filePath atomically:YES];
//
//    [NSKeyedArchiver archiveRootObject:_savedFile toFile:filePath];
}

@end
