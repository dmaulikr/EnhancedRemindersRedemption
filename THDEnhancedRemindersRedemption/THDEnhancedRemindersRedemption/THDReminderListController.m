//
//  THDReminderListController.m
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-03-12.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDReminderListController.h"
#import "THDReminderDetailsController.h"
#import "THDReminderEditController.h"
#import "THDReminder.h"
#import "THDAppDelegate.h"

@interface THDReminderListController ()
//the create new reminder button was pressed. Open the creation view
-(void)createNewButtonPressed;
@end

@implementation THDReminderListController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    THDAppDelegate* delegate = (THDAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = [delegate managedObjectContext];
    
    //Construct a fetch request
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"THDReminder" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //Add an NSSortDescriptor to sort the faculties alphabetically ,<--- WTF!?
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"titleText" ascending:YES];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError* error;
    _reminders = [context executeFetchRequest:fetchRequest error:&error];
    [[self tableView] reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Reminders"];
    
    UIBarButtonItem *addNewReminderButton = [[UIBarButtonItem alloc]initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(createNewButtonPressed)];
    [[self navigationItem]setLeftBarButtonItem:addNewReminderButton];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)createNewButtonPressed
{
    THDReminderEditController* next = [[THDReminderEditController alloc] init];
    [next setReminderID:nil];
    
    [[self navigationController] pushViewController:next animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_reminders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* myCellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myCellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myCellID];
    }
    
    // Configure the cell...
    THDReminder* reminder = _reminders[[indexPath row]];
    [[cell textLabel] setText:[reminder titleText]];
    [[cell detailTextLabel] setText:[reminder descriptionText]];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //redirect to the THDReminderDetailsController initializing using the ID for the selected row
    THDReminderDetailsController* next = [[THDReminderDetailsController alloc] init];
    THDReminder* reminder = _reminders[[indexPath row]];
    [next setReminderID:[reminder objectID]];
    
    [[self navigationController] pushViewController:next animated:YES];
}

@end
