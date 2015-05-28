//
//  JDMusicianButton.h
//  MusicExplorer
//
//  Created by Justin Doyle on 10/6/2014.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JDAVPlayerManager.h"
#import "JDViewController.h"

@class JDViewController;

@interface JDMusicianButton : UIView
{
    @private
    NSString* mLabel;
    JDAVPlayerManager* mAvManager;
    JDViewController* mJDViewController;
    UITapGestureRecognizer* tapGesture;
//    UILongPressGestureRecognizer* longGesture;
    UIImageView* mMuteImageView;
    
    UILabel* mInfoLabel;
    UITextView* mInfoText;
    JDAudioTrackInfo* mAudioTrackInfo;
}

@property(nonatomic, strong)UILongPressGestureRecognizer* longGesture;

-(id)initWithLabel:(NSString*)label;

-(NSString*)label;
-(void)setLabel:(NSString*)label;

-(void)registerDoubleTapMute:(JDAVPlayerManager*)avManager VideoViewController:(JDViewController*)vc;
-(void)deregisterDoubleTapMute;

-(void)registerLongPress:(JDViewController*)vc audioTrackInfo:(JDAudioTrackInfo*)ati infoLabel:(UILabel*)label infoText:(UITextView*)text;
-(void)deregisterLongPress;

@end
