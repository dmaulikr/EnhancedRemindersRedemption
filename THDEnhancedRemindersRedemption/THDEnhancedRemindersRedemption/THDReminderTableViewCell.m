//
//  THDReminderTableViewCell.m
//  THDEnhancedRemindersRedemption
//
//  Created by Adam LeBlanc on 2015-03-31.
//  Copyright (c) 2015 Team Hipster Droid. All rights reserved.
//

#import "THDReminderTableViewCell.h"
#import "THDAppDelegate.h"

@implementation THDReminderTableViewCell

-(id) initWithID:(int)ID reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        _ID = ID;
        //NSManagedObject* reminder = [THDAppDelegate readFromTable:@"THDReminder" byID:_ID];
        
        [[self textLabel] setText:@"Title"];
        [[self detailTextLabel] setText:[NSString stringWithFormat:@"ID: %d", _ID]];
        [self setAccessoryType:UITableViewCellAccessoryDetailButton];
        //[[self imageView] setImage:[UIImage imageNamed:@"puppy.jpg"]];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
