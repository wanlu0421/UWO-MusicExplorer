//
//  JDOauth2TokenResponse.h
//  MusicExplorer
//
//  Created by Justin Doyle on 2015-02-19.
//  Copyright (c) 2015 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface JDOauth2TokenResponse : NSObject
@property(nonatomic,copy) NSString* accessToken;
@property(nonatomic,copy) NSString* tokenType;
@property(nonatomic,copy) NSString* refreshToken;
@property(nonatomic,copy) NSNumber* expiresIn;
@property(nonatomic,copy) NSString* scope;

+(NSDictionary*)getMappings;
+(RKObjectMapping*)getObjectMapping;
+(void)getTokenUsername:(NSString*)username Password:(NSString*)password Success:(void(^)(JDOauth2TokenResponse* token))success Failure:(void(^)(NSError* error)) failure;
@end
