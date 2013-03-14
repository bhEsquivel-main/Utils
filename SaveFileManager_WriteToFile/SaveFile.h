//
//  SaveFile.h
//  
//
//  Created by Bernard Hommer Esquivel on 3/12/13.
//
//

#import <Foundation/Foundation.h>

#define SAVE_STATE_FILENAME    @"PlayerPrefsFile.txt"

@interface SaveFile : NSObject {
    
}
@property (nonatomic, retain) NSData *jsonSerialized;

+(SaveFile*) sharedInstance;
-(void)loadState;
-(void)saveState;


@end
