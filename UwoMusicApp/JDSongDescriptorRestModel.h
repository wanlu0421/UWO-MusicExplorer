//
//  JDSongDescriptorRestModel.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "JDVideoDescriptorRestModel.h"
#import "JDAudioDescriptorRestModel.h"

@interface JDSongDescriptorRestModel : NSObject

@property(nonatomic, copy) NSNumber* songId;
@property(nonatomic, copy) NSString* fileUrl;
@property(nonatomic, copy) NSString* descriptorUrl;
@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* artist;
@property(nonatomic, copy) NSString* genre;
@property(nonatomic) JDVideoDescriptorRestModel* video;
@property(nonatomic, copy) NSNumber* globalAudioOffset;
@property(nonatomic, copy) NSNumber* audioTrackCount;
@property(nonatomic) NSArray* audio;

+(RKObjectMapping*)getObjectMapping;
+(NSDictionary*)getMappings;
+(void)allSongsSuccess:(void (^)(NSArray* songs))success Failure:(void(^)(NSError* error)) failure;
+(void)searchSongsTitle:(NSString*)title Artist:(NSString*)artist Genre:(NSString*)genre Success:(void(^)(NSArray* songs))success Failure:(void(^)(NSError* error)) failure;
@end
