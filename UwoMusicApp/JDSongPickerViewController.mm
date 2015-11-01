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
    instruction_info_open = false;
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
- (IBAction)howtousebuttonpressed:(id)sender {
    NSLog(@"How to use button pressed");
    [UIView animateWithDuration:0.2 animations:^{
        if(!instruction_info_open) {
            instruction.frame = CGRectMake(instruction.frame.origin.x,
                                                instruction.frame.origin.y - instruction.frame.size.height, instruction.frame.size.width, instruction.frame.size.height);
            instruction_info_open = true;
        }
    }];
}
- (IBAction)gotitbuttonpressed:(id)sender {
    [UIView animateWithDuration:0.2 animations:^{
        if(instruction_info_open) {
            instruction.frame = CGRectMake(instruction.frame.origin.x,
                                                instruction.frame.origin.y +instruction.frame.size.height, instruction.frame.size.width, instruction.frame.size.height);
            instruction_info_open = false;
        }
    }];
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
