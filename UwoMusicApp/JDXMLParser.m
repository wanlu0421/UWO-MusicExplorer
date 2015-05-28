//
//  JDXMLParser.m
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-07-11.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDXMLParser.h"
#import "JDAudioTrackInfo.h"
#import "JDVideoTrackInfo.h"

@implementation JDXMLParser

@synthesize title, artist, genre, totalOffset, trackCount, videoTrackInfo, audioTracksInfo;

-(JDXMLParser*) initJDXMLParser {
    self = [super init];
    
    if(self != nil) {
        audioTracksInfo = [[NSMutableArray alloc] init];
        insideVideo = NO;
        insideAudio = NO;
    }
    return self;
}


-(void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    
    if([elementName isEqualToString:@"video"]) {
        videoTrackInfo = [[JDVideoTrackInfo alloc] init];
        insideVideo = YES;
    }
    else if ([elementName isEqualToString:@"audio"]) {
        insideAudio = YES;
    }
    else if([elementName isEqualToString:@"track"]) {
        tempAudioTrackInfo = [[JDAudioTrackInfo alloc] init];
    }
}

-(void)parser:(NSXMLParser *)parser
    foundCharacters:(NSString *)string {
    
    //if(!currentElementValue)
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    //else {
    //    [currentElementValue appendString:string];
    //}
}

-(void)parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName {
    
    if([elementName isEqualToString:@"info"])
        return;
    
    if([elementName isEqualToString:@"video"]) {
    }
    else if([elementName isEqualToString:@"audio"]) {
    }
    else if([elementName isEqualToString:@"track"]) {
        [audioTracksInfo addObject:tempAudioTrackInfo];
        tempAudioTrackInfo = nil;
    }
    else if([elementName isEqualToString:@"title"]) {
        title = currentElementValue;
    }
    else if([elementName isEqualToString:@"artist"]) {
        artist = currentElementValue;
    }
    else if([elementName isEqualToString:@"genre"]) {
        genre = currentElementValue;
    }
    else if([elementName isEqualToString:@"offset"] && insideAudio) {
        totalOffset = [self getNumber:currentElementValue];
    }
    else if([elementName isEqualToString:@"track_count"] && insideAudio) {
        trackCount = [self getNumber:currentElementValue];
    }
    else if([elementName isEqualToString:@"file"] && insideAudio) {
        [tempAudioTrackInfo setFile:currentElementValue];
    }
    else if([elementName isEqualToString:@"extension"] && insideAudio) {
        [tempAudioTrackInfo setExtension:currentElementValue];
    }
    else if([elementName isEqualToString:@"trackoffset"] && insideAudio) {
        [tempAudioTrackInfo setOffset:[self getNumber:currentElementValue]];
    }
    else if([elementName isEqualToString:@"start_range"] && insideAudio) {
        [tempAudioTrackInfo setHasStartRange:YES];
        [tempAudioTrackInfo setStartRange:[self getNumber:currentElementValue]];
    }
    else if([elementName isEqualToString:@"name"] && insideAudio) {
        [tempAudioTrackInfo setName:currentElementValue];
    }
    else if([elementName isEqualToString:@"x"] && insideAudio) {
        [tempAudioTrackInfo setX:[self getNumber:currentElementValue]];
    }
    else if([elementName isEqualToString:@"y"] && insideAudio) {
        [tempAudioTrackInfo setY:[self getNumber:currentElementValue]];
    }
    else if([elementName isEqualToString:@"width"] && insideAudio) {
        [tempAudioTrackInfo setWidth:[self getNumber:currentElementValue]];
    }
    else if([elementName isEqualToString:@"height"] && insideAudio) {
        [tempAudioTrackInfo setHeight:[self getNumber:currentElementValue]];
    }
    else if([elementName isEqualToString:@"description"] && insideAudio) {
        [tempAudioTrackInfo setDescription:currentElementValue];
    }
    else if([elementName isEqualToString:@"file"] && insideVideo) {
        [videoTrackInfo setFile:currentElementValue];
    }
    else if([elementName isEqualToString:@"extension"] && insideVideo) {
        [videoTrackInfo setExtension:currentElementValue];
    }
    else if([elementName isEqualToString:@"start_time"] && insideVideo) {
        [videoTrackInfo setStartTime:currentElementValue];
    }

}

-(NSNumber*)getNumber:(NSString*)string {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

@end
