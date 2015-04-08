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
#import "THDReminderNotificationAlert.h"
#import <UIKit/UIAlertView.h>

@implementation THDAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Set up Navigation Controller
    UITableViewController* thdReminderListController = [[THDReminderListController alloc] init];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:thdReminderListController];
    
    //Handle notifications when app is in background (user clicks notification, loads app, then does this)
    UILocalNotification* localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {
        [application setApplicationIconBadgeNumber: 0];
        
        NSManagedObjectID* reminderID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:[[localNotification userInfo] objectForKey:@"reminderID"]];
        
        THDReminderDetailsController* next = [[THDReminderDetailsController alloc] init];
        [next setReminderID:reminderID];
        [navController pushViewController:next animated:YES];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
    
    //pop up an alert box
    UIAlertView* alert = [[THDReminderNotificationAlert alloc] initWithReminderNotification:localNotification delegate:self];
    [alert show];
}

//Required for interface UIAlertViewDelegate: determines actions when user clicks the buttons on an AlertView pop up
-(void)alertView:(THDReminderNotificationAlert *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //buttonIndex == 0 is for cancel, and nothing needs to be processed for that
    if (buttonIndex == 1) //View reminder
    {
        THDReminderDetailsController* next = [[THDReminderDetailsController alloc] init];
        [next setReminderID:[[alert reminder] objectID]];
        [(UINavigationController*)[[self window] rootViewController] pushViewController:next animated:YES];
    }
    else if (buttonIndex == 2) //Snooze reminder
    {
        UILocalNotification* localNotification = [alert notification];
        
        int snooze = (int)[[NSUserDefaults standardUserDefaults] valueForKey:@"snoozeTimeSetting"];
        [localNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:snooze]];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

//Create a local notification containing a reminder to be fired immediately or upon the later date of triggerBefore or triggerAfter
//If set to send later and both triggerBefore and triggerAfter are nil, acts as if set to send immediately
-(void) createNotificationWithReminder:(THDReminder*)reminder sendNow:(BOOL)sendNow
{
    //Cancel any existing notifications with the reminder (one notification per reminder)
    [self cancelNotificationWithReminder:reminder];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    [localNotification setAlertBody: [reminder titleText]];
    [localNotification setSoundName: UILocalNotificationDefaultSoundName];
    [localNotification setApplicationIconBadgeNumber: [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1];
    
    [localNotification setUserInfo: [NSDictionary dictionaryWithObject:[[reminder objectID] URIRepresentation] forKey:@"reminderID"]];
    
    [localNotification setTimeZone: [NSTimeZone defaultTimeZone]];
    
    if (sendNow || ([reminder triggerBefore] == nil && [reminder triggerAfter] == nil))
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

#warning Long comments
//-(NSManagedObject*) readFromTable:(NSEntityDescription*)entityDescription byID:(NSManagedObjectID*)ID
//{
//     //Get the context
//    NSManagedObjectContext* context = [self managedObjectContext];
//    
//    // Build the fetch request
//    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription* entity = [NSEntityDescription entityForName:[entityDescription name] inManagedObjectContext:context];
//    
//    [fetchRequest setEntity:entity];
//    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"objectID == %@", ID];
//    [fetchRequest setPredicate:predicate];
//    
//    NSError* error = nil;
//    NSArray* fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    
//    if([fetchedObjects count] != 0)
//    {
//        return fetchedObjects[0];
//    }
//    else
//    {
//        return nil;
//    }
//    
//}

//-(void) updateObject:(NSManagedObject*)object
//{
//    [self readFromTable:[object entity] byID:[[object objectID]]];
//    if()
//    
//    
//    //Get the context
//    NSManagedObjectContext* context = [self managedObjectContext];
//    
//    // Build the fetch request
//    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
//    //NSEntityDescription* entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:context];
//    
//    [fetchRequest setEntity:[object entity]];
//    
//}

@end
