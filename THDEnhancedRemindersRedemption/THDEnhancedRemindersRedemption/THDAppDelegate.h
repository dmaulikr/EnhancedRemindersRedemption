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

-(void) createNotificationWithReminder:(THDReminder*)reminder sendNow:(BOOL)sendNow;
-(void) cancelNotificationWithReminder:(THDReminder*)reminder;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(NSFetchedResultsController*) readFromTable:(NSString*)entityName;

@end
