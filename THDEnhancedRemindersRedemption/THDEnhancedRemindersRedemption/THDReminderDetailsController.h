//
//  THDReminderDetailsController.h
//  EnhancedReminders

// display details about  reminder
//
//  Created by iOS Developer on 2015-03-12.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDReminder.h"

@interface THDReminderDetailsController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    //The reminder object
    THDReminder* _reminder;
}

//What does this do?
@property (nonatomic) NSManagedObjectID* reminderID;

@end
