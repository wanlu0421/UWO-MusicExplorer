//
//  JDPlaybackView.m
//  AVPractice
//
//  Created by Justin Doyle on 2014-08-14.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDPlaybackView.h"
#import <AVFoundation/AVFoundation.h>

@implementation JDPlaybackView

+(Class) layerClass {
    return [AVPlayerLayer class];
}

-(AVPlayer*)player {
    return [(AVPlayerLayer*)[self layer] player];
}

-(void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

-(void)setVideoFillMode:(NSString *)fillMode {
    AVPlayerLayer * playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

@end
