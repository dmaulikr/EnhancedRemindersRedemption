//
//  THDReminderEditController.m
//  EnhancedReminders
//
//  Created by Adam LeBlanc on 2015-03-25.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import "THDReminderEditController.h"
#import "THDReminder.h"

@interface THDReminderEditController ()
//Text fields
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (strong, nonatomic) IBOutlet UITextField *remindAfterTextField;
@property (strong, nonatomic) IBOutlet UITextField *remindByTextField;
@property (strong, nonatomic) IBOutlet UITextField *reminderLocationTextField;
//before and after dates
@property (strong, nonatomic) NSDate *remindAfterDate;
@property (strong, nonatomic) NSDate *remindByDate;

//callback methods to change date fields when datepicker changes
- (void)updateRemindAfterTextField:(id)sender;
- (void)updateRemindByTextField:(id)sender;
//callbacks to display datePicker instead of keyboard
- (IBAction)remindAfterEditDidBegin:(id)sender;
- (IBAction)remindByEditDidBegin:(id)sender;

//dismiss the keyboard when the background is touched
- (void)dismissKeyboard;
@end

@implementation THDReminderEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //listen for touches outside of textfield, and call the
        //dismisskeyboard  method when happens
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                    action:@selector(dismissKeyboard)];
        
       [self.view addGestureRecognizer:tap];
    }
    return self;
}

-(void)viewDidLoad
{
    
}

//dismiss the keyboard
-(void)dismissKeyboard
{
    [_titleTextField resignFirstResponder];
    [_descriptionTextField resignFirstResponder];
    [_remindAfterTextField resignFirstResponder];
    [_remindByTextField resignFirstResponder];
    [_reminderLocationTextField resignFirstResponder];
}


- (IBAction)remindAfterEditDidBegin:(id)sender
{
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateRemindAfterTextField:) forControlEvents:UIControlEventValueChanged];
    [self.remindAfterTextField setInputView:datePicker];
    [self updateRemindAfterTextField:sender];
}

- (void)updateRemindAfterTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.remindAfterTextField.inputView;
    self.remindAfterTextField.text = [NSString stringWithFormat:@"%@",picker.date];
    _remindAfterDate = picker.date;
}

- (IBAction)remindByEditDidBegin:(id)sender
{
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateRemindByTextField:) forControlEvents:UIControlEventValueChanged];
    [self.remindByTextField setInputView:datePicker];
    [self updateRemindAfterTextField:sender];
}

-(void)updateRemindByTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.remindByTextField.inputView;
    self.remindByTextField.text = [NSString stringWithFormat:@"%@",picker.date];
    _remindByDate = picker.date;
}

@end
