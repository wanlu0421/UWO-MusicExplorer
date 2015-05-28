//
//  JDVideoDescriptorRestModel.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface JDVideoDescriptorRestModel : NSObject

@property(nonatomic, copy) NSNumber* videoId;
@property(nonatomic, copy) NSString* file;
@property(nonatomic, copy) NSString* extension;
@property(nonatomic, copy) NSNumber* startTime;
@property(nonatomic, copy) NSNumber* maxZoom;

+(RKObjectMapping*)getObjectMapping;
+(NSDictionary*)getMappings;
@end
