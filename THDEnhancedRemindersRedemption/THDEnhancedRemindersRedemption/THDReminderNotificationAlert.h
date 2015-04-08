//
//  THDReminderNotificationAlert.h
//  THDEnhancedRemindersRedemption
//
//  Created by iOS Developer on 2015-04-01.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDReminder.h"

@interface THDReminderNotificationAlert : UIAlertView

@property(readonly) THDReminder* reminder;

-(id) initWithReminder:(THDReminder*)reminder delegate:(id <UIAlertViewDelegate>)delegate;

@end
