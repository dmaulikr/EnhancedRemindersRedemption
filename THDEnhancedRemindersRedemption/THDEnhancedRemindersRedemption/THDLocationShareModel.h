//
//  THDLocationShareModel.h
//  THDEnhancedRemindersRedemption
//
//  Created by Adam LeBlanc on 2015-04-12.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//
//Allows Location information to be shared throughout the app.

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface THDLocationShareModel : NSObject

@property (nonatomic) CLLocationManager *anotherLocationManager;


+(id)sharedModel;

@end
