//
//  JDAudioTrackInfo.h
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-07-11.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDAudioTrackInfo : NSObject
{
    NSString* file;
    NSString* extension;
    NSString* name;
    NSString* description;
    NSNumber* offset;
    NSNumber* x;
    NSNumber* y;
    NSNumber* width;
    NSNumber* height;
    BOOL hasStartRange;
    NSNumber* startRange;
}

@property(nonatomic, retain) NSString* file;
@property(nonatomic, retain) NSString* extension;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* description;
@property(nonatomic, retain) NSNumber* offset;
@property(nonatomic, retain) NSNumber* x;
@property(nonatomic, retain) NSNumber* y;
@property(nonatomic, retain) NSNumber* width;
@property(nonatomic, retain) NSNumber* height;
@property(nonatomic) BOOL hasStartRange;
@property(nonatomic, retain) NSNumber* startRange;


@end
