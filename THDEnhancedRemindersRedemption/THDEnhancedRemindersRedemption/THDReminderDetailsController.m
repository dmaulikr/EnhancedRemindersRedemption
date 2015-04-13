//
//  THDReminderDetailsController.m
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-03-12.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDAppDelegate.h"
#import "THDReminderDetailsController.h"
#import "THDReminderEditController.h"

@interface THDReminderDetailsController ()

//Open up the edit view for this reminder
-(void)editButtonPressed;

@end

@implementation THDReminderDetailsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"Details"];
    
    //Create Edit button on the right of the navigation bar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    [[self navigationItem] setRightBarButtonItem:editButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    THDAppDelegate* delegate = (THDAppDelegate*)[[UIApplication sharedApplication] delegate];
    _reminder = (THDReminder*)[[delegate managedObjectContext] objectWithID:_reminderID];
    [[self tableView] reloadData];
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
        case 2: [[cell textLabel] setText:([_reminder triggerBefore] == nil ? @"No Before Date" : [[THDAppDelegate dateFormatter] stringFromDate: [_reminder triggerBefore]])];
            break;
        case 3: [[cell textLabel] setText:([_reminder triggerAfter] == nil ? @"No After Date" : [[THDAppDelegate dateFormatter] stringFromDate:[_reminder triggerAfter]])];
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
    THDReminderEditController* next = [[THDReminderEditController alloc] init];
    [next setReminderID:[_reminder objectID]];
    [[self navigationController] pushViewController:next animated:YES];
}

@end
