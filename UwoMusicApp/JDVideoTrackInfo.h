//
//  JDVideoTrackInfo.h
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-07-11.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDVideoTrackInfo : NSObject

{
    NSString* file;
    NSString* extension;
    NSNumber* startTime;
    BOOL hasStartRange;
    NSNumber* startRange;
}

@property(nonatomic, retain) NSString* file;
@property(nonatomic, retain) NSString* extension;
@property(nonatomic, retain) NSNumber* startTime;
@property(nonatomic) BOOL hasStartRange;
@property(nonatomic, retain) NSNumber* startRange;

@end
