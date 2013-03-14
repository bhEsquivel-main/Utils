//
//  SaveFileManager.m
//  
//
//  Created by Bernard Hommer Esquivel on 3/13/13.
//
//

#import "SaveFileManager.h"

@interface SaveFileManager (PrivateMethods)
-(void) jsonSerialized;
-(void) save;
-(void) flush;
@end


@implementation SaveFileManager
static SaveFileManager* _saveFileMgr = nil;
@synthesize mutableDict = _mutableDict;


+(SaveFileManager*)saveFileInstance
{
    if(_saveFileMgr == nil){
        _saveFileMgr = [[[self class] alloc] init];
    }
    return _saveFileMgr;

}


-(id) init
{
    if((self = [super init])){
        _mutableDict = nil;
        _mutableDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id) loadThisValueWithKey:(NSString *)key
{
    NSError *error;
    NSLog(@"sadasd%@",[SaveFile sharedInstance].jsonSerialized);
    if([SaveFile sharedInstance].jsonSerialized){
        NSDictionary *dictFromJson = [NSJSONSerialization JSONObjectWithData:[SaveFile sharedInstance].jsonSerialized options: NSJSONReadingMutableContainers error: &error];
        if (!dictFromJson) {
            NSLog(@"Got an error: %@", error);
        } else {
            return [dictFromJson objectForKey:key];
        }
    }
    return nil;
}

-(void) saveThisValue:(id)value withKey:(NSString *)key
{
    NSError *error;
    if([SaveFile sharedInstance].jsonSerialized  != nil){
        NSDictionary *dictFromJson = [NSJSONSerialization JSONObjectWithData:[SaveFile sharedInstance].jsonSerialized options: NSJSONReadingMutableContainers error: &error];
        if (!dictFromJson) {
            NSLog(@"Got an error: %@", error);
        } else {
            [_mutableDict addEntriesFromDictionary:dictFromJson];
        }
    }
    [_mutableDict setObject:value forKey:key];
    [self jsonSerialized];
}


-(void) jsonSerialized
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_mutableDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        [SaveFile sharedInstance].jsonSerialized = jsonData;
        [self save];
    }

}

-(void) save
{
    [self flush];
    [[SaveFile sharedInstance] saveState];
}

-(void) flush
{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *cachesDirectory = [libraryDirectory stringByAppendingFormat:@"/Caches"];
    NSString *filePath = [cachesDirectory stringByAppendingPathComponent:SAVE_STATE_FILENAME];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:filePath error:&error] != YES){
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }
}

@end
