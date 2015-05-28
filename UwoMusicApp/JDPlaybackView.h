//
//  JDPlaybackView.h
//  AVPractice
//
//  Created by Justin Doyle on 2014-08-14.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVPlayer;

@interface JDPlaybackView : UIView

@property(nonatomic, strong) AVPlayer* player;

-(void) setPlayer:(AVPlayer *)player;
-(void) setVideoFillMode:(NSString*)fillMode;

@end
