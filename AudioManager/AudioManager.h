//
//  AudioManager.h
//  
//
//  Created by Bernard Hommer Esquivel on 3/14/13.
//
//

//#import "SimpleAudioEngine.h"

#import "CDAudioManager.h"
#import "cocos2d.h"

#define DEFAULT_MUSIC @"bumble_bee.mp3"
#define DEFAULT_SFX   @"alien-sfx.caf"
#define SFX @"SFX"
#define MUSIC @"MUSIC"
#define MIN_VOLUME 0.0
#define MAX_VOLUME 1.0
#define DEFAULT_VOLUME 0.5
#define CURRENT_MUSIC_PLAYED_KEY @"CURRENT_MUSIC_PLAYED_KEY"

@interface AudioManager : NSObject {
    
    float _playCount;
    float musicVolume;
    float sfxVolume;
//    SimpleAudioEngine *soundEngine;
    
}

@property (nonatomic, retain) NSString *bgMusicFile;
@property (readonly) BOOL willPlayBackgroundMusic;
@property (nonatomic) float sfxVolume;
@property (nonatomic) float musicVolume;

// StartPoint
+(AudioManager*) sharedAudioManager;
- (void)startEngine;

// Music Controls
- (void)playMusic:(NSString*)file repeat:(BOOL) repeatVal;

- (void)stopMusic;
- (void)preloadDefaultMusic;
- (void)preloadOtherMusic:(NSString *)bgMusic;
- (void)pauseMusic;
- (void)resumeMusic;

// Changing Volumes
- (void)changeDefaultVolumes:(bool)change backGroundVolume:(float)bgVolume effectsVolume:(float)effectVolume changeNow:(bool)adjust;
- (void)adjustVolumes:(bool)adjust musicVolume:(float)musVol effectsVolume:(float)effVol;
- (void)toggleMute:(bool)mute fade:(bool)fadeYesNo fadeTime:(float)time;
- (NSString *) increaseVolumeOf:(NSString*) string;
- (NSString *) decreaseVolumeOf:(NSString*) string;


// Effects Controls
- (ALuint) playSFX:(NSString*) effect;
- (void)preloadSFX:(NSString *)effect;


+(void) end;

@end