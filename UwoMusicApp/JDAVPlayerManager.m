//
//  JDAVPlayerManager.m
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-08-14.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDAVPlayerManager.h"
#import "JDAudioTrack.h"
#import "JDAudioTrackInfo.h"
#import "JDViewController.h"

@implementation JDAVPlayerManager

static const NSString *ItemStatusContext = @"ITEMSTATUSCONTEXT";
static const NSString *ItemTracksContext = @"ITEMTRACKSCONTEXT";

-(id)initWithVideo:(NSURL*)videoUrl AudioTracksInfo:(NSMutableArray*)audioTracks  ViewController:(JDViewController*)viewController {
    
    self = [super init];
    if (self) {
        mAudioTracksInfo = audioTracks;
        mViewController = viewController;
        [self setVideoWithUrl:videoUrl];
        
    }
    return self;
}

-(void)setVideoWithUrl:(NSURL *)videoUrl {
    mVideoAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    NSString* tracksKey = @"tracks";
    
    [mVideoAsset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            /** VIDEO ASSET COMPLETETION HANDLER **/
            
            NSError* error;
            AVKeyValueStatus status = [mVideoAsset statusOfValueForKey:tracksKey error:&error];
            
            if(status == AVKeyValueStatusLoaded) {
                self.mPlayerItem = [AVPlayerItem playerItemWithAsset:mVideoAsset];
            }
            
            // ensure that this is done before the PlayerItem is associated with the player
            [self.mPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
            
            self.mPlayer = [AVPlayer playerWithPlayerItem:self.mPlayerItem];
            [mViewController setPlayerForPlaybackView:self.mPlayer];
            [self.mPlayerItem addObserver:self forKeyPath:@"tracks" options:0 context:&ItemTracksContext];
            [self createPlayer];
        });
        }];
        
        
}

-(void)removeObservers {
    [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.mPlayerItem removeObserver:self forKeyPath:@"tracks"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == &ItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([keyPath isEqualToString:@"status"]) {
                if (self.mPlayerItem.status == AVPlayerItemStatusReadyToPlay) {
                    // TODO: Experimental
//                    [self createPlayer];
                    
                    [mViewController enableUi];
                    
                } else if (self.mPlayerItem.status == AVPlayerStatusFailed) {
                    NSLog(@"AVPlayerItem status is failed.");
                }
            }
            
        });
    } else if (context == &ItemTracksContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray* playerTracks = self.mPlayerItem.tracks;
            for(AVPlayerItemTrack* track in playerTracks) {
                track.enabled = YES;
            }
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    return;
}

-(void) syncUi {
    // TODO Sync play button here
    if((self.mPlayer.currentItem != nil) && ([self.mPlayer.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
        // TODO Enable play button
    } else {
        // TODO Disable play button
    }
}

-(void)addAudioTrack:(AVPlayerItemTrack*)audioTrack Key:(NSString*)key TrackId:(CMPersistentTrackID) trackId {
    if(mAudioTracks == NULL)
        mAudioTracks = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    JDAudioTrack* myAudioTrack = [[JDAudioTrack alloc] init];
    [myAudioTrack setTrack:audioTrack TrackID:trackId];
    
    if(mInputParams == NULL)
        mInputParams = [[NSMutableArray alloc] initWithCapacity:5];
    
    [mInputParams addObject:[myAudioTrack getAudioMixInputParams]];
    
    [mAudioTracks setObject:myAudioTrack forKey:key];
}

-(AVPlayerItem*)playerItem {
    return self.mPlayerItem;
}

-(AVPlayer*)player {
    return self.mPlayer;
}


-(void)createPlayer {
    [self.mPlayer prerollAtRate:1.0 completionHandler:^(BOOL finished) {
       
        /** PRE ROLL COMPLETION HANDLER **/
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray* audioTracks = [mVideoAsset tracksWithMediaType:AVMediaTypeAudio];
            
            int numAudioTracks = [mAudioTracksInfo count];
            for (int i = 0; i < numAudioTracks; i++) {
                JDAudioTrackInfo* ati = (JDAudioTrackInfo*)mAudioTracksInfo[i];
                [self addAudioTrack:audioTracks[i] Key:ati.file TrackId:[audioTracks[i] trackID]];
            }
            
            mAudioMix = [AVMutableAudioMix audioMix];
            mAudioMix.inputParameters = mInputParams;
            self.mPlayerItem.audioMix = mAudioMix;
            
            NSArray* playerTracks = self.mPlayerItem.tracks;
            for (AVPlayerItemTrack* track in playerTracks) {
                track.enabled = YES;
            }
        });
    }];
}

-(void)changeAudioVolumes:(NSMutableArray*)newVolumes TrackNames:(NSMutableArray*)trackNames {
    for (int i = 0; i < [newVolumes count]; i++) {
        NSString* name = (NSString*)trackNames[i];
        float volume = [newVolumes[i] floatValue];
        JDAudioTrack* track = (JDAudioTrack*)mAudioTracks[name];
        if ([track isMuted])
            [track setVolume:0.0f];
        else
            [track setVolume:volume];
    }
    
    // Need to set the audio mix again to update the new volumes
    self.mPlayerItem.audioMix = mAudioMix;

}

-(void)play {
    [self.mPlayer play];
}

-(void)pause {
    [self.mPlayer pause];
}

-(void)stop {
    [self.mPlayer pause];
    [self.mPlayer seekToTime:CMTimeMake(0, 1)];
}

-(void)registerTimeSlider:(UISlider *)slider {
    mTimeSlider = slider;
    CMTime playerDuration = [self playerItemDuration];
    if(CMTIME_IS_INVALID(playerDuration))
        return;
    
    double duration = CMTimeGetSeconds(playerDuration);
    
    if (isfinite(duration)) {
        CGFloat width = CGRectGetWidth([mTimeSlider bounds]);
        mInterval = 0.5f * duration / width;
        
    }
    
    @try {
    mTimeObserver = [self.mPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(mInterval, NSEC_PER_SEC)
                                          queue:NULL
                                     usingBlock:^(CMTime time) {
                                         [self syncSlider];
                                     }
     ];
    }
    @catch(NSException *e) {
        NSLog(@"Time observer error");
    }
    
}

-(void)unregisterTimeSlider {
    mTimeSlider = NULL;
    [self.mPlayer removeTimeObserver:mTimeObserver];
    mTimeObserver = NULL;
}

-(CMTime)playerItemDuration {
    if (self.mPlayerItem.status == AVPlayerItemStatusReadyToPlay)
        return [self.mPlayerItem duration];
    return kCMTimeInvalid;
}

-(void)syncSlider {
    CMTime playerDuration = [self playerItemDuration];
    
    if(CMTIME_IS_INVALID(playerDuration)) {
        mTimeSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if(isfinite(duration) && (duration > 0)) {
        float minVal = [mTimeSlider minimumValue];
        float maxVal = [mTimeSlider maximumValue];
        double time = CMTimeGetSeconds([self.mPlayer currentTime]);
        [mTimeSlider setValue:(maxVal - minVal) * time / duration + minVal];
    }
}

-(void)seekToTimeSeconds:(Float64)seconds {
    [self.mPlayer seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
}

-(Float64)durationInSeconds {
    return CMTimeGetSeconds([self.mPlayerItem duration]);
}

-(void)toggleMute:(NSString *)musician  {
    JDAudioTrack* track = mAudioTracks[musician];
    [[JDStatisticsLogger loggerInstance]
        logMute:![track isMuted]
        Musician:musician];
    
    [track setMuted:![track isMuted]];
}

-(BOOL)isMuted:(NSString *)musician {
    JDAudioTrack* track = mAudioTracks[musician];
    return [track isMuted];
}

@end
