//
//  JDAudioDescriptorRestModel.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDAudioDescriptorRestModel.h"

@implementation JDAudioDescriptorRestModel

+(RKObjectMapping*)getObjectMapping {
    RKObjectMapping* audioMapping = [RKObjectMapping mappingForClass:[JDAudioDescriptorRestModel class]];
    [audioMapping addAttributeMappingsFromDictionary:[JDAudioDescriptorRestModel getMappings]];
    
    return audioMapping;
}

+(NSDictionary*)getMappings {
    return @{
             @"id" : @"audioId",
             @"index" : @"index",
             @"file" : @"file",
             @"extension" : @"extension",
             @"trackOffset" : @"trackOffset",
             @"name" : @"name",
             @"description" : @"description",
             @"x" : @"x",
             @"y" : @"y",
             @"width" : @"width",
             @"height" : @"height"
             };
}
@end
