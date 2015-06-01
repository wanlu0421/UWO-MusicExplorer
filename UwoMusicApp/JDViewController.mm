//
//  JDViewController.m
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-05-19.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDViewController.h"
//#import <MediaPlayer/MediaPlayer.h>

@interface JDViewController ()

@end

@implementation JDViewController

static const NSString *PlayerReadyContext = @"PLAYERREADYCONTEXT";

-(void)setSongSelection:(NSURL *)song {
    song_selection = song;
    [[JDStatisticsLogger loggerInstance] logSongSelection:[song absoluteString]];
    [[JDStatisticsLogger loggerInstance] serializeToJson];
    
}

- (void)viewDidLoad
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    //song_selection = @"legacy";
    video_is_playing = false;
    slider_is_registered = false;

    musician_info_open = false;

    [self setUpView];
    
    
    
    
    // Set up the video properties. This will eventually be taken from an XML file.
    videoContentHeight = 960;
    videoContentWidth = 1280;
    videoMaximumZoomScale = 5.0;
    videoMinimumZoomScale = 1.0;
    
    scrollView.contentSize = CGSizeMake(videoContentWidth, videoContentHeight);
    scrollView.minimumZoomScale = videoMinimumZoomScale;
    scrollView.maximumZoomScale = videoMaximumZoomScale;
    scrollView.delegate = (id)self;
    
    playButton.enabled = NO;
    pauseButton.enabled = NO;
    stopButton.enabled = NO;
    timeSlider.enabled = NO;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpView {
    
    [self parseXMLData:song_selection];
    [self setUpAVManager];
    NSMutableArray* items = [NSMutableArray array];
    [items addObject:playButton];
    [items addObject:playStopSpacer];
    [items addObject:stopButton];
    [items addObject:stopSliderSpacer];
    [items addObject:timeSliderBarItem];

    
    toolBar.items = items;
    
    
    /* This player view must be used to place each individual hidden button
     for the instrumentalists. It allows the buttons to be dragged and scaled
     correctly with the video.
     */
    
    musicians = [self createMusicianButtons];
    musicianNames = [[NSMutableArray alloc] init];
    
    
    
    // Add all musician buttons to the screen
    for (JDMusicianButton* button in musicians) {
        [musicianNames addObject: [button label]];
        [mPlaybackView addSubview:button];
        [button setBackgroundColor:[UIColor clearColor]];
        [button setAlpha:0.6f];
        [mPlaybackView bringSubviewToFront:button];
    }
}

-(void)parseXMLData:(NSURL*)url {
    NSXMLParser* nsXmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    xmlParser = [[JDXMLParser alloc] initJDXMLParser];
    
    [nsXmlParser setDelegate:xmlParser];
    BOOL success = [nsXmlParser parse];
    
    if(!success) {
        NSLog(@"Error parsing document: %@", [[nsXmlParser parserError] localizedDescription]);
    }
}

-(void)setUpAVManager {
    NSURL* videoURl = [[song_selection URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", xmlParser.videoTrackInfo.file, xmlParser.videoTrackInfo.extension]];
    
    mAvPlayerManager = [[JDAVPlayerManager alloc]
                        initWithVideo:videoURl
                        AudioTracksInfo:xmlParser.audioTracksInfo ViewController:self];
    
    
    // Add observer so we know when to enable buttons/slider
//    [[mAvPlayerManager playerItem] addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:&PlayerReadyContext];
    
//    [mAvPlayerManager createPlayer];
}

-(void)setPlayerForPlaybackView:(AVPlayer *)player {
    [mPlaybackView setPlayer:player];
    [mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
}



- (NSMutableArray*)createMusicianButtons {
    // Invisible buttons used on scroll view.
    NSMutableArray *temp_musicians = [[NSMutableArray alloc] init];
    
    for (id audioTrack in xmlParser.audioTracksInfo) {
        JDAudioTrackInfo* ati = (JDAudioTrackInfo*)audioTrack;
        JDMusicianButton *tempButton = [[JDMusicianButton alloc] initWithLabel:ati.file];
        [tempButton setFrame:CGRectMake([ati.x intValue],
                                        [ati.y intValue],
                                        [ati.width intValue],
                                        [ati.height intValue])];
        [tempButton registerDoubleTapMute:mAvPlayerManager VideoViewController:self];
        [tempButton registerLongPress:self
                       audioTrackInfo:ati
                            infoLabel:musicianLabel
                             infoText:musicianText];
        [temp_musicians addObject:tempButton];
    }
    
    
    return temp_musicians;

}


- (void)playVideo {
    [mAvPlayerManager play];
    video_is_playing = true;
}

- (void)pauseVideo {
    [mAvPlayerManager pause];
    video_is_playing = false;
}

- (void)stopVideo {
    [mAvPlayerManager stop];
    video_is_playing = false;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return mPlaybackView;
}

-(void)scrollViewDidZoom:(UIScrollView*)inScrollView {
    [self videoScrolledOrZoomed:inScrollView];
}

-(void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    CGFloat scale = 1.0 / scrollView.zoomScale;
    
    beforeScroll = CGRectMake(scrollView.contentOffset.x * scale,
                                    scrollView.contentOffset.y * scale,
                                    scrollView.bounds.size.width * scale,
                                    scrollView.bounds.size.height * scale);
}

-(void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat scale = 1.0 / scrollView.zoomScale;
    
    CGRect afterScroll = CGRectMake(scrollView.contentOffset.x * scale,
                                     scrollView.contentOffset.y * scale,
                                     scrollView.bounds.size.width * scale,
                                     scrollView.bounds.size.height * scale);
    
    [[JDStatisticsLogger loggerInstance]
     logVideoPannedStartX:@(beforeScroll.origin.x)
     StartY:@(beforeScroll.origin.y)
     EndX:@(afterScroll.origin.x)
     EndY:@(afterScroll.origin.y)];
}

-(void)scrollViewDidScroll:(UIScrollView*)inScrollView {
    [self videoScrolledOrZoomed:inScrollView];
}

-(void)videoScrolledOrZoomed:(UIScrollView*)inScrollView {
    // Get the rectangle representing the current portion of the video
    // viewable in the scroll view.
    CGFloat scale = 1.0 / inScrollView.zoomScale;
    
    CGRect currentView = CGRectMake(inScrollView.contentOffset.x * scale,
                                     inScrollView.contentOffset.y * scale,
                                     inScrollView.bounds.size.width * scale,
                                     inScrollView.bounds.size.height * scale);
    
    NSMutableArray* newVolumes = [[NSMutableArray alloc] init];
    // Find the instruments that intersect the current view.

    for (int i = 0; i < [musicians count]; i++) {
        UIButton *button = (UIButton*)musicians[i];
        bool intersects = CGRectIntersectsRect(currentView, button.frame);
        if(intersects) {
            CGRect intersectingRect = CGRectIntersection(currentView, button.frame);
            CGFloat intersectingSize = intersectingRect.size.width * intersectingRect.size.height;
            CGFloat originalRectsize = button.frame.size.width * button.frame.size.height;
            CGFloat newVolume = intersectingSize / originalRectsize;
            [newVolumes addObject:@(newVolume)];
        } else {
            [newVolumes addObject:@(0.0f)];
        }
    }
    
    [mAvPlayerManager changeAudioVolumes:newVolumes TrackNames:musicianNames];
    
    
}
- (IBAction)playButtonPressed:(id)sender {
    [[JDStatisticsLogger loggerInstance] logPlay];
    if(!video_is_playing)
        [self playVideo];
    
    NSMutableArray* items = [NSMutableArray array];
    [items addObject:pauseButton];
    [items addObject:playStopSpacer];
    [items addObject:stopButton];
    [items addObject:stopSliderSpacer];
    [items addObject:timeSliderBarItem];

    
    toolBar.items = items;
    
    NSString *str1;
    int timenum1 = [mAvPlayerManager durationInSeconds] / 60;
    int timenum2 = int([mAvPlayerManager durationInSeconds]) % 60;
    str1 = [NSString stringWithFormat:@"00:00/%d:%d",timenum1,timenum2];
    timelabel.text = str1;
}

- (IBAction)pauseButtonPressed:(id)sender {
    [[JDStatisticsLogger loggerInstance] logPause];
    if(video_is_playing)
        [self pauseVideo];
    
    NSMutableArray* items = [NSMutableArray array];
    [items addObject:playButton];
    [items addObject:playStopSpacer];
    [items addObject:stopButton];
    [items addObject:stopSliderSpacer];
    [items addObject:timeSliderBarItem];

    
    toolBar.items = items;
}

- (IBAction)stopButtonPressed:(id)sender {
    [self stopVideo];
    [[JDStatisticsLogger loggerInstance] logStop];
    
    NSMutableArray* items = [NSMutableArray array];
    [items addObject:playButton];
    [items addObject:playStopSpacer];
    [items addObject:stopButton];
    [items addObject:stopSliderSpacer];
    [items addObject:timeSliderBarItem];

    
    toolBar.items = items;
}

-(void)callVideoScrolledOrZoomed {
    [self videoScrolledOrZoomed:scrollView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == &PlayerReadyContext) {
        AVPlayerItem* playerItem = [mAvPlayerManager playerItem];
    
        if (object == playerItem && [keyPath isEqualToString:@"status"]) {
            if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
                playButton.enabled = YES;
                pauseButton.enabled = YES;
                stopButton.enabled = YES;
                timeSlider.enabled = YES;
            
                if(!slider_is_registered) {
                    [mAvPlayerManager registerTimeSlider:timeSlider];
                    slider_is_registered = true;
                }
            } else if (playerItem.status == AVPlayerStatusFailed) {
                NSLog(@"AVPlayerItem status is failed.");
            }
        }
    }
}

-(void)enableUi {
    playButton.enabled = YES;
    pauseButton.enabled = YES;
    stopButton.enabled = YES;
    timeSlider.enabled = YES;
    
    if(!slider_is_registered) {
        [mAvPlayerManager registerTimeSlider:timeSlider];
        slider_is_registered = true;
    }

}


- (IBAction)beginSliderChange:(id)sender {
    oldTime = [mAvPlayerManager durationInSeconds] * timeSlider.value;
    [mAvPlayerManager unregisterTimeSlider];
    slider_is_registered = false;
}

- (IBAction)endSliderChange:(id)sender {
    Float64 newTime = [mAvPlayerManager durationInSeconds] * timeSlider.value;
    [mAvPlayerManager seekToTimeSeconds:newTime];
    [mAvPlayerManager registerTimeSlider:timeSlider];
    slider_is_registered = true;
    [[JDStatisticsLogger loggerInstance]
     logVideoTimelineSeekStartTime:[NSString stringWithFormat:@"%lf",oldTime]
     EndTime:[NSString stringWithFormat:@"%lf",newTime]];
}

- (IBAction)cancelSliderChange:(id)sender {
    [mAvPlayerManager registerTimeSlider:timeSlider];
    slider_is_registered = true;
}



-(void) viewWillDisappear:(BOOL)animated {
//    if([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
    
//        [[mAvPlayerManager playerItem] removeObserver:self forKeyPath:@"status"];
    for(JDMusicianButton* button in musicians) {
            [button deregisterLongPress];
            [button deregisterDoubleTapMute];
    }
        [mAvPlayerManager unregisterTimeSlider];
    [mAvPlayerManager removeObservers];
        mAvPlayerManager = nil;
//    }
    
    [super viewWillDisappear:animated];
}

-(void)handleMusicianLongPress
{
    // For now also make musician button appear and disappear
    NSLog(@"Long pressed being handled");
    [UIView animateWithDuration:0.2 animations:^{
        if(!musician_info_open) {
            musicianInfoView.frame = CGRectMake(musicianInfoView.frame.origin.x,
                                                musicianInfoView.frame.origin.y - musicianInfoView.frame.size.height, musicianInfoView.frame.size.width, musicianInfoView.frame.size.height);
            musician_info_open = true;
        }
    }];

}


- (IBAction)handleMusicianInfoClose:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        if(musician_info_open) {
            musicianInfoView.frame = CGRectMake(musicianInfoView.frame.origin.x,
                                                musicianInfoView.frame.origin.y +musicianInfoView.frame.size.height, musicianInfoView.frame.size.width, musicianInfoView.frame.size.height);
            musician_info_open = false;
        }
    }];
}




@end
