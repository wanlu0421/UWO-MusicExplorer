//
//  JDStoreSongSearchTableViewCell.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-03-05.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDStoreSongSearchTableViewCell.h"

@implementation JDStoreSongSearchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithSong:(JDSongDescriptorRestModel*)song reuseIdentifier:(NSString*)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self) {
        self->song = song;
        NSString* cellText = [NSString stringWithFormat:@"%@ - %@  Genre: %@", song.artist, song.title, song.genre];
        [self setText:cellText];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
