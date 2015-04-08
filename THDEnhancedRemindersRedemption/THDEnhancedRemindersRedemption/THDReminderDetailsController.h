//
//  THDReminderDetailsController.h
//  EnhancedReminders
//
//  Created by iOS Developer on 2015-03-12.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDReminder.h"

@interface THDReminderDetailsController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    THDReminder* _reminder;
}

@property (nonatomic) NSManagedObjectID* reminderID;

@end
