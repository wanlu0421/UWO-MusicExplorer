//
//  JDStoreSongDetailsViewController.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-03-05.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDStoreSongDetailsViewController.h"

@interface JDStoreSongDetailsViewController ()

@end

@implementation JDStoreSongDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [titleLabel setText:song.title];
    [artistLabel setText:song.artist];
    [genreLabel setText:song.genre];
    [downloadIndicator setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setSongSelection:(JDSongDescriptorRestModel *)songSelection {
    song = songSelection;
}
- (IBAction)downloadButtonClicked:(id)sender {
    // Download song file
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString* propsPath = [[NSBundle mainBundle] pathForResource:@"application" ofType:@"plist"];
                       NSDictionary* props = [[NSDictionary alloc] initWithContentsOfFile:propsPath];
                       NSString* urlString = [NSString stringWithFormat:@"%@/%@", props[@"apiUrl"], song.fileUrl];
                       NSString* descFileUrlString = [NSString stringWithFormat:@"%@/%@", props[@"apiUrl"], song.descriptorUrl];
                       NSLog(@"Downloading %@ - URL: %@", song.title, urlString);
                       
                       
                       // Must dispatch main queue to make UI changes to indicator and download button
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [downloadIndicator setHidden:NO];
                           [downloadButton setEnabled:NO];
                           [downloadButton setTitle:@"Downloading..." forState:UIControlStateDisabled];
                       });
                       
                       
                       NSURL* videoUrl = [NSURL URLWithString:urlString];
                       NSURL* descriptorUrl = [NSURL URLWithString:descFileUrlString];
                       NSData* videoData = [NSData dataWithContentsOfURL:videoUrl];
                       NSData* descriptorData = [NSData dataWithContentsOfURL:descriptorUrl];
                       if(videoData && descriptorData) {
                           // Do download if available
                           NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                           NSString* documentsDir = [paths objectAtIndex:0];
                           CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
                           NSString* uniquePath = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuid);
                           NSString* videoFilePath = [NSString stringWithFormat:@"%@/%@/%@", documentsDir, uniquePath, song.fileUrl];
                           NSString* descriptorFilePath = [NSString stringWithFormat:@"%@/%@/%@", documentsDir, uniquePath, song.descriptorUrl];
                           NSLog(@"Saving in: %@/%@", documentsDir, uniquePath);
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               NSString* newFolderPath = [NSString stringWithFormat:@"%@/%@", documentsDir, uniquePath];
                               [[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
                               [videoData writeToFile:videoFilePath atomically:YES];
                               [descriptorData writeToFile:descriptorFilePath atomically:YES];
                               NSLog(@"Video File Saved!");
                               [downloadIndicator setHidden:YES];
                               [downloadButton setEnabled:YES];
                               [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
                               NSString* completeMessage = [NSString stringWithFormat:@"Your song '%@' has finished downloading.", song.title];
                               [[[UIAlertView alloc] initWithTitle:@"Download complete."
                                                          message:completeMessage
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil, nil] show];
                           });
                       } else {
                           // Else re-eneable downloading button
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [downloadIndicator setHidden:YES];
                               [downloadButton setEnabled:YES];
                               [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
                           });
                       }
                   });
}

- (IBAction)streamButtonClicked:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Sorry..." message:@"This feature is not currently available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
