//
//  AudioManager.m
//  
//
//  Created by Bernard Hommer Esquivel on 3/14/13.
//
//

#import "AudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "SimpleAudioEngine.h"

@interface AudioManager (PrivateMethods)
- (void) loadPreferences;
- (void) savePreferences;
- (void)fadeOutMusic:(float)time endVolume:(float)endVol;
- (void)fadeInMusic:(float)time volume:(float)newVol;

-(ALuint) playEffect:(NSString*) effect pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain;
-(void) stopEffect:(ALuint) soundId;
@end

@implementation AudioManager
static AudioManager* _audioManager = nil;
static CDAudioManager *am = nil;
static CDBufferManager *bufferManager = nil;
static CDSoundEngine* soundEngine = nil;

//@synthesize engine;
@synthesize bgMusicFile = _bgMusicFile;
@synthesize sfxVolume = _sfxVolume;
@synthesize musicVolume = _musicVolume;


+(AudioManager*) sharedAudioManager {
    @synchronized(self)     {
		if (!_audioManager)
			_audioManager = [[AudioManager alloc] init];
	}
	return _audioManager;
}

+ (id) alloc
{
	@synchronized(self)     {
		NSAssert(_audioManager == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

-(id) init {
    
    if(self == [super init]) {
        am = [CDAudioManager sharedManager];
		soundEngine = am.soundEngine;
		bufferManager = [[CDBufferManager alloc] initWithEngine:soundEngine];
    }
    
    return self;
    
}

// Memory
- (void) dealloc
{
	am = nil;
	soundEngine = nil;
	bufferManager = nil;
	[super dealloc];
}

- (void)startEngine {
    [self loadPreferences];
//    engine = [SimpleAudioEngine sharedEngine];
    am.backgroundMusic.volume = _musicVolume;
    am.soundEngine.masterGain = _sfxVolume;
    
    _playCount = 0;
    
    
}

+(void) end
{
	am = nil;
	[CDAudioManager end];
	[bufferManager release];
	[_audioManager release];
	_audioManager = nil;
}

- (void)startUpdater {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update:) userInfo:nil repeats:YES];
}


#pragma  mark SFX
- (void)preloadSFX:(NSString *)effect
{
    int soundId = [bufferManager bufferForFile:effect create:YES];
	if (soundId == kCDNoBuffer) {
		CDLOG(@"Denshion::SimpleAudioEngine sound failed to preload %@",effect);
	} else {
		CDLOG(@"Denshion::SimpleAudioEngine preloaded %@",effect);
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

#pragma mark music
- (void)preloadDefaultMusic
{
   	[am preloadBackgroundMusic:DEFAULT_MUSIC];
    _bgMusicFile = DEFAULT_MUSIC;
}

- (void)preloadOtherMusic:(NSString *)bgMusic
{
    [am preloadBackgroundMusic:bgMusic];
}

- (void)playMusic:(NSString*)file repeat:(BOOL) repeatVal
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentlyPlaying = [userDefaults objectForKey:CURRENT_MUSIC_PLAYED_KEY];
    
    if(!([currentlyPlaying isEqualToString:file] && _playCount > 0)){
        _playCount = 1;
        [am playBackgroundMusic:file loop:repeatVal];
        [userDefaults setObject:file forKey:CURRENT_MUSIC_PLAYED_KEY];
    }
}

- (void)stopMusic {
    [am stopBackgroundMusic];
}

- (void)pauseMusic {
    [am pauseBackgroundMusic];
}

- (void)resumeMusic {
   [am resumeBackgroundMusic];
}

-(BOOL) willPlayBackgroundMusic {
	return [am willPlayBackgroundMusic];
}

- (void)loopFadeOut:(NSTimer *)timer {
    
    NSArray *uInfo = [timer userInfo];
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(performFadeOut:) userInfo:uInfo repeats:NO];
    
}

- (void)loopFadeIn:(NSTimer *)timer {
    
    NSArray *uInfo = [timer userInfo];
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(performFadeIn:) userInfo:uInfo repeats:NO];
    
}

- (void)performFadeIn:(NSTimer *)timer {
    
    NSArray *uInfo = [timer userInfo];
    NSString *stepStr = [NSString stringWithFormat:@"%@", [uInfo objectAtIndex:0]];
    NSString *timerInt = [NSString stringWithFormat:@"%@", [uInfo objectAtIndex:1]];
    NSString *newVolStr = [NSString stringWithFormat:@"%@", [uInfo objectAtIndex:2]];
    
    float timerInterval = [timerInt floatValue];
    float stepSize = [stepStr floatValue];
    float currentVolume = am.backgroundMusic.volume;
    float newVolume = currentVolume + stepSize;
    float newVol = [newVolStr floatValue];
    
    NSLog(@"stepSize: %f", stepSize);
    NSLog(@"currentVolume: %f", currentVolume);
    NSLog(@"newVolume: %f", newVolume);
    
    if(newVolume > newVol) {
        newVolume = newVol;
    }
    am.backgroundMusic.volume = newVolume;
    
    if(am.backgroundMusic.volume == newVol) {
        return;
    }
    [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(loopFadeIn:) userInfo:uInfo repeats:NO];
}

- (void)performFadeOut:(NSTimer *)timer {
    
    NSArray *uInfo = [timer userInfo];
    NSString *stepStr = [NSString stringWithFormat:@"%@", [uInfo objectAtIndex:0]];
    NSString *timerInt = [NSString stringWithFormat:@"%@", [uInfo objectAtIndex:1]];
    NSString *endVolStr = [NSString stringWithFormat:@"%@", [uInfo objectAtIndex:2]];
    float timerInterval = [timerInt floatValue];
    float endVol = [endVolStr floatValue];
    float stepSize = [stepStr floatValue];
    float currentVolume = am.backgroundMusic.volume;
    float newVolume = currentVolume - stepSize;
    
    NSLog(@"stepSize: %f", stepSize);
    NSLog(@"currentVolume: %f", currentVolume);
    NSLog(@"newVolume: %f", newVolume);
    
    if(newVolume < endVol) {
        newVolume = endVol;
    }
    am.backgroundMusic.volume = newVolume;
    
    if(am.backgroundMusic.volume == endVol) {
        return;
    }
    [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(loopFadeOut:) userInfo:uInfo repeats:NO];
}

- (void) savePreferences {
    //Using NSUSERDEFAULTS
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *musVolume = [NSString stringWithFormat:@"%f", _musicVolume];
//    NSString *effVolume = [NSString stringWithFormat:@"%f", _sfxVolume];
//    [userDefaults setObject:musVolume forKey:MUSIC];
//    [userDefaults setObject:effVolume forKey:SFX];

    
    //USING SAVEFILEMANAGER
    [[SaveFileManager saveFileInstance] saveThisValue:[NSNumber numberWithFloat:_musicVolume] withKey:MUSIC];
    [[SaveFileManager saveFileInstance] saveThisValue:[NSNumber numberWithFloat:_sfxVolume] withKey:SFX];
}

- (void) loadPreferences {
    
    //Using NSUSERDEFAULTS
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *musVolume = [userDefaults objectForKey:MUSIC];
//    NSString *effVolume = [userDefaults objectForKey:SFX];
    
    //USING SAVEFILE MANAGER
    
    NSString *musVolume = [[SaveFileManager saveFileInstance] loadThisValueWithKey:MUSIC] ;
    NSString *effVolume = [[SaveFileManager saveFileInstance] loadThisValueWithKey:SFX] ;
    
    if(!(musVolume == nil) && !(effVolume == nil)){
        _musicVolume = [musVolume floatValue];
        _sfxVolume = [effVolume floatValue];
    }else{
        _musicVolume = DEFAULT_VOLUME;
        _sfxVolume = DEFAULT_VOLUME;
    }
    [self adjustVolumes:YES musicVolume:_musicVolume effectsVolume:_sfxVolume];

}

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
    am.backgroundMusic.volume = musVol;
    am.soundEngine.masterGain = effVol;
}

- (NSString *) increaseVolumeOf:(NSString *)string
{
    NSString *returnString;
    
    if([string isEqualToString:MUSIC]){
        if(self.musicVolume < MAX_VOLUME){
            _musicVolume += 0.1 ;
        }
        am.backgroundMusic.volume = _musicVolume;
        returnString = [NSString stringWithFormat:@"%f",_musicVolume];
    }else{
        if(self.sfxVolume < MAX_VOLUME){
            _sfxVolume += 0.1 ;
        }
        am.soundEngine.masterGain = _sfxVolume;
        returnString = [NSString stringWithFormat:@"%f",_sfxVolume];
    }
    [self savePreferences];
    return returnString;
    
    
}

- (NSString *)decreaseVolumeOf:(NSString *)string
{
    NSString *returnString;

    if([string isEqualToString:MUSIC]){
        if(self.musicVolume > MIN_VOLUME){
            _musicVolume -= 0.1 ;
        }
        am.backgroundMusic.volume = _musicVolume;
          returnString = [NSString stringWithFormat:@"%f",_musicVolume];
    }else{
        if(self.sfxVolume > MIN_VOLUME){
            _sfxVolume -= 0.1 ;
        }
        am.soundEngine.masterGain = _sfxVolume;
        returnString = [NSString stringWithFormat:@"%f",_sfxVolume];
    }
    [self savePreferences];
    return returnString;
   
}

- (void)toggleMute:(bool)mute fade:(bool)fadeYesNo fadeTime:(float)time {
    if(am.backgroundMusic.volume> 0) {
        if(fadeYesNo == YES) {
            [self fadeOutMusic:time endVolume:0];
        } else {
            am.backgroundMusic.volume = 0;
        }
        
        am.soundEngine.masterGain = 0;
    } else {
        if(fadeYesNo == YES) {
            [self fadeInMusic:time volume:_musicVolume];
        } else {
            am.backgroundMusic.volume= _musicVolume;
        }
        
        am.soundEngine.masterGain = _sfxVolume;
    }
}


- (void)fadeOutMusic:(float)time endVolume:(float)endVol {
    
    float currentVolume = am.backgroundMusic.volume;
    float timerInterval = (time / 100);
    float stepSize = (currentVolume / 100);
    NSString *stepStr = [NSString stringWithFormat:@"%f", stepSize];
    NSString *timerInt = [NSString stringWithFormat:@"%f", timerInterval];
    NSString *endVolStr = [NSString stringWithFormat:@"%f", endVol];
    NSArray *uInfo = [NSArray arrayWithObjects:stepStr, timerInt, endVolStr, nil];
    
    [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(performFadeOut:) userInfo:uInfo repeats:NO];
    
}

- (void)fadeInMusic:(float)time volume:(float)newVol {
    NSLog(@"Fading in Music");
    float timerInterval = (time / 100);
    float stepSize = (newVol / 100);
    NSString *stepStr = [NSString stringWithFormat:@"%f", stepSize];
    NSString *timerInt = [NSString stringWithFormat:@"%f", timerInterval];
    NSString *newVolStr = [NSString stringWithFormat:@"%f", newVol];
    NSArray *uInfo = [NSArray arrayWithObjects:stepStr, timerInt, newVolStr, nil];
    
    [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(performFadeIn:) userInfo:uInfo repeats:NO];
    
}
@end