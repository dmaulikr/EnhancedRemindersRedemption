//
//  THDReminderTableViewCell.h
//  THDEnhancedRemindersRedemption
//
//  Created by Adam LeBlanc on 2015-03-31.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THDReminderTableViewCell : UITableViewCell

@property int ID;

-(id) initWithID:(int)ID reuseIdentifier:(NSString *)reuseIdentifier;

@end
