//
//  THDReminderEditController.h
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-03-25.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDReminder.h"

@interface THDReminderEditController : UIViewController
{
    THDReminder* _reminder;
}

@property (nonatomic) NSManagedObjectID* reminderID;

@end