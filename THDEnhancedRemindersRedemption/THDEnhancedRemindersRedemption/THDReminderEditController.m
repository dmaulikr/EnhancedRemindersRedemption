//
//  THDReminderEditController.m
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-03-25.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDReminderEditController.h"
#import "THDReminder.h"
#import "THDAppDelegate.h"
#import "THDLocation.h"
@import MapKit;

@interface THDReminderEditController ()
{
    
}

@property (weak, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (strong, nonatomic) IBOutlet UITextField *remindAfterTextField;
@property (strong, nonatomic) IBOutlet UITextField *remindByTextField;
@property (strong, nonatomic) IBOutlet UITextField *reminderLocationTextField;
@property (strong, nonatomic) IBOutlet UIButton *deleteOutlet;

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

//delete reminder from database when delete button pressed
- (IBAction)deleteAction:(id)sender;

//location stuff
-(void)searchLocation:(NSString*)locationString;

@end

@implementation THDReminderEditController

-(id) init
{
    return [self initWithReminder:nil];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_reminderID == nil)
    {
        [_deleteOutlet setHidden:YES];
        _reminder = nil;
    }
    else
    {
        [_deleteOutlet setHidden:NO];
        
        THDAppDelegate* delegate = (THDAppDelegate*)[[UIApplication sharedApplication] delegate];
        _reminder = (THDReminder*)[[delegate managedObjectContext] objectWithID:_reminderID];
    }
    
    if(_reminder != nil)
    {
        [_titleTextField setText:[_reminder titleText]];
        [_descriptionTextField setText:[_reminder descriptionText]];
        [_remindAfterTextField setText:([_reminder triggerAfter] == nil ? @"No After Date" : [[THDAppDelegate dateFormatter] stringFromDate:[_reminder triggerAfter]])];
        [_remindByTextField setText:([_reminder triggerBefore] == nil ? @"No Before Date" : [[THDAppDelegate dateFormatter] stringFromDate:[_reminder triggerBefore]])];
        [_reminderLocationTextField setText:[_reminder locationText]];
    }
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
    THDAppDelegate *root = (THDAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [root managedObjectContext];

    if(!_reminder)
    {
        THDReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"THDReminder" inManagedObjectContext:context];
        _reminder = reminder;
    }
    
    NSDate* triggerBefore = [[THDAppDelegate dateFormatter] dateFromString:[[self remindByTextField]text]];
    NSDate* triggerAfter = [[THDAppDelegate dateFormatter] dateFromString:[[self remindAfterTextField]text]];
    
    //if location is not set, then do logic to make sure an after time is not set
    if ([[[self reminderLocationTextField]text] isEqualToString:@""])
    {
        //use earlierDate: to get the earlier date (returns nil if one or both are nil)
        if (triggerBefore == nil)
            triggerBefore = [triggerAfter copy]; //avoids earlierDate: setting to nil if before is nil
        else
            triggerBefore = [[triggerBefore earlierDate:triggerAfter] copy];
        triggerAfter = nil;
    }
    
    [_reminder setTitleText:[[self titleTextField]text]];
    [_reminder setDescriptionText:[[self descriptionTextField]text]];
    //dates return as nil if text field is empty
    [_reminder setTriggerAfter:triggerAfter];
    [_reminder setTriggerBefore:triggerBefore];
    [_reminder setLocationText:[[self reminderLocationTextField]text]];
    
    
    if(![[[self reminderLocationTextField]text] isEqualToString:@""]){
        [_reminder setIsLocationBased:[NSNumber numberWithBool:YES]];
        [self searchLocation:[[self reminderLocationTextField]text]];
    }else{
        NSError *error;
        if([context save:&error])
        {
            if ([_reminder triggerBefore] != nil || [_reminder triggerAfter] != nil)
                [root createNotificationWithReminder:_reminder sendNow:NO];
        
            [[self navigationController] popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Unable to save reminder at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
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

- (IBAction)deleteAction:(id)sender {
    THDAppDelegate *root = (THDAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [root managedObjectContext];
    
    [context deleteObject:_reminder];
    
    NSError *error;
    if([context save:&error])
    {
       [[self navigationController] popToRootViewControllerAnimated:YES];
        
        //cancel any notifications that may exist for this reminder
        [root cancelNotificationWithReminder:_reminder];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Unable to delete reminder at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
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
    NSString *dateString = [NSString stringWithFormat:@"%@",[[THDAppDelegate dateFormatter] stringFromDate:picker.date]];
    self.remindAfterTextField.text = ([dateString isEqualToString:@"(null)"] ? @"" : dateString);
}

- (IBAction)remindByEditDidBegin:(id)sender
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateRemindByTextField:) forControlEvents:UIControlEventValueChanged];
    [self.remindByTextField setInputView:datePicker];
    [self updateRemindByTextField:sender];
}

-(void)updateRemindByTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.remindByTextField.inputView;
    NSString *dateString = [NSString stringWithFormat:@"%@",[[THDAppDelegate dateFormatter] stringFromDate:picker.date]];
    self.remindByTextField.text = ([dateString isEqualToString:@"(null)"] ? @"" : dateString);
}

-(void)searchLocation:(NSString*)locationString{
    
    //Create the search
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc]init];
    searchRequest.naturalLanguageQuery = locationString;
    
    //create the local search
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:searchRequest];
    __block NSMutableSet *locations = [[NSMutableSet alloc]initWithCapacity:20];
    
    //run the search
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if(error){
            NSLog(@"%@", error.localizedDescription);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Unable to save reminder at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        NSLog(@"Location results returned without error");
        //NSLog(@"responses : %@", response);
        NSArray *resultsArray = response.mapItems;
        locations = [[NSMutableSet alloc]initWithCapacity:resultsArray.count];
        
        THDAppDelegate *root = (THDAppDelegate*)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context = [root managedObjectContext];
        
        
        for(int i = 0; i < resultsArray.count; i++){
            MKMapItem *mapItem = resultsArray[i];
            //NSNumber *longitude = mapItem.placemark.location.coordinate.longitude;
            NSNumber *longitude = [NSNumber numberWithDouble:mapItem.placemark.location.coordinate.longitude];
            NSNumber *latitude = [NSNumber numberWithDouble:mapItem.placemark.location.coordinate.latitude];
           // NSLog(@"%@, %@", latitude, longitude);
            THDLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"THDLocation" inManagedObjectContext:context];
            location.longitude = longitude;
            location.latitude = latitude;
            [locations addObject:location];
        }
        NSLog(@"Location count : %d", locations.count);
        [_reminder setLocations:locations];
        [_reminder setIsLocationBased:[NSNumber numberWithBool:YES]];
        NSError *errorSave;
        if([context save:&errorSave])
        {
            if ([_reminder triggerBefore] != nil || [_reminder triggerAfter] != nil)
                [root createNotificationWithReminder:_reminder sendNow:NO];
            
            [[self navigationController] popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Unable to save reminder at this time." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
   }

@end
