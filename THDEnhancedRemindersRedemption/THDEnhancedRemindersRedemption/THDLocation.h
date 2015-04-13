//
//  THDLocation.h
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-04-12.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class THDReminder;

@interface THDLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) THDReminder *reminder;

@end
