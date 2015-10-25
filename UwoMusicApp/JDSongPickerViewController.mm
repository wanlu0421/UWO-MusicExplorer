//
//  JDSongPickerViewController.m
//  UwoMusicApp
//
//  Created by Justin Doyle on 9/16/2014.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDSongPickerViewController.h"
#import "JDSongSelectionTableViewCell.h"
#import "JDViewController.h"
//#import "JDNewsRestModel.h"
#import "JDSongDescriptorRestModel.h"
#import <RestKit/RestKit.h>
#import "JDOauth2TokenResponse.h"
#import <AVFoundation/AVFoundation.h>

//#define STORE_BUTTON_DIAMETER 75


@implementation JDSongPickerViewController

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
    // Get the latest news
/*    [JDNewsRestModel latestNewsArticleSuccess:
     ^(JDNewsRestModel* news){
         // Load the latest news into the news view
         NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
         [formatter setDateFormat:@"yyyy-MM-dd"];
         _newsTextView.text = [NSString stringWithFormat:@"%@\n%@\n\n%@", news.title, news.publishedAt, news.body];
         
    } Failure:
     ^(NSError* error){
        _newsTextView.text = @"Could not connect to the news... Sorry!";
    }];
 */
    // This will be an array of NSString*
    songsToChooseFrom = [self findMchairsFiles];
//    [self setUpRoundedStoreButton];
    
    // Set navigation bar color
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.25 green:0 blue:0.5 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    
    // Reload mchairs songs
    songsToChooseFrom = [self findMchairsFiles];
    [songPickerTable reloadData];
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    // Reload mchairs songs
//    songsToChooseFrom = [self findMchairsFiles];
//    [songPickerTable reloadData];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear: (BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewDidDisappear:animated];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"songPush"]) {
        JDViewController* jdvc = (JDViewController*)[segue destinationViewController];
        [jdvc setSongSelection:songFileChoice];
    }
}

- (NSURL*)documentsDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* docDir = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        docDir = [possibleURLs objectAtIndex:0];
    }
    
    
    return docDir;
}

-(NSArray*)getSongsToChooseFrom { return songsToChooseFrom; }

-(NSArray*)findMchairsFiles {
    NSMutableArray* urls = [NSMutableArray array];
    NSURL* documents = [self documentsDirectory];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    NSArray* subdirs = [fileManager
                        contentsOfDirectoryAtURL:documents
                        includingPropertiesForKeys:nil
                        options:NSDirectoryEnumerationSkipsHiddenFiles
                        error:nil];
    
    for(NSString* s in subdirs) {
        NSArray* filesInSubdir = [fileManager contentsOfDirectoryAtPath:s error:nil];
        for(NSString* file in filesInSubdir) {
            if([file hasSuffix:@".mchairs"]) {
                [urls addObject:[NSString stringWithFormat:@"%@%@", s, file]];
            }
        }
    }
    
    
    return urls;
}

- (UIImage *)imageWithMediaURL:(NSURL *)url {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    // 初始化媒体文件
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    // 根据asset构造一张图
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    // 设定缩略图的方向
    // 如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的（自己的理解）
    generator.appliesPreferredTrackTransform = YES;
    // 设置图片的最大size(分辨率)
    generator.maximumSize = CGSizeMake(600, 450);
    // 初始化error
    NSError *error = nil;
    // 根据时间，获得第N帧的图片
    // CMTimeMake(a, b)可以理解为获得第a/b秒的frame
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10000) actualTime:NULL error:&error];
    // 构造图片
    UIImage *image = [UIImage imageWithCGImage: img];
    return image;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [songsToChooseFrom count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
        cell = [[JDSongSelectionTableViewCell alloc]
                initWithFileUrl:[NSURL URLWithString:[songsToChooseFrom objectAtIndex:indexPath.row]]
                stlye:UITableViewCellStyleDefault
                reuseIdentifier:simpleTableIdentifier];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    songFileChoice = [(JDSongSelectionTableViewCell*)[tableView cellForRowAtIndexPath:indexPath]getUrl];
    
    [self performSegueWithIdentifier:@"songPush" sender:nil];
}

/*- (void)setUpRoundedStoreButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(820, 100, STORE_BUTTON_DIAMETER, STORE_BUTTON_DIAMETER);
    button.clipsToBounds = YES;
    button.layer.cornerRadius = STORE_BUTTON_DIAMETER/2.0f;
    button.layer.backgroundColor = [UIColor colorWithRed:1 green:0.341 blue:0.133 alpha:1].CGColor;
    button.layer.borderColor = [UIColor colorWithRed:1 green:0.341 blue:0.133 alpha:1].CGColor;
    button.layer.borderWidth = 2.0f;
    [button setTitle:@"Store" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(roundButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [_mainMenuView addSubview:button];
}

-(void)roundButtonDidTap:(UIButton*)tappedButton{
    
//    [self performSegueWithIdentifier:@"storePush" sender:nil];
}
*/

@end
