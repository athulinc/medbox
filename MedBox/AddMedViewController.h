//
//  AddMedViewController.h
//  MedBox
//
//  Created by Athul Sai on 17/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"

@protocol AddMedViewControllerDelegate <NSObject>

@optional
- (void)addNewReminder:(Reminder *)reminder;
- (void)didEditReminder;

@end


@interface AddMedViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) id <AddMedViewControllerDelegate> delegate;
@property (strong, nonatomic) Reminder *editObject;
@property (nonatomic, assign) BOOL isEdit;

@end
