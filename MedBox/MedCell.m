//
//  MedCell.m
//  MedBox
//
//  Created by Athul Sai on 22/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MedCell.h"
#import "ViewController.h"

@implementation MedCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Check Date

-(BOOL)isGreaterThanDate:(NSDate *)date and:(NSDate *)toDate {
    
    NSTimeInterval dateInterval = [date timeIntervalSince1970];
    NSTimeInterval toDateInterval = [toDate timeIntervalSince1970];
    
    if(dateInterval > toDateInterval){
        return YES;
    }
    else {
        return NO;
    }
    
}

#pragma mark - Image Methods

- (UIImage*)loadImage :(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithString: name] ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Cell Content

- (void)updateCellWithReminder:(Reminder *)reminder
{
    _nameLabel.text = reminder.name;
    _descriptionLabel.text = [NSString stringWithFormat:@"%@ %@", reminder.strength, reminder.form];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a, dd MMMM"];
    if(reminder.repeat){
        [formatter setDateFormat:@"hh:mm a"];
        _timeLabel.text = [NSString stringWithFormat:@"Daily at %@", [formatter stringFromDate:reminder.start]];
    }
    else {
        //[formatter setDateFormat:@"HH:mm a on dd MMMM YY"];
        _timeLabel.text = [NSString stringWithFormat:@"Once at %@", [formatter stringFromDate:reminder.start]];
        
    }
    
    if (reminder.imageName.length)
    {
        __block UIImage *iconImage = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            iconImage = [self imageWithImage:[self loadImage:reminder.imageName] scaledToSize:_iconImageView.frame.size];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _iconImageView.image = iconImage;
            });
        });
    }
    else
        _iconImageView.image = [UIImage imageNamed:@"Appointments"];
    
    if(reminder.imageName.length) {
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.clipsToBounds = YES;
        //_iconImageView.layer.borderColor = [[UIColor lightTextColor]CGColor];
        //_iconImageView.layer.borderWidth = 2.0;
        _iconImageView.layer.cornerRadius = 2.0;
        _iconImageView.layer.masksToBounds = YES;
    }
        
    BOOL isOverDue = [self isGreaterThanDate:[NSDate date] and:reminder.start];
    UIColor * color = [UIColor colorWithRed:0/255.0f green:149/255.0f blue:65/255.0f alpha:1.0f];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:_timeLabel.text];
    NSString *string1 = [_timeLabel.text substringWithRange:NSMakeRange(0, 8)];
    
    if((isOverDue == YES)&&(reminder.repeat == NO)) {
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8,[string length]-[string1 length])];
        _timeLabel.attributedText = string;
    }
    else
    {
        [string addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(8,[string length]-[string1 length])];
        _timeLabel.attributedText = string;
    }
}

@end
