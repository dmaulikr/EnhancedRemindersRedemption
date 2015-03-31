//
//  THDReminderEditController.h
//  EnhancedReminders
//
//  Created by Adam LeBlanc on 2015-03-25.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDReminder.h"

@interface THDReminderEditController : UIViewController
{
    THDReminder* _reminder;
}

- (id)initWithReminder:(THDReminder*)reminder;

@end