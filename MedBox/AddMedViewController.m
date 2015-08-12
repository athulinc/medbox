//
//  AddMedViewController.m
//  MedBox
//
//  Created by Athul Sai on 17/07/15.
//  Copyright (c) 2015 Incture Technologies. All rights reserved.
//

#import "AddMedViewController.h"

@interface AddMedViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *formField;
@property (weak, nonatomic) IBOutlet UITextField *strengthField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UISwitch *dailySwitch;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *dateTimeField;
@property (weak, nonatomic) IBOutlet UIImageView *picView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UITextField *activeText;
@property (strong, nonatomic) UIView *datePickerContainer;

@property (nonatomic, assign) CGFloat animatedDistance;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *oldDate;
@property (nonatomic, strong) NSString *picName;
@property (nonatomic, assign) BOOL hasChanged;

@end

@implementation AddMedViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //Add the top right button
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self addGestures];
    [self.notesTextView setDelegate:self];
    [self styleFormElements];
    [self initializeTextFieldInputView];
    [self checkEdit];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self customizeNavBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Load Methods

- (void)addGestures {
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageOptions:)];
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tapOnView:)];
    [self.view addGestureRecognizer: tapRec];
    
    [singleTap setNumberOfTapsRequired:1];
    [_imageView addGestureRecognizer:singleTap];
    
}

- (void)styleFormElements {
    
    _imageView.layer.cornerRadius = 8.0;
    _imageView.layer.masksToBounds = YES;
    
    self.notesTextView.layer.borderWidth = 1;
    [self.notesTextView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.notesTextView.layer setBorderColor: [[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0] CGColor]];
    [self.notesTextView.layer setBorderWidth: 0.8];
    [self.notesTextView.layer setCornerRadius:5.0f];
    [self.notesTextView.layer setMasksToBounds:YES];
    
}

- (void)checkEdit {
    
    if(_isEdit) {
        
        _nameField.text = _editObject.name;
        _formField.text = _editObject.form;
        _strengthField.text = _editObject.strength;
        _notesTextView.text = _editObject.notes;
        _imageView.image = _editObject.imageName.length ? [self loadImage:_editObject.imageName]:[UIImage imageNamed:@"Appointments"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-YYYY hh:mm a"];
        _dateTimeField.text = [formatter stringFromDate:_editObject.start];
        [self.dailySwitch setOn:_editObject.repeat animated:YES];
        
    }
}

- (void)customizeNavBar
{
    // Set title
    if(_isEdit) {
        self.navigationItem.title = @"Edit Drug";
    } else {
        self.navigationItem.title = @"Add Drug";
    }
    // Set nav bar color
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:34.0/255.0 green:77.0/255.0 blue:144.0/255.0 alpha:1.0];
    // Set text colors
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont fontWithName:kFontFutura size:18.0]};
    
    // Add cancel button
    if(!_isEdit) {
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dissmissView)];
    
        self.navigationItem.leftBarButtonItem = cancel;
    } else {
        self.navigationController.navigationBar.topItem.backBarButtonItem.title = @"Back";
    }
}

- (void) initializeTextFieldInputView {
    NSDate *now = [NSDate date];
    UIDatePicker *dP = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    dP.datePickerMode = UIDatePickerModeDateAndTime;
    dP.minuteInterval = 1;
    dP.minimumDate = now;
    dP.maximumDate = [now dateByAddingTimeInterval: 604811];
    dP.backgroundColor = [UIColor whiteColor];
    [dP setDate:now animated:NO];
    
    
    [dP addTarget:self action:@selector(dateUpdated:) forControlEvents:UIControlEventValueChanged];
    self.dateTimeField.inputView = dP;
}

- (void)dissmissView {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Show Date Picker

- (void) dateUpdated:(UIDatePicker *)datePicker {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy hh:mm a"];
    self.dateTimeField.text = [formatter stringFromDate:datePicker.date];
    _selectedDate = datePicker.date;
}

#pragma mark - Tap Gesture Actions

- (IBAction)showImageOptions:(UIButton *)sender {
    
    UIAlertController *controller =
    [UIAlertController alertControllerWithTitle:@"Photo Options"
                                        message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *delAction = [UIAlertAction actionWithTitle:@"Delete Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *act){
        if(_editObject.imageName.length){
            [self removeImage:_editObject.imageName];
            _editObject.imageName = @"";
            _imageView.image = [UIImage imageNamed:@"Appointments"];
        }
    }];
    UIAlertAction *takeAction =
    [UIAlertAction actionWithTitle:@"Take Photo"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action){
                                 UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                                              init];
                                 pickerController.delegate = self;
                                 // Set nav bar color
                                 pickerController.navigationBar.barTintColor = [UIColor colorWithRed:34.0/255.0 green:77.0/255.0 blue:144.0/255.0 alpha:1.0];
                                 // Set text colors
                                 pickerController.navigationBar.tintColor = [UIColor whiteColor];
                                 
                                 pickerController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
                                 pickerController.allowsEditing = YES;
                                 if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                     
                                     UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Can't take photo"
                                                                                           message:@"Sorry, this device has no camera!"
                                                                                          delegate:nil
                                                                                 cancelButtonTitle:@"OK"
                                                                                 otherButtonTitles: nil];
                                     
                                     [myAlertView show];
                                     
                                 }
                                 else {
                                     pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                 }
                                 
                                 
                                 [self presentViewController:pickerController animated:YES completion:nil];
                           }];
    UIAlertAction *selectAction = [UIAlertAction actionWithTitle:@"Select Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                     init];
        pickerController.delegate = self;
        // Set nav bar color
        pickerController.navigationBar.barTintColor = [UIColor colorWithRed:34.0/255.0 green:77.0/255.0 blue:144.0/255.0 alpha:1.0];
        // Set text colors
        pickerController.navigationBar.tintColor = [UIColor whiteColor];
        
        pickerController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:kFontFutura size:18.0]};
        pickerController.allowsEditing = YES;
        [self presentViewController:pickerController animated:YES completion:nil];
    }];

    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleCancel handler:nil];
    
    if(_editObject.imageName.length) {
        [controller addAction:delAction];
    }
    [controller addAction:takeAction];
    [controller addAction:selectAction];
    [controller addAction:noAction];
    UIPopoverPresentationController *ppc =
    controller.popoverPresentationController;
    if (ppc != nil) {
        ppc.sourceView = sender;
        ppc.sourceRect = sender.bounds;
    }
    [self presentViewController:controller animated:YES completion:nil];

}

-(void)tapOnView:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}

#pragma mark - Image Picker

-(void)imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    self.imageView.image = image;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yy_HH:mm:ss"];
    NSDate *now = [NSDate date];
    _picName = [NSString stringWithFormat:@"%@.png",[formatter stringFromDate:now]];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Create Reminder Object

-(Reminder *)createReminderObject {
    
    Reminder *remObject = [[Reminder alloc]init];
    remObject.remId = [NSString stringWithFormat:@"%@", self.selectedDate];
    remObject.name = self.nameField.text;
    remObject.form = self.formField.text;
    remObject.strength = self.strengthField.text;
    remObject.notes = self.notesTextView.text;
    remObject.start = self.selectedDate;
    remObject.repeat = self.dailySwitch.isOn;
    remObject.imageName = self.picName.length ? self.picName : @"";
    
    return remObject;
}


#pragma mark - Save Action

-(void)saveAction
{
    if((_nameField.text.length<3)||(_formField.text.length<3)||(_strengthField.text.length<3)||
        (_dateTimeField.text.length<6)) {
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Input Required"
                                                          message:@"Please enter name, form, strength and set reminder."
                                                         delegate:nil
                                                cancelButtonTitle:@"Got It!"
                                                otherButtonTitles:nil];
        
        [message show];
    }
    else if(_isEdit){
        if(_editObject.imageName.length){
            if(_picName.length){
                [self removeImage:_editObject.imageName];
            }
        }
        if(_picName.length)
            [self saveImage:_imageView.image];
        
        [self updateReminder];
        [self.delegate didEditReminder];
        
    } else {
        if(_picName.length){
            [self saveImage:_imageView.image];
        }
        [self.delegate addNewReminder:[self createReminderObject]];
    }

}

-(void)saveImage: (UIImage*)image
{

    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:_picName];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
    
}

#pragma mark - Image Handling

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

#pragma mark - Edit Action

- (void)updateReminder {
    
    self.editObject.name = _nameField.text;
    self.editObject.form = _formField.text;
    self.editObject.strength = _strengthField.text;
    self.editObject.notes = _notesTextView.text;
    //NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    //[dateFormat setDateFormat:@"dd-MM-YYYY hh:mm a"];
    //NSDate *date = [dateFormat dateFromString:_dateTimeField.text];
    if(_hasChanged) {
        self.editObject.start = self.selectedDate;
    }
    self.editObject.repeat = _dailySwitch.isOn;
    if(_isEdit) {
        self.editObject.imageName = self.picName.length ? self.picName : _editObject.imageName;
    } else {
        self.editObject.imageName = self.picName.length ? self.picName : @"";
    }

}
#pragma mark - Keyboard Methods

- (void)textFieldDidBeginEditing:(UITextField *)sender
{
    self.activeText = sender;
    if(sender == _dateTimeField) {
        _hasChanged = YES;
    }
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender
{
    self.activeText = nil;
}

// Called when the UIKeyboardDidShowNotification is received
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    // keyboard frame is in window coordinates
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect keyboardInfoFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // get the height of the keyboard by taking into account the orientation of the device too
    CGRect windowFrame = [self.view.window convertRect:self.view.frame fromView:self.view];
    CGRect keyboardFrame = CGRectIntersection (windowFrame, keyboardInfoFrame);
    CGRect coveredFrame = [self.view.window convertRect:keyboardFrame toView:self.view];
    
    // add the keyboard height to the content insets so that the scrollview can be scrolled
    UIEdgeInsets contentInsets = UIEdgeInsetsMake (0.0, 0.0, coveredFrame.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // make sure the scrollview content size width and height are greater than 0
//    [self.scrollView setContentSize:CGSizeMake (self.scrollView.frame.size.width, self.scrollView.contentSize.height)];
    
    // scroll to the text view
    if (self.activeText)
        [self.scrollView scrollRectToVisible:self.activeText.frame animated:YES];
    else
        [self.scrollView scrollRectToVisible:self.notesTextView.frame animated:YES];
    
}

- (void) keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField) {
        [textField resignFirstResponder];
        [self.formField becomeFirstResponder];
    }
    else if (textField == self.formField) {
        [textField resignFirstResponder];
        [self.strengthField becomeFirstResponder];
    }
    else if (textField == self.strengthField) {
        [textField resignFirstResponder];
        [self.notesTextView becomeFirstResponder];
        
        return NO;
        
    }
    return YES;
}

/*
#pragma mark - Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView  {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    if (component == kNumComponent) {
        return [self.desTypes count];
    } else {
        return [self.numTypes count];
    }
}

#pragma mark - Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    if (component == kNumComponent) {
        return self.desTypes[row];
    } else {
        return self.numTypes[row];
    } }
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
