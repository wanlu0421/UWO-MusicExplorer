//
//  JDStoreViewController.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-03-05.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDSongDescriptorRestModel.h"
#import "JDStoreSongDetailsViewController.h"

@interface JDStoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    
    IBOutlet UITableView *searchTableView;
    JDSongDescriptorRestModel* songSelection;
}

@end
