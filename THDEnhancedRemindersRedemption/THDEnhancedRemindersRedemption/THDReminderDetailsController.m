//
//  THDReminderDetailsController.m
//  EnhancedReminders
//
//  Created by iOS Developer on 2015-03-12.
//  Copyright (c) 2015 UPEICS. All rights reserved.
//

#import "THDAppDelegate.h"
#import "THDReminderDetailsController.h"
#import "THDReminderEditController.h"

@interface THDReminderDetailsController ()

@property int ID;

@end

@implementation THDReminderDetailsController

-(id)init
{
    return [self initWithReminder:nil];
}

-(id) initWithReminder:(THDReminder*)reminder
{
    self = [super init];
    if (self) {
        _reminder = reminder;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Title";
    else if (section == 1)
        return @"Description";
    else if (section == 2)
        return @"Before";
    else if (section == 3)
        return @"After";
    else
        return @"Location";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* myCellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myCellID];
    }
    
    switch ([indexPath section])
    {
        case 0: [[cell textLabel] setText:([[_reminder titleText] isEqualToString:@""] ? @"No Title" : [_reminder titleText])];
            break;
        case 1: [[cell textLabel] setText:([[_reminder descriptionText] isEqualToString:@""] ? @"No Description" : [_reminder descriptionText])];
            break;
        case 2: [[cell textLabel] setText:([_reminder triggerBefore] == nil ? @"No Before Date" : [[THDAppDelegate dateFormatter]
                                                                                                   stringFromDate: [_reminder triggerBefore]])];
            break;
        case 3: [[cell textLabel] setText:([_reminder triggerAfter] == nil ? @"No After Date" : [[THDAppDelegate dateFormatter]
                                                                                                 stringFromDate:[_reminder triggerAfter]])];
            break;
        case 4: [[cell textLabel] setText:([[_reminder locationText] isEqualToString:@""] ? @"No Location Set" : [_reminder locationText])];
            break;
    }
    
    return cell;
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
