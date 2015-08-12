//
//  ViewController.m
//  MedBox
//
//  Created by Athul Sai on 17/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import "ViewController.h"
#import "MedCell.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Tableview
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self loadMedObjects];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont fontWithName:kFontFutura size:18.0]};
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self setupNavBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localNotifReceived) name:kNotificationLocalNotifReceived object:nil];
    [self.tableView reloadData];
    if (_medObjects.count == 0) {
        [self showNoContentMessage];
    } else {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavBar
{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:34.0/255.0 green:77.0/255.0 blue:144.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont fontWithName:kFontFutura size:18.0]};
}


#pragma mark - medObjects methods

- (NSMutableArray *)medObjects {
    
    if (!_medObjects) {
        _medObjects = [[NSMutableArray alloc] init];
    }
    
    return _medObjects;
}

- (void)loadMedObjects
{
    NSArray *remAsPropertyLists = [[NSUserDefaults standardUserDefaults] arrayForKey:MED_OBJECTS_KEY];
    
    for (NSDictionary *dictionary in remAsPropertyLists) {
        Reminder *remObject = [[Reminder alloc] initWithData:dictionary];
        [self.medObjects addObject:remObject];
    }
}


#pragma mark - Actions

- (void)localNotifReceived
{
    [_tableView reloadData];
}

- (IBAction)addButtonPressed:(UIBarButtonItem *)sender {
    AddMedViewController *addController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([AddMedViewController class])];
    addController.delegate = self;
    addController.isEdit = NO;
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:addController];
    [self presentViewController:navC animated:YES completion:nil];
}

- (IBAction)reorderButtonPressed:(UIBarButtonItem *)sender {
    [_tableView setEditing:!_tableView.editing animated:YES];
}

#pragma mark - Set Notification

-(void)scheduleLocalNotificationForReminder:(Reminder *)reminder {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc]init];
    localNotif.alertTitle = @"Medicine Alert";
    localNotif.alertBody = [NSString stringWithFormat:@"You have set a reminder to take %@ - %@.", reminder.name, reminder.form];
    localNotif.fireDate = reminder.start;
    localNotif.repeatInterval = reminder.repeat ? NSCalendarUnitDay : 0;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.userInfo = @{kMedUserInfo: reminder.remId};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

#pragma mark - AddMedViewControllerDelegate

- (void)addNewReminder:(Reminder *)reminder {
    
    [self.medObjects insertObject:reminder atIndex:0];
    
    
    // Load reminder dict from NSUserDefaults
    NSMutableArray *medObjectAsPropertyLists = [[[NSUserDefaults standardUserDefaults]arrayForKey:MED_OBJECTS_KEY]mutableCopy];
    if (!medObjectAsPropertyLists)
        medObjectAsPropertyLists = [[NSMutableArray alloc] init];
    [medObjectAsPropertyLists insertObject:[self medObjectAsPropertyList:reminder] atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:medObjectAsPropertyLists forKey:MED_OBJECTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    // Schedule reminders for future dates
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    for(int i = 0;i < _medObjects.count;i++) {
        Reminder *reminder = _medObjects[i];
        if ([reminder.start compare:[NSDate date]] == NSOrderedDescending || reminder.repeat)
            [self scheduleLocalNotificationForReminder:reminder];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}


#pragma mark - DetailMedViewControllerDelegate

- (void)updateDatasource {
    
    [self saveRemindersInUserDefaults];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    for(int i = 0;i < _medObjects.count;i++) {
        Reminder *reminder = _medObjects[i];
        if ([reminder.start compare:[NSDate date]] == NSOrderedDescending || reminder.repeat)
            [self scheduleLocalNotificationForReminder:reminder];
    }
    [self.tableView reloadData];
}


#pragma mark - Helper Methods

-(NSDictionary *)medObjectAsPropertyList:(Reminder *)medObject {
    
    NSDictionary *dictionary = @{MED_ID: medObject.remId,
                                 MED_NAME: medObject.name,
                                 MED_FORM: medObject.form,
                                 MED_STRENGTH: medObject.strength,
                                 MED_NOTES: medObject.notes,
                                 MED_TIME_DATE: medObject.start,
                                 MED_IMAGE: medObject.imageName,
                                 MED_REPEAT: @(medObject.repeat)};
    
    return dictionary;
}

-(void)saveRemindersInUserDefaults {
    
    NSMutableArray *medObjectsAsPropertyLists = [[NSMutableArray alloc] init];
    for(int x = 0; x<[self.medObjects count]; x++) {
        [medObjectsAsPropertyLists addObject:[self medObjectAsPropertyList:self.medObjects[x]]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:medObjectsAsPropertyLists forKey:MED_OBJECTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - TableView Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.medObjects count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MedCell";
    MedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell)
        cell = [[MedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    Reminder *remObject = self.medObjects[indexPath.row];
    [cell updateCellWithReminder:remObject];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showDetailForReminder:self.medObjects[indexPath.row]];
}

- (void)showDetailForReminder:(Reminder *)reminder
{
    DetailViewController *detailController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([DetailViewController class])];
    detailController.remObject = reminder;
    detailController.delegate = self;
    
    [self.navigationController pushViewController:detailController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        
        Reminder *rem =  _medObjects[indexPath.row];
        if(rem.imageName.length) {
            [self removeImage:rem.imageName];
        }
        [self.medObjects removeObjectAtIndex:indexPath.row];
        
        
        NSMutableArray *newMedObjects = [[NSMutableArray alloc]init];
        
        for(Reminder *rem in self.medObjects){
            
            [newMedObjects addObject:[self medObjectAsPropertyList:rem]];
            
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:newMedObjects forKey:MED_OBJECTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        for(int i = 0;i < _medObjects.count;i++) {
            
            Reminder *reminder = _medObjects[i];
            if ([reminder.start compare:[NSDate date]] == NSOrderedDescending || reminder.repeat)
                [self scheduleLocalNotificationForReminder:reminder];
        }

        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //Check for empty reminder list
        if (_medObjects.count == 0) {
            [self showNoContentMessage];
        } 
        
    }
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"toDetailView" sender:indexPath];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    Reminder *remObject = self.medObjects[sourceIndexPath.row];
    [self.medObjects removeObjectAtIndex:sourceIndexPath.row];
    [self.medObjects insertObject:remObject atIndex:destinationIndexPath.row];
    [self saveRemindersInUserDefaults];
    
}

- (void)showNoContentMessage
{
    //create a lable size to fit the Table View
    UILabel *messageLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                    self.tableView.bounds.size.width,
                                                                    self.tableView.bounds.size.height)];
    messageLbl.text = @"No reminders to show.\n Please add medication.";
    messageLbl.textAlignment = NSTextAlignmentCenter;
    messageLbl.numberOfLines = 0;
    messageLbl.font = [UIFont fontWithName:kFontGeezaPro size:16.0];
    messageLbl.textColor = [UIColor grayColor];
    [messageLbl sizeToFit];
    
    self.tableView.backgroundView = messageLbl;
    //No separator
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Remove Image

- (void)removeImage:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (!success) {
        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong!" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [removeSuccessFulAlert show];
    }
    
}

@end
