//
//  JDVideoDescriptorRestModel.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDVideoDescriptorRestModel.h"

@implementation JDVideoDescriptorRestModel

+(RKObjectMapping*)getObjectMapping {
    RKObjectMapping* videoMapping = [RKObjectMapping mappingForClass:[JDVideoDescriptorRestModel class]];
    [videoMapping addAttributeMappingsFromDictionary:[JDVideoDescriptorRestModel getMappings]];
    
    return videoMapping;
}

+(NSDictionary*)getMappings {
    return @{
             @"id" : @"videoId",
             @"file" : @"file",
             @"extension" : @"extension",
             @"startTime" : @"startTime",
             @"maxZoom" : @"maxZoom"
             };
}
@end
