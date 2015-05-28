//
//  JDStoreSongSearchTableViewCell.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-03-05.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDSongDescriptorRestModel.h"

@interface JDStoreSongSearchTableViewCell : UITableViewCell
{
    JDSongDescriptorRestModel* song;
}

-(id)initWithSong:(JDSongDescriptorRestModel*)song reuseIdentifier:(NSString*)reuseIdentifier;

@end
