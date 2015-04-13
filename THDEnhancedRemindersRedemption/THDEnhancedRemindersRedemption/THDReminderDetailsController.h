//
//  THDReminderDetailsController.h
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-03-12.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDReminder.h"

@interface THDReminderDetailsController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    THDReminder* _reminder;
}

@property (nonatomic) NSManagedObjectID* reminderID;

@end
