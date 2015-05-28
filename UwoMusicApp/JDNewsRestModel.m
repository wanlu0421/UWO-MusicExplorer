//
//  JDNewsRestModel.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-18.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDNewsRestModel.h"
#import <RestKit/RestKit.h>
#import <ISO8601DateFormatterValueTransformer/RKISO8601DateFormatter.h>


@implementation JDNewsRestModel

+(NSDictionary*)getMappings {
    return @{@"id" : @"newsId",
             @"title" : @"title",
             @"body" : @"body",
             @"titleId" : @"titleId",
             @"publishedAt" : @"publishedAt"};
}

+(RKObjectMapping*)getObjectMapping {
    RKObjectMapping* newsMapping = [RKObjectMapping mappingForClass:[JDNewsRestModel class]];
    [newsMapping addAttributeMappingsFromDictionary:[JDNewsRestModel getMappings]];
    
    return newsMapping;
}
+(void)latestNewsArticleSuccess:(void (^)(JDNewsRestModel* news)) success Failure:(void (^)(NSError* error)) failure {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/api/news/latest" parameters:nil
                      success:^(RKObjectRequestOperation* operation, RKMappingResult* result){
                          
                          JDNewsRestModel* news = [result firstObject];
                          // Now call passed in block
                          success(news);
                      }
                      failure:^(RKObjectRequestOperation* operation, NSError* error){
                          failure(error);
                      }];
}
@end
