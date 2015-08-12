//
//  MedCell.h
//  MedBox
//
//  Created by Athul Sai on 22/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

@interface MedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

- (void)updateCellWithReminder:(Reminder *)reminder;

@end
