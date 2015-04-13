//
//  THDReminder.h
//  THDEnhancedRemindersRedemption
//
//  Created by Adam LeBlanc on 2015-04-12.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class THDLocation;

@interface THDReminder : NSManagedObject

@property (nonatomic, retain) NSString * descriptionText;
@property (nonatomic, retain) NSString * locationText;
@property (nonatomic, retain) NSString * titleText;
@property (nonatomic, retain) NSDate * triggerAfter;
@property (nonatomic, retain) NSDate * triggerBefore;
@property (nonatomic, retain) NSNumber * isLocationBased;
@property (nonatomic, retain) NSSet *locations;
@end

@interface THDReminder (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(THDLocation *)value;
- (void)removeLocationsObject:(THDLocation *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
