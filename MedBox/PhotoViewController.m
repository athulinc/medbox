//
//  PhotoViewController.m
//  MedBox
//
//  Created by Athul Sai on 03/08/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

- (IBAction)handleSingleTap:(UIButton*)tapGestureRecognizer;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setUpScrollView];
    [self customNavBar];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollView.bounds),
                                      CGRectGetMidY(self.scrollView.bounds));
    [self view:self.detailImageView setCenter:centerPoint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Load Methods

- (void)setUpScrollView {
    
    _detailImageView.image = _dImage;
    _scrollView.contentSize = _detailImageView.bounds.size;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate=self;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    [singleTap setNumberOfTapsRequired:1];
    
    [self.scrollView addGestureRecognizer:singleTap];
    
}

- (void)customNavBar {
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = NO;
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@""
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = btnBack;
    
    
}

- (IBAction)handleSingleTap:(UIGestureRecognizer *)tapGestureRecognizer {
    
    if(self.navigationController.navigationBar.hidden) {
        self.navigationController.navigationBar.hidden = NO;
        
    } else {
        self.navigationController.navigationBar.hidden = YES;
    }
}

#pragma mark - Pinch and Zoom Methods

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _detailImageView;
}

- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.scrollView.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    self.scrollView.contentOffset = co;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
