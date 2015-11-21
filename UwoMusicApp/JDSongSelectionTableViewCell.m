//
//  JDTableViewCell.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-01-14.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDSongSelectionTableViewCell.h"
#import "JDXMLParser.h"
#import <AVFoundation/AVFoundation.h>

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
     if(error){
         NSLog(@"There exist an error when trying to get the image：%@",error.localizedDescription);
     }
    return image;
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
    NSURL* videoURl = [[[self getUrl] URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",xmlParser.videoTrackInfo.file, xmlParser.videoTrackInfo.extension]];

    self.textLabel.text = [NSString stringWithFormat:@"%@", xmlParser.title];

    self.detailTextLabel.text = [NSString stringWithFormat:@"Performer: %@   Genre: %@", xmlParser.artist, xmlParser.genre ];

    UIImage *image = [self imageWithMediaURL:videoURl];
    self.imageView.image = image;
    
}

- (NSURL*)getUrl
{
    return fileUrl;
}

@end
