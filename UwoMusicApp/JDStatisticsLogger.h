//
//  JDStatisticsLogger.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-01-23.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDStatisticsLogger : NSObject
{
    NSURL* documentsUrl;
    NSString* fileName;
    NSDateFormatter* dateFormatter;
    
    // JSON Hierarchy
    NSMutableArray* topLevelArray;
    NSMutableDictionary* jsonDict;
    NSData* json;
}

@property(nonatomic) NSURL* documentsUrl;
@property(nonatomic) NSString* fileName;
@property(nonatomic) NSMutableDictionary* jsonDict;
@property(nonatomic) NSDateFormatter* dateFormatter;
@property(nonatomic) NSData* json;

+(id)loggerInstance;

-(void)setLogFileName:(NSString*)fileName;
-(void)generateFileName;
-(void)logSongSelection:(NSString*)song;
-(void)logMute:(BOOL)muted Musician:(NSString*)musician;
-(void)logVideoPannedStartX:(NSNumber*)startX StartY:(NSNumber*)startY EndX:(NSNumber*)endX EndY:(NSNumber*)endY;
-(void)logVideoZoomedStartX:(NSNumber*)startX StartY:(NSNumber*)startY EndX:(NSNumber*)endX EndY:(NSNumber*)endY;
-(void)logVideoTimelineSeekStartTime:(NSString*)startTime EndTime:(NSString*)endTime;
-(void)logPlay;
-(void)logPause;
-(void)logStop;
-(void)logOpenVideo;
-(void)logCloseVideo;
-(void)logMusicianInfoOpenedForMusician:(NSString*)musician;

-(NSString*)serializeToJson;
-(void)dumpToFile;

@end
