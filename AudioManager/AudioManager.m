//
//  AudioManager.m
//  
//
//  Created by Bernard Hommer Esquivel on 3/14/13.
//
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioManager (PrivateMethods)
- (void) loadPreferences;
- (void) savePreferences;
-(ALuint) playEffect:(NSString*) effect pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain;
@end

@implementation AudioManager
static AudioManager* _audioManager = nil;
static CDAudioManager *cdAudioMngr = nil;
static CDBufferManager *bufferManager = nil;
static CDSoundEngine* soundEngine = nil;

//@synthesize engine;
@synthesize bgMusicFile = _bgMusicFile;
@synthesize sfxVolume = _sfxVolume;
@synthesize musicVolume = _musicVolume;



#pragma mark Start point
+(AudioManager*) sharedAudioManager {
    if(_audioManager == nil){
        _audioManager = [[[self class] alloc] init];
    }
    return _audioManager;
}

-(id) init {
    
    if(self == [super init]) {
        cdAudioMngr = [CDAudioManager sharedManager];
		soundEngine = cdAudioMngr.soundEngine;
		bufferManager = [[CDBufferManager alloc] initWithEngine:soundEngine];
    }
    
    return self;
    
}

#pragma mark dealloc
- (void) dealloc
{
	cdAudioMngr = nil;
	soundEngine = nil;
	bufferManager = nil;
	[super dealloc];
}

- (void)startEngine {
    [self loadPreferences];
    cdAudioMngr.backgroundMusic.volume = _musicVolume;
    cdAudioMngr.soundEngine.masterGain = _sfxVolume;
    
    // Check if current game is muted
    if([[SaveFileManager saveFileInstance] loadThisValueWithKey:MUTE_SAVE_KEY]){
        [self toggleMute:YES];
    }
    _playCount = 0;
}

+(void) end
{
	cdAudioMngr = nil;
	[CDAudioManager end];
	[bufferManager release];
	[_audioManager release];
	_audioManager = nil;
}

#pragma mark Music COntrols
- (void)playMusic:(NSString*)file repeat:(BOOL) repeatVal
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentlyPlaying = [userDefaults objectForKey:CURRENT_MUSIC_PLAYED_KEY];
    
    if(!([currentlyPlaying isEqualToString:file] && _playCount > 0)){
        _playCount = 1;
        [cdAudioMngr playBackgroundMusic:file loop:repeatVal];
        [userDefaults setObject:file forKey:CURRENT_MUSIC_PLAYED_KEY];
    }
}

- (void)stopMusic {
    [cdAudioMngr stopBackgroundMusic];
}

- (void)pauseMusic {
    [cdAudioMngr pauseBackgroundMusic];
}

- (void)resumeMusic {
   [cdAudioMngr resumeBackgroundMusic];
}

- (void)preloadDefaultMusic
{
   	[cdAudioMngr preloadBackgroundMusic:DEFAULT_MUSIC];
}

- (void)preloadOtherMusic:(NSString *)bgMusic
{
    [cdAudioMngr preloadBackgroundMusic:bgMusic];
}



#pragma mark Load/Save
- (void) savePreferences {
    //Using NSUSERDEFAULTS
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *musVolume = [NSString stringWithFormat:@"%f", _musicVolume];
//    NSString *effVolume = [NSString stringWithFormat:@"%f", _sfxVolume];
//    [userDefaults setObject:musVolume forKey:MUSIC_KEY];
//    [userDefaults setObject:effVolume SFX_KEY];

    
    //USING SAVEFILEMANAGER
    [[SaveFileManager saveFileInstance] saveThisValue:[NSNumber numberWithFloat:_musicVolume] withKey:MUSIC_KEY];
    [[SaveFileManager saveFileInstance] saveThisValue:[NSNumber numberWithFloat:_sfxVolume] withKey:SFX_KEY];
}

- (void) loadPreferences {
    
    //Using NSUSERDEFAULTS
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *musVolume = [userDefaults objectForKey:MUSIC_KEY];
//    NSString *effVolume = [userDefaults objectForKey:SFX_KEY];
    
    //USING SAVEFILE MANAGER
    
    NSString *musVolume = [[SaveFileManager saveFileInstance] loadThisValueWithKey:MUSIC_KEY] ;
    NSString *effVolume = [[SaveFileManager saveFileInstance] loadThisValueWithKey:SFX_KEY] ;
    
    if(!(musVolume == nil) && !(effVolume == nil)){
        _musicVolume = [musVolume floatValue];
        _sfxVolume = [effVolume floatValue];
    }else{
        _musicVolume = DEFAULT_VOLUME;
        _sfxVolume = DEFAULT_VOLUME;
    }
    [self adjustVolumes:YES musicVolume:_musicVolume effectsVolume:_sfxVolume];

}


#pragma mark Changing Volumes
- (void)changeDefaultVolumes:(bool)change backGroundVolume:(float)bgVolume effectsVolume:(float)effectVolume changeNow:(bool)adjust {
    if(change == YES) {
        _musicVolume = bgVolume;
        _sfxVolume = effectVolume;
        [self savePreferences];
        if(adjust == YES) {
            [self adjustVolumes:YES musicVolume:_musicVolume effectsVolume:_sfxVolume];
        }
    } else {
        return;
    }
}

- (void)adjustVolumes:(bool)adjust musicVolume:(float)musVol effectsVolume:(float)effVol {
    cdAudioMngr.backgroundMusic.volume = musVol;
    cdAudioMngr.soundEngine.masterGain = effVol;
}

- (NSString *) increaseVolumeOf:(NSString *)string
{
    NSString *returnString;
    
    if([string isEqualToString:MUSIC_KEY]){
        if(self.musicVolume < MAX_VOLUME){
            _musicVolume += 0.1 ;
        }
        cdAudioMngr.backgroundMusic.volume = _musicVolume;
        returnString = [NSString stringWithFormat:@"%f",_musicVolume];
    }else{
        if(self.sfxVolume < MAX_VOLUME){
            _sfxVolume += 0.1 ;
        }
        cdAudioMngr.soundEngine.masterGain = _sfxVolume;
        returnString = [NSString stringWithFormat:@"%f",_sfxVolume];
    }
    [self savePreferences];
    return returnString;
    
    
}

- (NSString *)decreaseVolumeOf:(NSString *)string
{
    NSString *returnString;

    if([string isEqualToString:MUSIC_KEY]){
        if(self.musicVolume > MIN_VOLUME){
            _musicVolume -= 0.1 ;
        }
        cdAudioMngr.backgroundMusic.volume = _musicVolume;
        returnString = [NSString stringWithFormat:@"%f",_musicVolume];
    }else{
        if(self.sfxVolume > MIN_VOLUME){
            _sfxVolume -= 0.1 ;
        }
        cdAudioMngr.soundEngine.masterGain = _sfxVolume;
        returnString = [NSString stringWithFormat:@"%f",_sfxVolume];
    }
    [self savePreferences];
    return returnString;
   
}
- (NSString *)toggleMute:(BOOL) mute
{
    NSString *returnString;
    if(mute){
        cdAudioMngr.backgroundMusic.volume = -0.0;
        cdAudioMngr.soundEngine.masterGain = -0.0;
        returnString = [NSString stringWithFormat:@"%f",0.0];
 
    } else {
        cdAudioMngr.backgroundMusic.volume= _musicVolume;
        cdAudioMngr.soundEngine.masterGain = _sfxVolume;
        returnString = [NSString stringWithFormat:@"%f",_musicVolume];

    }
    return returnString;
}

#pragma mark SFX Controlls
- (void)preloadSFX:(NSString *)effect
{
    int soundId = [bufferManager bufferForFile:effect create:YES];
	if (soundId == kCDNoBuffer) {
		CDLOG(@"Denshion::Failed to preload SFX %@",effect);
	} else {
		CDLOG(@"Denshion::preloaded %@",effect);
	}
}
-(ALuint) playSFX:(NSString *)effect
{
    return [self playEffect:effect pitch:1.0f pan:0.0f gain:1.0f];
}

-(ALuint) playEffect:(NSString*) effect pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain
{
	int soundId = [bufferManager bufferForFile:effect create:YES];
	if (soundId != kCDNoBuffer) {
		return [soundEngine playSound:soundId sourceGroupId:0 pitch:pitch pan:pan gain:gain loop:false];
	} else {
		return CD_MUTE;
	}
}

-(void) stopEffect:(ALuint) soundId {
	[soundEngine stopSound:soundId];
}


@end