//
//  THDReminderListController.h
//  EnhancedReminders
//
//  Created by iOS Developer on 2015-03-12.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THDReminderListController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray* _reminders;
}

@end