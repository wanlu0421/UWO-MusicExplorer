//
//  JDStatisticsLogger.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-01-23.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDStatisticsLogger.h"

@implementation JDStatisticsLogger

@synthesize documentsUrl, jsonDict, fileName, dateFormatter, json;

+(id)loggerInstance {
    static JDStatisticsLogger* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(id)init {
    if (self = [super init]) {
        // Do class setup here
        documentsUrl = [self documentsDirectory];
        topLevelArray = [[NSMutableArray alloc] initWithCapacity:1];
        jsonDict = [[NSMutableDictionary alloc] initWithCapacity:100];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    return self;
}

-(void)setLogFileName:(NSString *)fileName {
    self.fileName = fileName;
}

-(void)generateFileName {
    self.fileName = [NSUUID UUID].UUIDString;
}

- (NSURL*)documentsDirectory {
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* docDir = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        docDir = [possibleURLs objectAtIndex:0];
    }
    
    
    return docDir;
}

-(NSString*)dateTimeAsString {
    NSDate* date = [NSDate date];
    return [dateFormatter stringFromDate:date];
}

-(void)logSongSelection:(NSString *)song {
    NSDictionary* d = @{@"songSelection": song};
    jsonDict[[self dateTimeAsString]] = d;
}

-(void)logMute:(BOOL)muted Musician:(NSString *)musician {
    NSDictionary* d = @{@"muteAction": muted ? @"muted" : @"unmuted",
                        @"musician": musician};
    jsonDict[[self dateTimeAsString]] = d;
}

-(void)logVideoPannedStartX:(NSNumber *)startX StartY:(NSNumber *)startY EndX:(NSNumber *)endX EndY:(NSNumber *)endY {
    NSDictionary* d = @{@"panStartX": startX,
                        @"panStartY": startY,
                        @"panEndX": endX,
                        @"panEndY": endY};
    jsonDict[[self dateTimeAsString]] = d;
}

-(void)logVideoZoomedStartX:(NSNumber *)startX StartY:(NSNumber *)startY EndX:(NSNumber *)endX EndY:(NSNumber *)endY {
    NSDictionary* d = @{@"zoomStartX": startX,
                        @"zoomStartY": startY,
                        @"zoomEndX": endX,
                        @"zoomEndY": endY};
    jsonDict[[self dateTimeAsString]] = d;
}

-(void)logVideoTimelineSeekStartTime:(NSString *)startTime EndTime:(NSString *)endTime {
    NSDictionary* d = @{@"seekStart": startTime,
                        @"seekEnd": endTime};
    jsonDict[[self dateTimeAsString]] = d;
}

-(void)logPlay {
    jsonDict[[self dateTimeAsString]] = @"playClicked";
}

-(void) logPause {
    jsonDict[[self dateTimeAsString]] = @"pauseClicked";
}

-(void)logStop {
    jsonDict[[self dateTimeAsString]] = @"stopClicked";
}

-(void)logOpenVideo {
    jsonDict[[self dateTimeAsString]] = @"openVideo";
}

-(void)logCloseVideo {
    jsonDict[[self dateTimeAsString]] = @"closeVideo";
}

-(void)logMusicianInfoOpenedForMusician:(NSString *)musician {
    NSDictionary* d = @{@"musicianOpened": musician};
    jsonDict[[self dateTimeAsString]] = d;
}


-(NSString*)serializeToJson {
    NSError* error;
    if ([NSJSONSerialization isValidJSONObject:jsonDict]) {
        json = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        
        if (json != nil && error == nil) {
            NSString* jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            
            NSLog(@"JSON: %@", jsonString);
            return jsonString;
        } else {
            return @"Error";
        }
    } else {
        return @"Error";
    }
}

-(void)dumpToFile {
    NSString* content = [self serializeToJson];
    NSFileManager* sharedFM = [NSFileManager defaultManager];
    NSArray* possibleURLs = [sharedFM URLsForDirectory:NSDocumentDirectory
                                             inDomains:NSUserDomainMask];
    NSURL* docDir = nil;
    
    if ([possibleURLs count] >= 1) {
        // Use the first directory (if multiple are returned)
        docDir = [possibleURLs objectAtIndex:0];
    } else {
        NSLog(@"Error: Documents folder not found");
    }
    
    NSDateFormatter *formatter;
    NSString *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString* filePath = [[docDir path] stringByAppendingPathComponent:dateString];
    filePath = [filePath stringByAppendingPathExtension:@"json"];
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"FILE TO WRITE: %@", filePath);
}

@end
