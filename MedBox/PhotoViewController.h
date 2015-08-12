//
//  PhotoViewController.h
//  MedBox
//
//  Created by Athul Sai on 03/08/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) UIImage *dImage;

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint;

@end
