//
//  THDReminder.h
//  THDEnhancedRemindersRedemption
//
//  Created by Adam LeBlanc on 2015-03-31.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface THDReminder : NSManagedObject

@property (nonatomic, retain) NSString * titleText;
@property (nonatomic, retain) NSString * locationText;
@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSDate * triggerBefore;
@property (nonatomic, retain) NSDate * triggerAfter;

@end
