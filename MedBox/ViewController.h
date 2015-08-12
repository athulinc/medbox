//
//  ViewController.h
//  MedBox
//
//  Created by Athul Sai on 17/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMedViewController.h"
#import "DetailViewController.h"

@interface ViewController : UIViewController<AddMedViewControllerDelegate,UITableViewDataSource, UITableViewDelegate,DetailViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *medObjects;

@end

