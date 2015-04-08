//
//  THDReminderNotificationAlert.m
//  THDEnhancedRemindersRedemption
//
//  Created by iOS Developer on 2015-04-01.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDReminderNotificationAlert.h"
#import "THDAppDelegate.h"

@implementation THDReminderNotificationAlert

-(id)initWithReminderNotification:(UILocalNotification *)notification delegate:(id<UIAlertViewDelegate>)delegate
{
    //Get reminder using objectID stored in notification
    THDAppDelegate *root = (THDAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectID* reminderID = [[root persistentStoreCoordinator] managedObjectIDForURIRepresentation:[[notification userInfo] objectForKey:@"reminderID"]];
    THDReminder* reminder = [root getReminderFromTable:@"THDReminder" withObjectID:reminderID];
    
    self = [super initWithTitle:@"Reminder:" message:[reminder titleText] delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles:@"View", @"Snooze", nil];
    if (self) {
        _notification = notification;
        _reminder = reminder;
    }
    return self;
}

@end
