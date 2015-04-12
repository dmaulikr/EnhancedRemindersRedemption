//
//  THDAppDelegate.m
//  THDEnhancedRemindersRedemption
//
//  Created by Adam LeBlanc on 2015-03-31.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDAppDelegate.h"
#import "THDReminderListController.h"
#import "THDReminderDetailsController.h"
#import <UIKit/UIAlertView.h>


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
    NSLog(@"didFinishLaunchingWithOptions");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [application setApplicationIconBadgeNumber: 0];
    
    //Set up Navigation Controller
    UITableViewController* thdReminderListController = [[THDReminderListController alloc] init];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:thdReminderListController];
    
    //Handle notifications when app is closed (user clicks notification, loads app, then does this)
    UILocalNotification* localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        //Pops up alert box with options to view, snooze, or cancel
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
        
         self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
        self.shareModel.anotherLocationManager.delegate = self;
        self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
        
        [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
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
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"applicationDidEnterBackground");
    
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
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
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Notifications and Maps

//Handle notifications when app is in foreground (user is browsing app, notification comes in, then do this)
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)localNotification
{
    application.applicationIconBadgeNumber = 0;
    
    //Get reminder using objectID stored in notification
    NSURL *url = [NSKeyedUnarchiver unarchiveObjectWithData:[[localNotification userInfo] objectForKey:@"reminderID"]];
    NSManagedObjectID* notificationReminderID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];
    alertReminder = [self getReminderFromTable:@"THDReminder" withObjectID:notificationReminderID];
    
    //pop up an alert box
    #warning Funky activity when another alert box pops up before this one is cleared (doesn't overwrite alertReminder)
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reminder:" message:[alertReminder titleText] delegate:self cancelButtonTitle:@"Thanks for reminding me" otherButtonTitles:@"View reminder", @"Remind me later", nil];
    [alert show];
}

//Required for interface UIAlertViewDelegate: determines actions when user clicks the buttons on an AlertView pop up
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //buttonIndex == 0 is for cancel, and nothing needs to be processed for that
    if (buttonIndex == 1) //View reminder
    {
        THDReminderDetailsController* next = [[THDReminderDetailsController alloc] init];
        [next setReminderID:[alertReminder objectID]];
        [(UINavigationController*)[[self window] rootViewController] pushViewController:next animated:YES];
    }
    else if (buttonIndex == 2) //Snooze reminder
    {
        int snooze = [[[NSUserDefaults standardUserDefaults] valueForKey:@"snoozeTimeSetting"] intValue];
        
        UILocalNotification* localNotification = [self createNotificationFromReminder:alertReminder];
        [localNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:snooze]];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
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
    else {
        [localNotification setFireDate: [[reminder triggerBefore] laterDate:[reminder triggerAfter]]];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

//Cancel a scheduled local notification for a reminder (if it exists)
-(void) cancelNotificationWithReminder:(THDReminder*)reminder
{
    NSArray* localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification* localNotification in localNotifications) {
        //compare them using their id in the database
        if ([[[localNotification userInfo] objectForKey:@"reminder"] objectID] == [reminder objectID]) {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            break;
        }
    }
}

-(void) tempMapCallBackMethodAdamPleaseFixMe
{
    //Send notification now
    #warning Adam: need a reminder for notification, grab from map callback
    //THDReminder* reminder = Map.getReminder();
    //[self createNotificationWithReminder:reminder sendNow:YES];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data stack

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
        #warning Long comment
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
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
    
    //sort here if required
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"titleText" ascending:YES];
    NSArray* sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //[sortDescriptors release];
    //[sortDescriptor release];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:fetchRequest
                                              managedObjectContext:context
                                              sectionNameKeyPath:nil
                                              cacheName:nil];
    //[fetchRequest release];
    
    NSError* error;
    return ([controller performFetch:&error] ? controller : nil);
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

//LOCATION DELEGATE METHODS

//Tells the delegate that location updates were paused. (required)
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{
    
}

//Tell the delegate that location updates were resumed (required)
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{
    
}

//Tells the delegate that new location information is available
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
}

@end
