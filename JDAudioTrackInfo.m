//
//  JDAudioTrackInfo.m
//  UwoMusicApp
//
//  Created by Justin Doyle on 2014-07-11.
//  Copyright (c) 2014 Western University. All rights reserved.
//

#import "JDAudioTrackInfo.h"

@implementation JDAudioTrackInfo

@synthesize file, extension, name, description, offset, x, y, width, height, hasStartRange, startRange;

-(id)init {
    self = [super init];
    if (self) {
        // Initialization code
        hasStartRange = NO;
    }
    return self;
}

@end
