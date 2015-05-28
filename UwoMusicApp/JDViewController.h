//
//  JDViewController.h
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-05-19.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

//#import "JDAVManager.h"
#import "JDAVPlayerManager.h"
#import "JDPlaybackView.h"
#import "JDXMLParser.h"
#import "JDVideoTrackInfo.h"
#import "JDAudioTrackInfo.h"
#import "JDMusicianButton.h"
#import "JDStatisticsLogger.h"

#define TESTING_OFFSET (30400000 - 30000)

@class JDPlaybackView;
@class JDAVPlayerManager;

@interface JDViewController : UIViewController
{
    
    @private
    
    // UI Components
    IBOutlet UIScrollView *scrollView;
    IBOutlet JDPlaybackView *mPlaybackView;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UIBarButtonItem *playButton;
    IBOutlet UIBarButtonItem *pauseButton;
    IBOutlet UIBarButtonItem *playStopSpacer;
    IBOutlet UIBarButtonItem *stopButton;
    IBOutlet UIBarButtonItem *stopSliderSpacer;
    IBOutlet UIBarButtonItem *timeSliderBarItem;
    IBOutlet UISlider *timeSlider;
    IBOutlet UIBarButtonItem *boundingBoxButton;
    IBOutlet UIView *musicianInfoView;
    IBOutlet UITextView *musicianText;
    IBOutlet UILabel *musicianLabel;
    IBOutlet UIButton *closeMusicianInfoButton;
    
    CGRect beforeScroll;
    Float64 oldTime;
    
    // AV
    JDAVPlayerManager* mAvPlayerManager;
    
    
    // Video properties
    int videoContentWidth, videoContentHeight;
    float videoMaximumZoomScale, videoMinimumZoomScale;
    bool video_is_playing;
    bool slider_is_registered;
    
    // Variables
    JDXMLParser* xmlParser;
    bool should_resume_on_play;
    bool songs_hidden;
    NSURL* song_selection;
    bool bounding_boxes_visible;
    bool musician_info_open;
    
    
    
    NSMutableArray *musicians;
    NSMutableArray* musicianNames;
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

-(void)setSongSelection:(NSURL*)song;
-(void)callVideoScrolledOrZoomed;
-(void)handleMusicianLongPress;
-(void)enableUi;
-(void)setPlayerForPlaybackView:(AVPlayer*)player;



@end
