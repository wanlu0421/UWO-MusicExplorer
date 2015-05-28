//
//  JDSongDescriptorRestModel.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDSongDescriptorRestModel.h"

@class JDVideoDescriptorRestModel;
@class JDAudioDescriptorRestModel;

@implementation JDSongDescriptorRestModel

+(void)allSongsSuccess:(void (^)(NSArray *))success Failure:(void (^)(NSError *))failure {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/api/songs"
                                           parameters:nil
                                              success:^(RKObjectRequestOperation* operation, RKMappingResult* result){
                                                  success([result array]);
                                              }
                                              failure:^(RKObjectRequestOperation* operation, NSError* error) {
                                                  failure(error);
                                              }
     ];
}

+(void)searchSongsTitle:(NSString *)title Artist:(NSString *)artist Genre:(NSString *)genre Success:(void (^)(NSArray *))success Failure:(void (^)(NSError *))failure {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:3];
    if(title)
        params[@"t"] = title;
    if(artist)
        params[@"a"] = artist;
    if(genre)
        params[@"g"] = genre;
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/api/songs/search"
                                           parameters:params
                                              success:^(RKObjectRequestOperation* operation, RKMappingResult* result) {
                                                  success([result array]);
                                              }
                                              failure:^(RKObjectRequestOperation* operation, NSError* error) {
                                                  failure(error);
                                              }];
}



+(RKObjectMapping*)getObjectMapping {
    // Video field mapping
    RKObjectMapping* videoMapping = [JDVideoDescriptorRestModel getObjectMapping];
    
    // Audio array field mapping
    RKObjectMapping* audioMapping = [JDAudioDescriptorRestModel getObjectMapping];
    
    // Now set up mapping for song descriptors
    RKObjectMapping* songMapping = [RKObjectMapping mappingForClass:[JDSongDescriptorRestModel class]];
    [songMapping addAttributeMappingsFromDictionary:[JDSongDescriptorRestModel getMappings]];
    [songMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"video" toKeyPath:@"video" withMapping:videoMapping]];
    [songMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"audio" toKeyPath:@"audio" withMapping:audioMapping]];
    
    return songMapping;
    
}

+(NSDictionary*)getMappings {
    // Leave out video and audio, since they are taken care of with relationship mapping
    return @{@"id" : @"songId",
             @"fileUrl" : @"fileUrl",
             @"descriptorUrl" : @"descriptorUrl",
             @"title" : @"title",
             @"artist" : @"artist",
             @"genre" : @"genre",
             @"globalAudioOffset" : @"globalAudioOffset",
             @"audioTrackCount" : @"audioTrackCount"};
}

-(NSString*)description {
    return [NSString stringWithFormat:@"Title: %@\n"
            "Artist: %@\n"
            "Genre: %@\n"
            "URL: %@", self.title,self.artist,self.genre,self.fileUrl];
}
@end
