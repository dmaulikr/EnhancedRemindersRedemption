//
//  THDAppDelegate.h
//  THDEnhancedRemindersRedemption
//
//  Created by Team Hipster Droid on 2015-03-31.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//
//http://mobileoop.com/getting-location-updates-for-ios-7-and-8-when-the-app-is-killedterminatedsuspended
#import <UIKit/UIKit.h>
#import "THDReminder.h"
#import "THDLocationShareModel.h"
@import CoreLocation;

@interface THDAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

+(NSDateFormatter*) dateFormatter;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//creates a new notification with a reminder object.
-(void) createNotificationWithReminder:(THDReminder*)reminder sendNow:(BOOL)sendNow;

//Cacneles a notification with a reminder
-(void) cancelNotificationWithReminder:(THDReminder*)reminder;

//write to the database
- (void)saveContext;
//Magic
- (NSURL *)applicationDocumentsDirectory;


-(NSFetchedResultsController*) readFromTable:(NSString*)entityName;

//get a reminder from database
-(THDReminder*) getReminderFromTable:(NSString*)table withObjectID:(NSManagedObjectID*)objectID;


//LOCATION STUFF
@property (strong,nonatomic) THDLocationShareModel * shareModel;

@end
