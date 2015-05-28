//
//  JDOauth2TokenResponse.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDOauth2TokenResponse.h"

@implementation JDOauth2TokenResponse

+(NSDictionary*)getMappings {
    return @{
             @"access_token" : @"accessToken",
             @"token_type" : @"tokenType",
             @"refresh_token" : @"refreshToken",
             @"expires_in" : @"expiresIn",
             @"scope" : @"scope"
             };
}

+(RKObjectMapping*)getObjectMapping {
    RKObjectMapping* tokenMapping = [RKObjectMapping mappingForClass:[JDOauth2TokenResponse class]];
    [tokenMapping addAttributeMappingsFromDictionary:[JDOauth2TokenResponse getMappings]];
    return tokenMapping;
}

+(void)getTokenUsername:(NSString*)username Password:(NSString*)password Success:(void (^)(JDOauth2TokenResponse *))success Failure:(void (^)(NSError *))failure {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"application" ofType:@"plist"];
    NSDictionary* props = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSString* apiKey = props[@"apiKey"];
    NSString* apiSecret = props[@"apiSecret"];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/oauth/token"
                                           parameters:@{@"password": password,
                                                        @"username" : username,
                                                        @"grant_type" : @"password",
                                                        @"scope" : @"write",
                                                        @"client_secret" : apiSecret,
                                                        @"client_id" : apiKey}
                                              success:^(RKObjectRequestOperation* operation, RKMappingResult* result) {
                                                  NSArray* a = [result array];
                                                  JDOauth2TokenResponse* token = [result firstObject];
                                                  success(token);
                                              }
                                              failure:^(RKObjectRequestOperation* operation, NSError* error) {
                                                  failure(error);
                                              }];
}

@end
