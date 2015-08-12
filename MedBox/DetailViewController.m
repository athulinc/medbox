//
//  DetailViewController.m
//  MedBox
//
//  Created by Athul Sai on 23/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DetailViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont fontWithName:kFontFutura size:18.0]};
    
    //Remove table footer
     _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self setUpNavBar];
    
    if(_remObject.imageName.length)
    {
        _tableView.tableHeaderView = [self tvHeaderView];
        
    } else {
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    }


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Replace edit with cancel if presented modally
    if (self.presentingViewController)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUpNavBar
{
    self.navigationController.navigationBar.hidden = NO;
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:34.0/255.0 green:77.0/255.0 blue:144.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont fontWithName:kFontFutura size:18.0]};
}

#pragma mark - User Actions

- (IBAction)editTapped:(id)sender {
    AddMedViewController *detailController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AddMedViewController class])];
    
    Reminder *obj = self.remObject;
    detailController.editObject = obj;
    detailController.delegate = self;
    detailController.isEdit = YES;
    
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)detailImageAction {
    
    PhotoViewController *photoController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PhotoViewController class])];
    
    photoController.dImage = _imageView.image;
    
    [self.navigationController pushViewController:photoController animated:YES];
}

#pragma mark - Handle Screen Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self viewWillAppear:YES];
}

#pragma mark - Load Image

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

#pragma mark - Initialize Table View Header

- (UIView *)tvHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.superview.frame.size.width, 140)];
    CGFloat imageWidth = 125;
    CGFloat imageHeight = 125;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_tableView.superview.frame.size.width/2 - imageWidth/2, headerView.frame.size.height/2 - imageHeight/2, imageWidth, imageHeight)];
    _imageView.image = [self loadImage:_remObject.imageName];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.cornerRadius = 10.0;
    _imageView.layer.borderColor = [[UIColor lightTextColor] CGColor];
    _imageView.layer.borderWidth = 5.0;
    _imageView.layer.masksToBounds = YES;
    _imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailImageAction)];
    
    [singleTap setNumberOfTapsRequired:1];
    [_imageView addGestureRecognizer:singleTap];
    [headerView addSubview:_imageView];
    
    return headerView;
}

#pragma mark - Table View Methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 31.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a, dd MMMM YYYY"];
    cell.textLabel.font =  [UIFont fontWithName:kFontGeezaPro size:14.0];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = self.remObject.name;
            break;
        case 1:
            cell.textLabel.text = self.remObject.form;
            break;
        case 2:
            cell.textLabel.text = self.remObject.strength;
            break;
        case 3:
            if(self.remObject.repeat){
                [formatter setDateFormat:@"hh:mm a"];
                cell.textLabel.text = [NSString stringWithFormat:@"Daily at %@", [formatter stringFromDate:self.remObject.start]];
            }
            else {
                //[formatter setDateFormat:@"HH:mm a on dd MMMM YY"];
                cell.textLabel.text = [NSString stringWithFormat:@"Once at %@", [formatter stringFromDate:self.remObject.start]];

            }
            
            break;
        case 4:
            if(_remObject.notes.length == 0)
            {
                cell.textLabel.text = @"You have not added any notes.";
                cell.textLabel.textColor = [UIColor lightGrayColor];
            } else {
                cell.textLabel.text = self.remObject.notes;
            }
            
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Name";
            break;
        case 1:
            sectionName = @"Form";
            break;
        case 2:
            sectionName = @"Strength";
            break;
        case 3:
            sectionName = @"Reminder";
            break;
        case 4:
            sectionName = @"Notes";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // notes row
    if(indexPath.section == 4) {
        UIFont *cellFont = [UIFont fontWithName:kFontGeezaPro size:17.0];
        CGSize constraintSize = CGSizeMake(tableView.frame.size.width - 8*4, CGFLOAT_MAX);
        NSDictionary *fontAttr = @{NSFontAttributeName: cellFont};
        CGRect labelRect = [_remObject.notes boundingRectWithSize:constraintSize options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:fontAttr context:nil];
        //CGSize labelSize = [_remObject.notes sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        
        return labelRect.size.height + 20;    }
    
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(16, 6, 320, 20);
    myLabel.font = [UIFont fontWithName:kFontFutura size:16.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerSecView = [[UIView alloc] init];
    headerSecView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1];
    [headerSecView addSubview:myLabel];
    
    return headerSecView;
    
}

#pragma mark - AddMedViewControllerDelegate

- (void)didEditReminder {
    
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate)
        [self.delegate updateDatasource];
    [self.tableView reloadData];
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
