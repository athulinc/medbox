//
//  DetailViewController.h
//  MedBox
//
//  Created by Athul Sai on 23/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reminder.h"
#import "AddMedViewController.h"
#import "PhotoViewController.h"


@protocol DetailViewControllerDelegate <NSObject>

@optional
- (void)updateDatasource;

@end

@interface DetailViewController : UIViewController <AddMedViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) Reminder *remObject;
@property (weak, nonatomic) id <DetailViewControllerDelegate> delegate;

@end
