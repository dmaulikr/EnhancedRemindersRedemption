//
//  THDReminderDetailsController.m
//  EnhancedReminders
//
//  Created by iOS Developer on 2015-03-12.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import "THDReminderDetailsController.h"
#import "THDReminderEditController.h"

@interface THDReminderDetailsController ()

@property int ID;

@end

@implementation THDReminderDetailsController

-(id)init
{
    _reminder = nil;
    return self;
}

-(id) initWithReminder:(THDReminder*)reminder
{
    self = [super init];
    if (self) {
        _reminder = reminder;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"Details"];
    
    //Create Edit button on the right of the navigation bar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    [[self navigationItem] setRightBarButtonItem:editButton];
    
    // Setup up Table View
    
    
    NSLog(@"Loaded");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)editButtonPressed
{
    UIViewController *controller = [[THDReminderEditController alloc] initWithReminder:_reminder];
    [[self navigationController] pushViewController:controller animated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
