//
//  AQPlayer.m
//  AudioPractice
//
//  Created by Justin Doyle on 2014-06-10.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#include "AQPlayer.h"

AQPlayer::AQPlayer() :
mQueue(0),
mAudioFile(0),
mFilePath(NULL),
mIsRunning(false),
mIsInitialized(false),
mNumPacketsToRead(0),
mCurrentPacket(0),
mIsDone(false),
mIsLooping(false),
mGain(1.0),
mTimeSlider(NULL){}

AQPlayer::~AQPlayer() {
    DisposeQueue(true);
}

/*******************************
 
 PUBLIC METHODS
 
 *******************************/

OSStatus AQPlayer::StartQueue(BOOL inResume, AudioTimeStamp &ATS) {
    if((mQueue == NULL) && (mFilePath != NULL))
        CreateQueueForFile(mFilePath);
    
    mIsDone = false;
    
    if(!inResume) {
        // Instead of setting the current packet offset for where the file begins, the
        // objecting handling the audio queue should set the playback time and allow
        // AQPlayer to handle packet offset calculation.
        //mCurrentPacket = kPacketOffset;
    }
    for (int i = 0; i < kNumberBuffers; ++i) {
        AQBufferCallback(this, mQueue, mBuffers[i]);
    }
    //}
    
    return AudioQueueStart(mQueue, &ATS);
}

OSStatus AQPlayer::StopQueue() {
    mIsDone = true;
    OSStatus result = AudioQueueStop(mQueue, true);
    
    if(result)
        printf("Error stopping Audio Queue!");
    
    return result;
}

OSStatus AQPlayer::PauseQueue()
{
    // Queue should be stopped and restarted instead of paused. This is to keep
    // audio layer synchronization.
	OSStatus result = AudioQueueStop(mQueue, true);
    
	return result;
}

void AQPlayer::CreateQueueForFile(CFStringRef inFilePath) {
    CFURLRef soundFile = NULL;
    
    try {
        if(mFilePath == NULL) {
            mIsLooping = false;
            
            soundFile = CFURLCreateWithString(kCFAllocatorDefault, inFilePath, NULL);
            
            if(!soundFile) {
                printf("Can't parse sound file path\n");
                return;
            }
            
            OSStatus result = AudioFileOpenURL(soundFile, kAudioFileReadPermission, 0, &mAudioFile);
            CFRelease(soundFile);
            XThrowIfError(result, "Can't open file");
            
            UInt32 size = sizeof(mDataFormat);
            XThrowIfError(AudioFileGetProperty(mAudioFile, kAudioFilePropertyDataFormat, &size, &mDataFormat), "Couldn't get file's data format");
            mFilePath = CFStringCreateCopy(kCFAllocatorDefault, inFilePath);
        }
        SetupNewQueue();
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
}

void AQPlayer::SetupNewQueue() {
    XThrowIfError(AudioQueueNewOutput(&mDataFormat,
                                      AQPlayer::AQBufferCallback,
                                      this, CFRunLoopGetCurrent(),
                                      kCFRunLoopCommonModes, 0,
                                      &mQueue),
                  "AudioQueueNew failed");
    
    UInt32 bufferByteSize;
    UInt32 maxPacketSize;
    UInt32 size = sizeof(maxPacketSize);
    XThrowIfError(AudioFileGetProperty(mAudioFile,
                                       kAudioFilePropertyPacketSizeUpperBound,
                                       &size,
                                       &maxPacketSize),
                  "Couldn't get file's max packet size");
    
    CalculateBytesForTime(mDataFormat,
                          maxPacketSize,
                          kBufferDurationSeconds,
                          &bufferByteSize,
                          &mNumPacketsToRead);
    
    size = sizeof(UInt32);
    OSStatus result = AudioFileGetPropertyInfo(mAudioFile,
                                               kAudioFilePropertyMagicCookieData,
                                               &size,
                                               NULL);
    if(!result && size) {
        char* cookie = new char[size];
        XThrowIfError(AudioFileGetProperty(mAudioFile,
                                           kAudioFilePropertyMagicCookieData,
                                           &size,
                                           cookie),
                      "Get cookie from file");
        XThrowIfError(AudioQueueSetProperty(mQueue,
                                            kAudioQueueProperty_MagicCookie,
                                            cookie,
                                            size),
                      "Set cookie on queue");
        delete [] cookie;
    }
    
    result = AudioFileGetPropertyInfo(mAudioFile, kAudioFilePropertyChannelLayout, &size, NULL);
    if(result == noErr && size > 0) {
        AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
        
        result = AudioFileGetProperty(mAudioFile, kAudioFilePropertyChannelLayout, &size, acl);
        if(result) {
            free(acl);
            XThrowIfError(result, "Get audio file's channel layout");
        }
        result = AudioQueueSetProperty(mQueue, kAudioQueueProperty_ChannelLayout, acl, size);
        if(result) {
            free(acl);
            XThrowIfError(result, "Set channel layout on queue");
        }
        
        free(acl);
    }
    
    XThrowIfError(AudioQueueAddPropertyListener(mQueue,
                                                kAudioQueueProperty_IsRunning,
                                                isRunningProc,
                                                this),
                  "Adding property listener");
    bool isFormatVBR = (mDataFormat.mBytesPerPacket == 0 || mDataFormat.mFramesPerPacket == 0);
    for (int i = 0; i < kNumberBuffers; ++i) {
        XThrowIfError(AudioQueueAllocateBufferWithPacketDescriptions(mQueue,
                                                                     bufferByteSize,
                                                                     (isFormatVBR ? mNumPacketsToRead : 0),
                                                                     &mBuffers[i]),
                      "AudioQueueAllocateBuffer failed");
    }
    
    XThrowIfError(AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 1.0), "Set queue volume");
    
    mIsInitialized = true;
}

void AQPlayer::DisposeQueue(Boolean inDisposeFile) {
    if(mQueue) {
        AudioQueueDispose(mQueue, true);
        mQueue = NULL;
    }
    if(inDisposeFile) {
        if(mAudioFile) {
            AudioFileClose(mAudioFile);
            mAudioFile = 0;
        }
        if(mFilePath) {
            CFRelease(mFilePath);
            mFilePath = NULL;
        }
    }
    mIsInitialized = false;
}

UInt32 AQPlayer::GetTotalTime() {
    
    /*
     This only currently works for audio files that have a constant bit rate.
     */
    UInt64 packetCount;
    UInt64 totalFrames = 0;
    
    UInt32 size = sizeof(packetCount);
    OSStatus result =  AudioFileGetProperty(mAudioFile, kAudioFilePropertyAudioDataPacketCount, &size, &packetCount);
    if(result) {
        printf("AudioFileGetProperty failed.\n");
    } else {
        if (mDataFormat.mFramesPerPacket) {
            totalFrames = mDataFormat.mFramesPerPacket * packetCount;
        }
    }
    
    return (packetCount * mDataFormat.mFramesPerPacket) / mDataFormat.mSampleRate;
}

UInt32 AQPlayer::GetCurrentTime() {
    /*
     This only currently works for audio files that have a constant bit rate.
     */
    UInt64 packetCount;
    UInt64 totalFrames = 0;
    
    UInt32 size = sizeof(packetCount);
    OSStatus result =  AudioFileGetProperty(mAudioFile, kAudioFilePropertyAudioDataPacketCount, &size, &packetCount);
    if(result) {
        printf("AudioFileGetProperty failed.\n");
    } else {
        if (mDataFormat.mFramesPerPacket) {
            totalFrames = mDataFormat.mFramesPerPacket * packetCount;
        }
    }
    
    // This was for returning total file length
    //return (packetCount * mDataFormat.mFramesPerPacket) / mDataFormat.mSampleRate;
    
    return (mCurrentPacket * mDataFormat.mFramesPerPacket) / mDataFormat.mSampleRate;
}

UInt64 AQPlayer::GetCurrentTimeMilliseconds() {
    /*
     This only currently works for audio files that have a constant bit rate.
     */
    UInt64 packetCount;
    UInt64 totalFrames = 0;
    
    UInt32 size = sizeof(packetCount);
    OSStatus result =  AudioFileGetProperty(mAudioFile, kAudioFilePropertyAudioDataPacketCount, &size, &packetCount);
    if(result) {
        printf("AudioFileGetProperty failed.\n");
    } else {
        if (mDataFormat.mFramesPerPacket) {
            totalFrames = mDataFormat.mFramesPerPacket * packetCount;
        }
    }
    
    
    return (mCurrentPacket * mDataFormat.mFramesPerPacket) / (mDataFormat.mSampleRate / 1000.0f);
}

void AQPlayer::SetCurrentTime(UInt32 inMinutes, UInt32 inSeconds) {
    /*
     This only currently works for audio files that have a constant bit rate.
     */
    UInt64 totalSeconds = (inMinutes * 60) + inSeconds;
    mCurrentPacket = ((totalSeconds * mDataFormat.mSampleRate) / mDataFormat.mFramesPerPacket) + mPacketOffset;
}

void AQPlayer::SetCurrentTime(UInt32 inMinutes, UInt32 inSeconds, UInt64 inMillis) {
    /*
     This only currently works for audio files that have a constant bit rate.
     */
    UInt64 totalMillis = ((inMinutes * 60) + inSeconds) * 1000 + inMillis;
    mCurrentPacket = ((totalMillis * (mDataFormat.mSampleRate / 1000.0f)) / mDataFormat.mFramesPerPacket) + mPacketOffset;
}



/*******************************
 
 PRIVATE METHODS
 
 *******************************/

void AQPlayer::AQBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer) {
    AQPlayer *player = (AQPlayer *)inUserData;
    
    if(player->mIsDone)
        return;
    
    UInt32 numBytes;
    UInt32 nPackets = player->GetNumPacketsToRead();
    OSStatus result = AudioFileReadPackets(player->GetAudioFileID(),
                                           false,
                                           &numBytes,
                                           inCompleteAQBuffer->mPacketDescriptions,
                                           player->GetCurrentPacket(),
                                           &nPackets,
                                           inCompleteAQBuffer->mAudioData);
    if(result)
        printf("AudioFileReadPackets failed: %d", (int)result);
    if(nPackets > 0) {
        inCompleteAQBuffer->mAudioDataByteSize = numBytes;
        inCompleteAQBuffer->mPacketDescriptionCount = nPackets;
        AudioQueueEnqueueBufferWithParameters(inAQ, inCompleteAQBuffer, 0, NULL, 0, 0, 0, NULL, NULL, NULL);
        player->mCurrentPacket = (player->GetCurrentPacket() + nPackets);
        
        /*
         
         This commented out timeSlider section will be used again once the video
         time slider has been implemented.
         
         UISlider *timeSlider = player->GetTimeSlider();
         if (timeSlider) {
         float value = (float)player->GetCurrentTime() / (float)player->GetTotalTime();
         [timeSlider setValue:value animated:NO];
         }*/
        
        
    } else {
        if(player->IsLooping()) {
            player->mCurrentPacket = 0;
            AQBufferCallback(inUserData, inAQ, inCompleteAQBuffer);
        } else {
            player->mIsDone = true;
            AudioQueueStop(inAQ, false);
        }
    }
}

void AQPlayer::isRunningProc(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID) {
    AQPlayer *player = (AQPlayer *)inUserData;
    UInt32 size = sizeof(player->mIsRunning);
    OSStatus result = AudioQueueGetProperty(inAQ,
                                            kAudioQueueProperty_IsRunning,
                                            &player->mIsRunning,
                                            &size);
    
    if((result == noErr) && (!player->mIsRunning)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:nil];
    }
}

void AQPlayer::CalculateBytesForTime(CAStreamBasicDescription &inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets) {
    
    // Calculate an appropriate buffer size without allocating more space than needed.
    static const int maxBufferSize = 0x10000;
    static const int minBufferSize = 0x4000;
    
    if(inDesc.mFramesPerPacket) {
        Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
        *outBufferSize = numPacketsForTime * inMaxPacketSize;
    } else {
        *outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
    }
    
    if(*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize) {
        *outBufferSize = maxBufferSize;
    } else {
        if(*outBufferSize < minBufferSize)
            *outBufferSize = minBufferSize;
    }
    *outNumPackets = *outBufferSize / inMaxPacketSize;
}
