//
//  JDRestKitConfiguration.m
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import "JDRestKitConfiguration.h"
#import <RestKit/RestKit.h>
#import <ISO8601DateFormatterValueTransformer/RKISO8601DateFormatter.h>
#import "JDNewsRestModel.h"
#import "JDSongDescriptorRestModel.h"
#import "JDOauth2TokenResponse.h"

@implementation JDRestKitConfiguration
+(void)configureRestKit {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"application" ofType:@"plist"];
    NSDictionary* props = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSURL* url = [NSURL URLWithString:props[@"apiUrl"]];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [client setDefaultHeader:@"Content-Type" value:RKMIMETypeJSON];
    RKObjectManager* objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    RKObjectManager* manager = [RKObjectManager sharedManager];
    
    NSString* apiKey = props[@"apiKey"];
    NSString* apiSecret = props[@"apiSecret"];
    
    [manager.HTTPClient setAuthorizationHeaderWithUsername:apiKey password:apiSecret];
    
    /*
        Set up the date formatter. TODO: Get this actually working properly... It's getting sent
        as seconds since epoch, but not converting it properly.
     */
    [[RKValueTransformer defaultValueTransformer] insertValueTransformer:[RKValueTransformer timeIntervalSince1970ToDateValueTransformer] atIndex:0];
    
    
    /*
        Add response descriptors
     */
    [manager addResponseDescriptorsFromArray:[JDRestKitConfiguration responseDescriptors]];
}

+(NSArray*)responseDescriptors {
    return @[
             // OAuth2 token request
             [RKResponseDescriptor responseDescriptorWithMapping:[JDOauth2TokenResponse getObjectMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/oauth/token"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             // Latest news on success
             [RKResponseDescriptor
              responseDescriptorWithMapping:[JDNewsRestModel getObjectMapping]
              method:RKRequestMethodGET
              pathPattern:@"/api/news/latest"
              keyPath:nil
              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             // All songs on success
             [RKResponseDescriptor responseDescriptorWithMapping:[JDSongDescriptorRestModel getObjectMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/songs"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)],
             
             // Song search
             [RKResponseDescriptor responseDescriptorWithMapping:[JDSongDescriptorRestModel getObjectMapping]
                                                          method:RKRequestMethodGET
                                                     pathPattern:@"/api/songs/search"
                                                         keyPath:nil
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]
             
             /*** ADD MORE HERE ***/
             ];
}
@end
