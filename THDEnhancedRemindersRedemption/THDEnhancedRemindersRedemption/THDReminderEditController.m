//
//  THDReminderEditController.m
//  EnhancedReminders
//
//  Created by Adam LeBlanc on 2015-03-25.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import "THDReminderEditController.h"
#import "THDReminder.h"
#import "THDAppDelegate.h"

@interface THDReminderEditController ()
@property (weak, nonatomic) NSManagedObjectContext *context;
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

//save the reminder to the database
-(void)save;

//dismiss the keyboard when the background is touched
- (void)dismissKeyboard;

- (IBAction)deleteAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *deleteOutlet;

@end

@implementation THDReminderEditController

-(id) init
{
    _reminder = nil;
    [_deleteOutlet setHidden:YES];
    return self;
}

-(id) initWithReminder:(THDReminder*)reminder
{
    self = [super init];
    if (self) {
        _reminder = reminder;
        //[_deleteOutlet setHidden:(!reminder ? YES : NO)];
        [_deleteOutlet setHidden:(reminder == nil)];
    }
    return self;
}

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
    [super viewDidLoad];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    [[self navigationItem]setRightBarButtonItem:saveButton];
}

-(void)save
{
    THDAppDelegate *root = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [root managedObjectContext];

    THDReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"THDReminder" inManagedObjectContext:context];
    [reminder setTitleText:[[self titleTextField]text]];
    [reminder setDescriptionText:[[self descriptionTextField]text]];
    [reminder setTriggerAfter:_remindAfterDate];
    [reminder setTriggerBefore:_remindByDate];
    [reminder setLocationText:[[self reminderLocationTextField]text]];
    
    NSError *error;
    
    if([context save:&error])
    {
        //test code please ignore
//        NSFetchRequest *request = [[NSFetchRequest alloc]init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"THDReminder" inManagedObjectContext:context];
//        
//        [request setEntity:entity];
//        
//        NSArray *fetched = [context executeFetchRequest:request error:&error];
//        
//        for(THDReminder *reminder in fetched){
//            NSLog(@"Title: %@", [reminder titleText]);
//        }
        
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"insert broken popup here");
    }
}

- (IBAction)deleteAction:(id)sender {
    THDAppDelegate *root = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [root managedObjectContext];
    
    [context deleteObject:_reminder];
    
    NSError *error;
    if([context save:&error])
    {
       [[self navigationController] popToRootViewControllerAnimated:YES];
    }
    else
    {
        NSLog(@"Delete Failed");
    }
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
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
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
