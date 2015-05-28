//
//  JDTableViewCell.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-01-14.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDSongSelectionTableViewCell.h"
#import "JDXMLParser.h"

@implementation JDSongSelectionTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFileUrl:(NSURL*)url stlye:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        fileUrl = url;
        [self setCellDisplaySongName];
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

-(void)setCellDisplaySongName
{
    NSXMLParser* nsXmlParser = [[NSXMLParser alloc] initWithContentsOfURL:fileUrl];
    
    JDXMLParser* xmlParser = [[JDXMLParser alloc] initJDXMLParser];
    [nsXmlParser setDelegate:xmlParser];
    BOOL success = [nsXmlParser parse];
    
    if(!success) {
        NSLog(@"Error parsing document: %@", [[nsXmlParser parserError] localizedDescription]);
        self.textLabel.text =  @"ERROR GETTING NAME";
        return;
    }
    
    self.textLabel.text = [NSString stringWithFormat:@"%@ - %@", xmlParser.artist, xmlParser.title];
}

- (NSURL*)getUrl
{
    return fileUrl;
}

@end
