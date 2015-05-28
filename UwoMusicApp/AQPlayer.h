//
//  AQPlayer.h
//  AudioPractice
//
//  Created by Justin Doyle on 2014-06-10.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

#include "CAStreamBasicDescription.h"
#include "CAXException.h"

#define kNumberBuffers 3
#define kBufferDurationSeconds .01

class AQPlayer {
public:
    AQPlayer();
    ~AQPlayer();
    
    OSStatus StartQueue(BOOL inResume, AudioTimeStamp &ATS);
    OSStatus StopQueue();
    OSStatus PauseQueue();
    AudioQueueRef Queue() { return mQueue; }
    CAStreamBasicDescription DataFormat() const { return mDataFormat; }
    Boolean IsRunning() const { return (mIsRunning) ? true : false; }
    Boolean IsInitialized() const { return mIsInitialized; }
    CFStringRef GetFilePath() const { return (mFilePath) ? mFilePath : CFSTR(""); }
    Boolean IsLooping() const { return mIsLooping; }
    void SetLooping(Boolean inIsLooping) { mIsLooping = inIsLooping; }
    void CreateQueueForFile(CFStringRef inFilePath);
    void DisposeQueue(Boolean inDisposeFile);
    void SetCurrentPacket(SInt64 inPacket) { mCurrentPacket = inPacket; }
    SInt64 GetCurrentPacket() { return mCurrentPacket; }
    void SetPacketOffset(SInt64 inPacketOffset) { mPacketOffset = inPacketOffset; }
    SInt64 GetPacketOffset() { return mPacketOffset; }
    void SetGain(Float32 inGain) {
        AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, inGain);
        mGain = inGain; }
    Float32 GetGain() { return mGain; }
    UInt32 GetTotalTime();
    UInt32 GetCurrentTime();
    UInt64 GetCurrentTimeMilliseconds();
    void SetCurrentTime(UInt32 inMinutes, UInt32 inSeconds);
    void SetCurrentTime(UInt32 inMinutes, UInt32 inSeconds, UInt64 inMillis);
    void SetTimeSlider(UISlider *inSlider) { mTimeSlider = inSlider; }
    UISlider* GetTimeSlider() { return mTimeSlider; }
    
    
private:
    // Private variables
    AudioQueueRef mQueue;
    AudioQueueBufferRef mBuffers[kNumberBuffers];
    AudioFileID mAudioFile;
    CFStringRef mFilePath;
    CAStreamBasicDescription mDataFormat;
    Boolean mIsInitialized;
    UInt32 mNumPacketsToRead;
    SInt64 mCurrentPacket;
    SInt64 mPacketOffset;
    UInt32 mIsRunning;
    Boolean mIsDone;
    Boolean mIsLooping;
    Float32 mGain;
    UISlider *mTimeSlider;
    
    // Private methods
    UInt32 GetNumPacketsToRead() { return mNumPacketsToRead; }
    
    AudioFileID GetAudioFileID() { return mAudioFile; }
    
    void SetupNewQueue();
    static void isRunningProc(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID);
    static void AQBufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer);
    void CalculateBytesForTime(CAStreamBasicDescription &inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets);
    
    
};