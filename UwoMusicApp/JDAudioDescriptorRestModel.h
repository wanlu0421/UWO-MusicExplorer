//
//  JDAudioDescriptorRestModel.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface JDAudioDescriptorRestModel : NSObject

@property(nonatomic, copy) NSNumber* audioId;
@property(nonatomic, copy) NSNumber* index;
@property(nonatomic, copy) NSString* file;
@property(nonatomic, copy) NSString* extension;
@property(nonatomic, copy) NSNumber* trackOffset;
@property(nonatomic, copy) NSString* name;
@property(nonatomic, copy) NSString* description;
@property(nonatomic, copy) NSNumber* x;
@property(nonatomic, copy) NSNumber* y;
@property(nonatomic, copy) NSNumber* width;
@property(nonatomic, copy) NSNumber* height;

+(RKObjectMapping*)getObjectMapping;
+(NSDictionary*)getMappings;
@end
