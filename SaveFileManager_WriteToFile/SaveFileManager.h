//
//  SaveFileManager.h
//  
//
//  Created by Bernard Hommer Esquivel on 3/13/13.
//
//

#import <Foundation/Foundation.h>
#import "SaveFile.h"

@interface SaveFileManager : NSObject
{

}
@property (nonatomic, retain) NSMutableDictionary *mutableDict;

+(SaveFileManager*) saveFileInstance;
-(void) saveThisValue:(id)value withKey:(NSString*)key;
-(id) loadThisValueWithKey:(NSString*)key;
@end
