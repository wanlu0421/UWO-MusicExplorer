//
//  JDAudioTrack.h
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-08-14.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface JDAudioTrack : NSObject
{
    @private
    AVMutableAudioMixInputParameters* mTrackMixInputParams;
    AVAudioMixInputParameters* mTrackParams;
    Boolean mIsMuted;
    
    AVPlayerItemTrack* mAudioTrack;
    CMPersistentTrackID mTrackId;
}

@property(nonatomic, strong) AVMutableAudioMixInputParameters* mTrackMixInputParams;
@property(nonatomic, strong) AVAudioMixInputParameters* mTrackParams;
@property(nonatomic, strong) NSURL* mTrackURL;

-(void)setTrack:(AVPlayerItemTrack*)audioTrack TrackID:(CMPersistentTrackID)trackId;
-(AVAudioMixInputParameters*)getAudioMixInputParams;
-(void)setVolume:(float)volume;
-(void)setMuted:(Boolean)muted;

-(Boolean)isMuted;

@end
