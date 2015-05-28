//
//  JDStoreSongDetailsViewController.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-03-05.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JDSongDescriptorRestModel.h"

@interface JDStoreSongDetailsViewController : UIViewController
{
    JDSongDescriptorRestModel* song;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *artistLabel;
    IBOutlet UILabel *genreLabel;
    IBOutlet UIActivityIndicatorView *downloadIndicator;
    IBOutlet UIButton *downloadButton;
}

-(void)setSongSelection:(JDSongDescriptorRestModel*)songSelection;

@end
