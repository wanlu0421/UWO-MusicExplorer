//
//  JDTableViewCell.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-01-14.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDVideoTrackInfo.h"

@interface JDSongSelectionTableViewCell : UITableViewCell
{
    NSURL* fileUrl;
   
}

- (id)initWithFileUrl:(NSURL*)url stlye:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier;


- (NSURL*)getUrl;

@end
