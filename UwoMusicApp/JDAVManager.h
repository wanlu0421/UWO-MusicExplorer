//
//  JDAVManager.h
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-06-22.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#include "AQPlayer.h"
#include "CAHostTimeBase.h"
#include <mach/mach_time.h>
#include <vector>

#define INC_DEC_AMOUNT 10



@interface JDAVManager : NSObject
{
    @private
    NSURL *videoURL;
    MPMoviePlayerController *videoPlayer;
    std::vector<AQPlayer*> audioLayers;
    int numberOfAudioLayers;
    int currentAudioLayer;
    BOOL audioInitialized;
    BOOL playing;
    AudioTimeStamp audioTimeStamp;
    SInt64 audioSynchronizationPacket;
    SInt64 audioPacketOffset;
    NSNumber* videoPlaybackTime;
}



-(int)AddAudioLayerWithFilename:(NSString*)inFilename fileExtension:(NSString*)inExtension;
-(void)SetNumberOfAudioLayers:(int)inNumOfLayers;
-(void)SetAudioLayerVolumeOfIndex:(int)inIndex volume:(float)inVolume;
-(void)SetAudioPacketOffset:(SInt64)inOffset;
-(int)SetVideoFile:(NSString*)inFileName fileExtension:(NSString*)inExtension;
-(void)SetStartingPlaybackTime:(NSNumber*)inTime;
-(NSURL*)GetVideoFile;
-(MPMoviePlayerController*)GetVideoPlayer;
-(UIView*)CreateMoviePlayer:(UIScrollView*)inParentScrollView;
-(void)Play;
-(void)Resume;
-(void)Pause;
-(void)Stop;

/*** THESE ARE DEV METHODS ONLY ***/
-(void)DecrementSync;
-(void)IncrementSync;

static void VideoSyncCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID);



@end
