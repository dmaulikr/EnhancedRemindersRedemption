//
//  THDAppDelegate.m
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-03-31.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDAppDelegate.h"
#import "THDReminderListController.h"
#import "THDReminderDetailsController.h"
#import <UIKit/UIAlertView.h>
#import "THDLocation.h"


@interface THDAppDelegate ()
{
    THDReminder* alertReminder;
}

@end

@implementation THDAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [application setApplicationIconBadgeNumber: 0];
    
    //Set up Navigation Controller
    UITableViewController* thdReminderListController = [[THDReminderListController alloc] init];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:thdReminderListController];
    
    //Handle notifications when app is closed (user clicks notification, loads app, then does this)
    UILocalNotification* localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        //Pops up an alert box with options to view, snooze, or cancel
        [self application:application didReceiveLocalNotification:localNotification];
    }
    
    //LOCATION STUFF
    self.shareModel = [THDLocationShareModel sharedModel];
    
    UIAlertView *alert;
    
     //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
    }else{
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        if([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]){
            self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
            self.shareModel.anotherLocationManager.delegate = self;
            self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
        
            [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
        }
    }

    
    [[self window] setRootViewController:navController];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

//Return dateFormatter when it's called (setting it up only on the first time)
+(NSDateFormatter *)dateFormatter
{
    static NSDateFormatter* df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setTimeStyle:NSDateFormatterShortStyle];
        [df setDateStyle:NSDateFormatterFullStyle];
        [df setLocale:[NSLocale currentLocale]];
    }
    return df;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //Need to start than stop monitoring so we can get the callback in background
    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber: 0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //set up listening for significant location changes again
    if(self.shareModel.anotherLocationManager)
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Notifications and Maps

//Handle notifications when app is not closed (user is browsing app, notification comes in, then do this)
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)localNotification
{
    application.applicationIconBadgeNumber = 0;
    
    //Get reminder using objectID stored in notification
    NSURL *url = [NSKeyedUnarchiver unarchiveObjectWithData:[[localNotification userInfo] objectForKey:@"reminderID"]];
    NSManagedObjectID* notificationReminderID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];
    alertReminder = [self getReminderFromTable:@"THDReminder" withObjectID:notificationReminderID];
    
    //pop up an alert box
    static UIAlertView* alert = nil;
    if (alert == nil) //allow only one pop up at a time
        alert = [[UIAlertView alloc] initWithTitle:@"Reminder:" message:[alertReminder titleText] delegate:self cancelButtonTitle:@"Thanks for reminding me" otherButtonTitles:@"View reminder", @"Remind me later", nil];
    [alert show];
    
    [self deleteReminder:alertReminder];
}

//Required for interface UIAlertViewDelegate: determines actions when user clicks the buttons on an AlertView pop up
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) //Cancel reminder (renamed "Thanks")
    {
        [self deleteReminder:alertReminder];
    }
    else //View or snooze
    {
        //Snooze no matter what
        int snooze = [[[NSUserDefaults standardUserDefaults] valueForKey:@"snoozeTimeSetting"] intValue];
        
        UILocalNotification* localNotification = [self createNotificationFromReminder:alertReminder];
        [localNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:snooze]];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        //View reminder if they chose to
        if (buttonIndex == 1)
        {
            THDReminderDetailsController* next = [[THDReminderDetailsController alloc] init];
            [next setReminderID:[alertReminder objectID]];
            [(UINavigationController*)[[self window] rootViewController] pushViewController:next animated:YES];
        }
    }
    
    alert = nil; //allow only one pop up at a time
}

//Helper method to create a notification from a reminder (but not to send it)
-(UILocalNotification*) createNotificationFromReminder:(THDReminder*)reminder
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    [localNotification setAlertBody: [reminder titleText]];
    [localNotification setSoundName: UILocalNotificationDefaultSoundName];
    [localNotification setApplicationIconBadgeNumber: [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
    [localNotification setTimeZone: [NSTimeZone defaultTimeZone]];
    
    //SetUserInfo: only takes objects that can be on a property list, so store the reminder's object ID as an NSData object
    NSData* reminderID = [NSKeyedArchiver archivedDataWithRootObject:[[reminder objectID] URIRepresentation]];
    [localNotification setUserInfo:[NSDictionary dictionaryWithObject:reminderID forKey:@"reminderID"]];
    return localNotification;
}

//Create a local notification containing a reminder to be fired immediately or upon the triggerBefore date
//If set to send later and both triggerBefore and triggerAfter are nil, acts as if set to send immediately
-(void) createNotificationWithReminder:(THDReminder*)reminder sendNow:(BOOL)sendNow
{
    if (!sendNow && [reminder triggerBefore] == nil && [[reminder locationText] isEqualToString:@""])
        return;
    
    //Cancel any existing notifications with the reminder (one notification per reminder)
    [self cancelNotificationWithReminder:reminder];
    
    UILocalNotification* localNotification = [self createNotificationFromReminder:reminder];
    
    if (sendNow || [reminder triggerBefore] == nil)
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    else
    {
        [localNotification setFireDate: [[reminder triggerBefore] laterDate:[reminder triggerAfter]]];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

//Cancel a scheduled local notification for a reminder (if it exists)
-(void) cancelNotificationWithReminder:(THDReminder*)reminder
{
    NSArray* localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification* localNotification in localNotifications)
    {
        //compare them using their id in the database
        if ([[[localNotification userInfo] objectForKey:@"reminder"] objectID] == [reminder objectID]) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            break;
        }
    }
}

#pragma mark - Core Data stack

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//Save the contect of the database
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"THDEnhancedRemindersRedemption" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"THDEnhancedRemindersRedemption.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

//Read and return entire table from database
-(NSFetchedResultsController*) readFromTable:(NSString*)entityName
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    //set entity for fetch request
    NSEntityDescription* entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //sort based on reminder title
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"titleText" ascending:YES];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:fetchRequest
                                              managedObjectContext:context
                                              sectionNameKeyPath:nil
                                              cacheName:nil];
    
    NSError* error;
    return ([controller performFetch:&error] ? controller : nil);
}

//delete a reminder from the database
-(void) deleteReminder:(THDReminder*)reminder
{
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:reminder];
    [self cancelNotificationWithReminder:reminder];
    NSError *error = nil;
    if(![context save:&error]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Unable to delete reminder" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//Return reminder from table that matches object ID (or nil if no match)
-(THDReminder*) getReminderFromTable:(NSString*)table withObjectID:(NSManagedObjectID*)objectID
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    
    //set entity for fetch request
    NSEntityDescription* entity = [NSEntityDescription entityForName:table inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError* error;
    NSArray* result = [context executeFetchRequest:fetchRequest error:&error];
    
    return ([result count] == 0 ? nil : (THDReminder*)[result objectAtIndex:0]);
}

#pragma mark Location Delegate

//Tells the delegate that location updates were paused. (required)
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"LocationManagerDidPauseLocationUpdates");
}

//Tell the delegate that location updates were resumed (required)
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"LocationManagerDidResumeLocationUpdates");
}

//Tells the delegate that new location information is available
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"LocationManager didUpdateLocations");
    
    //Create a fetch request that will only pull remidners that are location based
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"THDReminder" inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isLocationBased == YES"]];
    
    NSError *error = nil;
    
    NSArray *results = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&error];
    
    CLLocation *coordinate = manager.location;  //The users current location
    NSDate *currentTime = [NSDate date];        //The current time
    
    //loop through all items in the fetch result
    //Trigering a notification for the first one found that is close enough to a found location
    for (THDReminder *reminder in results) {
        NSSet *locations = reminder.locations;      //All locations assositated with this reminder
        for (THDLocation *location in locations) {
            NSLog(@"Checking location");
            //Turn the coordinates stored in location into a CLLocation
            CLLocation *anotherLocation = [[CLLocation alloc]initWithLatitude:[[location latitude]doubleValue] longitude:[[location longitude]doubleValue]];
            if([coordinate distanceFromLocation:anotherLocation] <= 100.0 && [[reminder triggerBefore]timeIntervalSince1970] >= [currentTime timeIntervalSince1970] && [[reminder triggerAfter]timeIntervalSince1970] <= [currentTime timeIntervalSince1970]){
                alertReminder = reminder;
                [self createNotificationWithReminder:reminder sendNow:YES];
                NSLog(@"Notification sent");
                return;
            }
        }
    }
}

@end
