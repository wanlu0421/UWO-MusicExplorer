//
//  JDXMLParser.h
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-07-11.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JDAudioTrackInfo;
@class JDVideoTrackInfo;

@interface JDXMLParser : NSObject <NSXMLParserDelegate>
{
    NSMutableString* currentElementValue;
    NSString* title;
    NSString* artist;
    NSString* genre;
    NSNumber* totalOffset;
    NSNumber* trackCount;
    JDVideoTrackInfo* videoTrackInfo;
    JDAudioTrackInfo* tempAudioTrackInfo;
    NSMutableArray* audioTracksInfo;
    BOOL insideVideo;
    BOOL insideAudio;
    
}

@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) NSString* artist;
@property(nonatomic, retain) NSString* genre;
@property(nonatomic, retain) NSNumber* totalOffset;
@property(nonatomic, retain) NSNumber* trackCount;
@property(nonatomic, retain) JDVideoTrackInfo* videoTrackInfo;
@property(nonatomic, retain) NSMutableArray* audioTracksInfo;

-(JDXMLParser*) initJDXMLParser;

@end
