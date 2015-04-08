//
//  THDReminderNotificationAlert.m
//  THDEnhancedRemindersRedemption
//
//  Created by iOS Developer on 2015-04-01.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDReminderNotificationAlert.h"

@implementation THDReminderNotificationAlert

-(id)initWithReminder:(THDReminder *)reminder delegate:(id <UIAlertViewDelegate>)delegate
{
    self = [super initWithTitle:@"Reminder:" message:[reminder titleText] delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles:@"View", nil];
    if (self) {
        _reminder = reminder;
    }
    return self;
}

@end
