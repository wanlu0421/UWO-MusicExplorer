//
//  JDSongPickerViewController.h
//  UwoMusicApp
//
//  Created by Justin Doyle on 9/16/2014.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface JDSongPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@private
    NSArray* songsToChooseFrom;
    NSURL* songFileChoice;
    IBOutlet UITableView *songPickerTable;
    
}
@property (weak, nonatomic) IBOutlet UINavigationItem *navController;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;
@property (weak, nonatomic) IBOutlet UIView *mainMenuView;
@property (strong, nonatomic) IBOutlet UITextView *newsTextView;

-(NSArray*)getSongsToChooseFrom;

@end
