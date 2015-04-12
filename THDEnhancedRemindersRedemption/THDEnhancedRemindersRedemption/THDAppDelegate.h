//
//  THDAppDelegate.h
//  THDEnhancedRemindersRedemption
//
//  Created by Adam LeBlanc on 2015-03-31.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDReminder.h"

@interface THDAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

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

@end
