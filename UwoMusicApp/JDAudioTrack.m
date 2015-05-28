//
//  JDAudioTrack.m
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-08-14.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDAudioTrack.h"

@implementation JDAudioTrack

@synthesize mTrackMixInputParams, mTrackParams, mTrackURL;

-(void)setTrack:(AVPlayerItemTrack *)audioTrack TrackID:(CMPersistentTrackID)trackId {
    mTrackId = trackId;
    mAudioTrack = audioTrack;
    mIsMuted = false;
}

-(AVAudioMixInputParameters*)getAudioMixInputParams {
    mTrackMixInputParams = [AVMutableAudioMixInputParameters
                            audioMixInputParameters];
    [mTrackMixInputParams setVolume:1.0 atTime:kCMTimeZero];
    [mTrackMixInputParams setTrackID:mTrackId];
    
    mTrackParams = mTrackMixInputParams;
    return mTrackParams;
}

-(void)setVolume:(float)volume {
    [mTrackMixInputParams setVolume:volume atTime:kCMTimeZero];
}

-(void)setMuted:(Boolean)muted {
    mIsMuted = muted;
}

-(Boolean)isMuted {
    return mIsMuted;
}

@end
