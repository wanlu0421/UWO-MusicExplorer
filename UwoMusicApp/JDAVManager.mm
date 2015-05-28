//
//  JDAVManager.m
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-06-22.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDAVManager.h"

@implementation JDAVManager

-(id)init {
    if (self = [super init]) {
        playing = false;
        audioInitialized = false;
        audioPacketOffset = 0;
        videoPlaybackTime = 0;
    }
    return self;
}

/*
    Need to create a constructor that inits the AVManager with the number of layers already
    specified, and get rid of the default init method. Also should look into setting up
    a dictionary structure for the layers instead of a vector.
 */

-(int)AddAudioLayerWithFilename:(NSString *)inFilename fileExtension:(NSString *)inExtension  {
    
    NSString *url = [[[NSBundle mainBundle] URLForResource:inFilename withExtension:inExtension] absoluteString];
    AQPlayer *layer = new AQPlayer();
    layer->CreateQueueForFile((__bridge CFStringRef)url);
    
    
    if(currentAudioLayer >= numberOfAudioLayers) {
        printf("Can't add another audio layer.");
        return -1;
    } else {
        audioLayers[currentAudioLayer++] = layer;
        return 0;
    }
}

-(void)SetNumberOfAudioLayers:(int)inNumOfLayers {
    numberOfAudioLayers = inNumOfLayers;
    currentAudioLayer = 0;
    audioLayers.assign(numberOfAudioLayers, NULL);
}

-(void)SetAudioLayerVolumeOfIndex:(int)inIndex volume:(float)inVolume {
    audioLayers[inIndex]->SetGain(inVolume);
}

-(void)SetAudioPacketOffset:(SInt64)inOffset {
    audioPacketOffset = inOffset;
    
    for (int i = 0; i < numberOfAudioLayers; i++) {
        audioLayers[i]->SetPacketOffset(inOffset);
    }
}

-(int)SetVideoFile:(NSString *)inFileName fileExtension:(NSString *)inExtension {
    videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:inFileName ofType:inExtension]];
    
    if(videoURL)
        return 0;
    else
        return -1;
}

-(void)SetStartingPlaybackTime:(NSNumber *)inTime {
    videoPlaybackTime = inTime;
}

-(NSURL*)GetVideoFile {
    return videoURL;
}

-(MPMoviePlayerController*)GetVideoPlayer {
    return videoPlayer;
}

- (UIView*)CreateMoviePlayer:(UIScrollView*)inParentScrollView {
    // Set up the player
    /*
        MPMoviePlayer doesn't really seem to have the fine control that
        we need for video and audio synchronization. Look into AVFoundation playback:
            https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/02_Playback.html#//apple_ref/doc/uid/TP40010188-CH3-SW4
     
     */
    videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    [videoPlayer setScalingMode:MPMovieScalingModeAspectFit];
    [videoPlayer setControlStyle:MPMovieControlStyleNone];
    [videoPlayer.view setFrame:inParentScrollView.bounds];
    UIView *playerView = [[UIView alloc] initWithFrame:videoPlayer.view.bounds];
    [videoPlayer.view addSubview:playerView];
    [inParentScrollView addSubview:videoPlayer.view];
    return playerView;
    
}

-(void)Play {
    
    // Get a timestamp to sync audio tracks to.
    audioTimeStamp = {0};
    Float64 secondsOffset = 0.1;
    Float64 hostTimeFreq = CAHostTimeBase::GetFrequency();
    UInt64 startHostTime = CAHostTimeBase::GetCurrentTime() + secondsOffset * hostTimeFreq;
    
    audioTimeStamp.mFlags = kAudioTimeStampHostTimeValid;
    audioTimeStamp.mHostTime = startHostTime;
    
    // *** THIS IS TEMPORARY FOR DEMOING UNTIL TIME SLIDER IS IMPLEMENTED ***
    for (int i = 0; i < numberOfAudioLayers; i++) {
        audioLayers[i]->SetCurrentTime(0, 0);
    }
    
    
    [videoPlayer setInitialPlaybackTime:[videoPlaybackTime doubleValue]];
    // *** END TESTING AREA ***
    
    // Adds a listener to the first audio track that takes care of video playback
    // synchronization.
    AudioQueueAddPropertyListener(audioLayers[0]->Queue(),
                                  kAudioQueueProperty_IsRunning,
                                  VideoSyncCallback,
                                  (__bridge void*)self);
    
    for (int i = 0; i < numberOfAudioLayers; i++) {
        audioLayers[i]->StartQueue(audioInitialized, audioTimeStamp);
    }
    
    audioInitialized = true;
    playing = true;
    //[videoPlayer play];
}

-(void)Resume {
    
    // Get a timestamp to sync audio tracks to.
    audioTimeStamp = {0};
    Float64 secondsOffset = 0.1;
    Float64 hostTimeFreq = CAHostTimeBase::GetFrequency();
    UInt64 startHostTime = CAHostTimeBase::GetCurrentTime() + secondsOffset * hostTimeFreq;
    
    audioTimeStamp.mFlags = kAudioTimeStampHostTimeValid;
    audioTimeStamp.mHostTime = startHostTime;
    
    for (int i = 0; i < numberOfAudioLayers; i++) {
        audioLayers[i]->StartQueue(audioInitialized, audioTimeStamp);
    }
    
    audioInitialized = true;
    playing = true;
    //[videoPlayer play];
}


-(void)Pause {
    // The idea is that the first audio layer is offset from the video, then
    // all of the following audio layer are offset from the first audio layer
    audioSynchronizationPacket = audioLayers[0]->GetCurrentPacket();
    UInt32 currentTime = audioLayers[0]->GetCurrentTime();
    unsigned int minutes;
    unsigned int seconds;
    minutes = currentTime / 60;
    seconds = currentTime % 60;
    
    for (int i = 0; i < numberOfAudioLayers; i++) {
        audioLayers[i]->PauseQueue();
        audioLayers[i]->SetCurrentPacket(audioSynchronizationPacket);
    }
    playing = false;

    //[videoPlayer pause];
}

-(void)Stop {
    for (int i = 0; i < numberOfAudioLayers; i++) {
        audioLayers[i]->StopQueue();
    }
    playing = false;
    
    //[videoPlayer stop];
}

static void VideoSyncCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID) {
    JDAVManager* userData = (__bridge JDAVManager*)inUserData;
    UInt32 isRunning;
    UInt32 dataSize;
    AudioQueueGetPropertySize(inAQ, kAudioQueueProperty_IsRunning, &dataSize);
    AudioQueueGetProperty(inAQ, kAudioQueueProperty_IsRunning, &isRunning, &dataSize);
    
    if(isRunning == 0)
        [[userData GetVideoPlayer] pause];
    else
        [[userData GetVideoPlayer] play];
        
}

-(void)DecrementSync {
    UInt64 currentTime = audioLayers[0]->GetCurrentTimeMilliseconds();
    [self Pause];
    for(int i=0; i < numberOfAudioLayers; i++) {
        audioLayers[i]->SetCurrentTime(0, 0, currentTime - INC_DEC_AMOUNT);
    }
    printf("Old:%lld\nNew:%lld\n", currentTime, audioLayers[0]->GetCurrentTimeMilliseconds());
    [self Resume];
}

-(void)IncrementSync {
    UInt64 currentTime = audioLayers[0]->GetCurrentTimeMilliseconds();
    [self Pause];
    
    for(int i=0; i < numberOfAudioLayers; i++) {
        audioLayers[i]->SetCurrentTime(0, 0, currentTime + INC_DEC_AMOUNT);
    }
    printf("Old:%lld\nNew:%lld\n", currentTime, currentTime + INC_DEC_AMOUNT);
    [self Resume];
}


@end
