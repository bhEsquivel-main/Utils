//
//  SaveFileManager.m
//  
//
//  Created by Bernard Hommer Esquivel on 3/13/13.
//
//

#import "SaveFileManager.h"
#import "NSData+CommonCrypto.h"

#define SAVE_STATE_FILENAME    @"PlayerPrefsFile.txt"
#define CRYPT_PASSWORD         @"bhEsquivel"

@interface SaveFileManager (PrivateMethods)
-(void) jsonFromDictionary;
-(void) flush;
-(void) saveState;
-(void) loadState;
-(void) encryptData;
-(void) decryptData;
-(NSString*) getFilePath;
-(NSDictionary*) dictFromJson:(NSData*)data;

@end


@implementation SaveFileManager
static SaveFileManager* _saveFileMgr = nil;
@synthesize mutableDict = _mutableDict;
@synthesize jsonSerialized =_jsonSerialized;


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
        _jsonSerialized = nil;
    }
    return self;
}

#pragma mark LOAD/SAVE Methods
-(id) loadThisValueWithKey:(NSString *)key
{
    [self loadState];
    [self decryptData];
    if(_jsonSerialized){
        NSDictionary *dictFromJson = [NSDictionary dictionaryWithDictionary:[self dictFromJson:_jsonSerialized]];
        if (dictFromJson) {
           return [dictFromJson objectForKey:key];
        }
    }
    return nil;
}

-(void) saveThisValue:(id)value withKey:(NSString *)key
{
    [self loadState];
    [self decryptData];
    if(_jsonSerialized){
        NSDictionary *dictFromJson = [NSDictionary dictionaryWithDictionary:[self dictFromJson:_jsonSerialized]];
        if (dictFromJson) {
            [_mutableDict addEntriesFromDictionary:dictFromJson];
        }
    }
    [_mutableDict setObject:value forKey:key];
    [self jsonFromDictionary];

}


#pragma mark JSON/DICT CONVERSION
-(NSDictionary*)dictFromJson:(NSData*)data
{ 
    NSError *error;
    NSDictionary *dictFromJson = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    if(!dictFromJson){
        NSLog(@"error %@", error);
    }else{
        return dictFromJson;
    }
    return nil;

}

-(void) jsonFromDictionary
{
    NSError *error;
    _jsonSerialized = [NSJSONSerialization dataWithJSONObject:_mutableDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!_jsonSerialized) {
        NSLog(@"Got an error: %@", error);
    } else {
        [self flush];
//        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self encryptData];
        [self saveState];
    }

}

#pragma mark ENCRYPT/Decrypt
-(void)encryptData
{
    NSError *error;
   _jsonSerialized = [_jsonSerialized AES256EncryptedDataUsingKey:CRYPT_PASSWORD error:&error];
}

-(void) decryptData
{
    NSError *error;
    _jsonSerialized = [_jsonSerialized decryptedAES256DataUsingKey:CRYPT_PASSWORD error:&error];
}

#pragma mark LOAD/SAVE/FLUSH
-(void) flush
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:[self getFilePath] error:&error] != YES){
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }
}

-(void) saveState
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_jsonSerialized writeToFile:[self getFilePath] atomically:YES];
}

-(void) loadState
{
    _jsonSerialized =[[NSData dataWithContentsOfFile:[self getFilePath]]  retain];
}


#pragma mark GETFILE
-(NSString*) getFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *cachesDirectory = [libraryDirectory stringByAppendingFormat:@"/Caches"];
    return [cachesDirectory stringByAppendingPathComponent:SAVE_STATE_FILENAME] ;
}

@end
