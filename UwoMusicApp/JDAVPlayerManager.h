//
//  JDAVPlayerManager.h
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-08-14.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class JDAudioTrack;
@class JDViewController;

@interface JDAVPlayerManager : NSObject
{
    @private
    AVMutableComposition* mComposition;
    AVURLAsset* mVideoAsset;
    AVMutableCompositionTrack* mVideoTrack;
    JDViewController* mViewController;
    
    
    // Audio mix
    NSMutableArray* mInputParams;
    NSMutableDictionary* mAudioTracks;
    NSMutableArray* mAudioTracksInfo;
    AVMutableAudioMix* mAudioMix;
    
    // Time slider
    UISlider* mTimeSlider;
    double mInterval;
    
    id mTimeObserver;
    
    UILabel* mTimeLabel;

}

@property (nonatomic) AVPlayer* mPlayer;
@property (nonatomic) AVPlayerItem* mPlayerItem;

-(id)initWithVideo:(NSURL*)videoUrl AudioTracksInfo:(NSMutableArray*)audioTracks ViewController:(JDViewController*)viewController;
-(void)setVideoWithUrl:(NSURL*)videoUrl;
-(void)addAudioTrack:(AVPlayerItemTrack*)audioTrack Key:(NSString*)key;
-(AVPlayerItem*)playerItem;
-(AVPlayer*)player;


-(void)createPlayer;
-(void)changeAudioVolumes:(NSMutableArray*)newVolumes TrackNames:(NSMutableArray*)trackNames;

-(void)play;
-(void)pause;
-(void)stop;

-(void)registerTimeSlider:(UISlider*)slider timelabel:(UILabel*)label;
-(void)unregisterTimeSlider;
-(void)syncSlider;

-(void)seekToTimeSeconds:(Float64)seconds;
-(Float64)durationInSeconds;

-(void)toggleMute:(NSString*)musician;
-(BOOL)isMuted:(NSString*)musician;

-(void)removeObservers;

@end
