//
//  THDReminderEditController.h
//  EnhancedReminders
//
//  Created by Adam LeBlanc on 2015-03-25.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THDReminderEditController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextView *desctiptionText;
@property (weak, nonatomic) IBOutlet UITextField *triggerAfterText;
@property (weak, nonatomic) IBOutlet UITextField *triggerBeforeText;
- (IBAction)byTimeDidBeginEdit:(id)sender;
- (IBAction)afterTimeDidBeginEdit:(id)sender;
- (IBAction)deleteAction:(id)sender;

@end