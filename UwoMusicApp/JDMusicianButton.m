//
//  JDMusicianButton.m
//  MusicExplorer
//
//  Created by Justin Doyle on 10/6/2014.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDMusicianButton.h"

@implementation JDMusicianButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithLabel:(NSString*)label
{
    self = [super init];
    if(self) {
        mLabel = label;
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"mute_icon" withExtension:@"gif"];
        NSData* imgData = [NSData dataWithContentsOfURL:url];
        UIImage* muteImage = [UIImage imageWithData:imgData];
        
        
        mMuteImageView = [[UIImageView alloc] initWithImage:muteImage];
        
        [self addSubview:mMuteImageView];
        mMuteImageView.frame = CGRectMake(0, 0, 50.0f, 50.0f);
        [mMuteImageView setAlpha:0.0f];
    }
    return self;
}

-(NSString*)label {
    return mLabel;
}

-(void)setLabel:(NSString *)label {
    mLabel = label;
}

-(void)registerDoubleTapMute:(JDAVPlayerManager *)avManager
         VideoViewController:(JDViewController *)vc {
    mAvManager = avManager;
    mJDViewController = vc;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTappedToMute:)];
    tapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapGesture];
}

-(void)deregisterDoubleTapMute {
    mAvManager = nil; // TODO: This is throwing a EXC_BAD_ACCESS code=2
    mJDViewController = nil;
    [self removeGestureRecognizer:tapGesture];
}

-(void)doubleTappedToMute:(UITapGestureRecognizer*)sender {
    if(sender.state == UIGestureRecognizerStateRecognized) {
        NSLog(@"Double tapped");
        [mAvManager toggleMute:[self label]];
        [mJDViewController callVideoScrolledOrZoomed];
        
        if([mAvManager isMuted:[self label]]) {
            // Show a mute label
            [mMuteImageView setAlpha:1.0f];
        }
        else {
            // Remove mute label
            [mMuteImageView setAlpha:0.0f];
        }
    }
}

-(void)registerLongPress:(JDViewController*)vc audioTrackInfo:(JDAudioTrackInfo*)ati infoLabel:(UILabel*)label infoText:(UITextView*)text
{
    mJDViewController = vc;
    mInfoLabel = label;
    mInfoText = text;
    mAudioTrackInfo = ati;
    
    self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(musicianLongPressed:)];
    
    self.longGesture.minimumPressDuration = 0.6f;
    self.longGesture.allowableMovement = 100.0f;
    
    [self addGestureRecognizer:self.longGesture];
    
}

-(void)deregisterLongPress
{
    [self removeGestureRecognizer:self.longGesture];
}

- (void)musicianLongPressed:(UILongPressGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Long pressed");
        [[JDStatisticsLogger loggerInstance] logMusicianInfoOpenedForMusician:mAudioTrackInfo.name];
        mInfoLabel.text = mAudioTrackInfo.name;
        
        if(mAudioTrackInfo.description == nil){
            mInfoText.text = @"this is a test\n \nthis will going to show the information of the musician \n\nname \n\n\ninstrument \n\n\n\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n\n\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n\n\n\n\n\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n\n\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
            mInfoText.font = [UIFont boldSystemFontOfSize:15];
        }
        else {mInfoText.text = mAudioTrackInfo.description;}
        
        [mJDViewController handleMusicianLongPress];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
