//
//  THDReminderListController.h
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-03-12.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THDReminderListController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSArray* _reminders;
}

@end