//
//  THDLocationShareModel.m
//  THDEnhancedRemindersRedemption
//
//  Created by Adam LeBlanc on 2015-04-12.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDLocationShareModel.h"

@implementation THDLocationShareModel

//creates a singleton
+ (id)sharedModel
{
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    return sharedMyModel;
}


@end
