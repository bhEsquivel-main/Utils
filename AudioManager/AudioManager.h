//
//  AudioManager.h
//  
//
//  Created by Bernard Hommer Esquivel on 3/14/13.
//
//

//#import "SimpleAudioEngine.h"

#import "CDAudioManager.h"
#import "SaveFileManager.h"

#define DEFAULT_MUSIC @"bumble_bee.mp3"
#define DEFAULT_SFX   @"alien-sfx.caf"

#define MIN_VOLUME 0.0
#define MAX_VOLUME 1.0
#define DEFAULT_VOLUME 0.5

#define CURRENT_MUSIC_PLAYED_KEY @"CURRENT_MUSIC_PLAYED_KEY"
#define MUTE_SAVE_KEY @"MUTE_KEY"
#define SFX_KEY @"SFX"
#define MUSIC_KEY @"MUSIC"

@interface AudioManager : NSObject {
    
    float _playCount;
    float musicVolume;
    float sfxVolume;
    
}

@property (nonatomic, retain) NSString *bgMusicFile;
@property (nonatomic) float sfxVolume;
@property (nonatomic) float musicVolume;

// StartPoint
+(AudioManager*) sharedAudioManager;
- (void)startEngine;

// Music Controls
- (void)playMusic:(NSString*)file repeat:(BOOL) repeatVal;
- (void)stopMusic;
- (void)pauseMusic;
- (void)resumeMusic;
- (void)preloadDefaultMusic;
- (void)preloadOtherMusic:(NSString *)bgMusic;

// Changing Volumes
- (void)changeDefaultVolumes:(bool)change backGroundVolume:(float)bgVolume effectsVolume:(float)effectVolume changeNow:(bool)adjust;
- (void)adjustVolumes:(bool)adjust musicVolume:(float)musVol effectsVolume:(float)effVol;
- (NSString *) increaseVolumeOf:(NSString*) string;
- (NSString *) decreaseVolumeOf:(NSString*) string;
- (NSString *) toggleMute:(BOOL) mute;


// Effects Controls
- (void)preloadSFX:(NSString *)effect;
- (ALuint) playSFX:(NSString*) effect;
-(void) stopEffect:(ALuint) soundId;


+(void) end;

@end