//
//  JDNewsRestModel.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-18.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>



@interface JDNewsRestModel : NSObject

@property(nonatomic, copy) NSNumber* newsId;
@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* body;
@property(nonatomic, copy) NSString* titleId;
@property(nonatomic) NSDate* publishedAt;

+(NSDictionary*)getMappings;
+(RKObjectMapping*)getObjectMapping;
+(void)latestNewsArticleSuccess:(void (^)(JDNewsRestModel* news)) success Failure:(void (^)(NSError* error)) failure;
@end
