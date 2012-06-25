//
//  RecordViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "RecordViewController.h"
#import "Record+Modification.h"
#import "TextInputFilter.h"
#import "Record.h"
#import "Formation.h"
#import "Bedding.h"
#import "Contact.h"
#import "JointSet.h"
#import "JointSet+Description.h"
#import "Fault.h"
#import "Other.h"

#import "StrikePickerViewController.h"
#import "DipPickerViewController.h"
#import "DipDirectionPickerViewController.h"
#import "PlungePickerViewController.h"
#import "TrendPickerViewController.h"

@interface RecordViewController() <UINavigationControllerDelegate,StrikePickerDelegate,DipPickerDelegate,DipDirectionPickerDelegate,PlungePickerDelegate,TrendPickerDelegate>

@property (weak,nonatomic) IBOutlet UIToolbar *toolbar;

- (void)updateSplitViewBarButtonPresenterWith:(UIBarButtonItem *)splitViewBarButtonItem;
- (void)userDoneEditingRecord;         //handles when user finishes editing the record's info
- (void)resignAllTextFieldsAndAreas;

@property (nonatomic) BOOL editing;
@property (nonatomic,readonly) NSArray *textFields;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//=====================================UI elements=======================================//

@property (weak, nonatomic) IBOutlet UIImageView *recordImage;
@property (weak, nonatomic) IBOutlet UILabel *recordTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *recordNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *recordLatitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordLongitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (weak, nonatomic) IBOutlet UITextField *strikeTextField;
@property (weak, nonatomic) IBOutlet UITextField *dipTextField;
@property (weak, nonatomic) IBOutlet UITextField *formationTextField;
@property (weak, nonatomic) IBOutlet UITextField *dipDirectionTextField;
@property (weak, nonatomic) IBOutlet UITextView *fieldObservationTextArea;
@property (weak, nonatomic) IBOutlet UILabel *formationLabel;
@property (weak, nonatomic) IBOutlet UILabel *strikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dipDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *trendLabel;
@property (weak, nonatomic) IBOutlet UITextField *trendTextField;
@property (weak, nonatomic) IBOutlet UILabel *plungeLabel;
@property (weak, nonatomic) IBOutlet UITextField *plungeTextField;
@property (weak, nonatomic) IBOutlet UILabel *lowerFormationLabel;
@property (weak, nonatomic) IBOutlet UITextField *lowerFormationTextField;
@property (weak, nonatomic) IBOutlet UILabel *upperFormationLabel;
@property (weak, nonatomic) IBOutlet UITextField *upperFormationTextField;

//=========================================================================================//

//==================================Form Setup methods for UI elements=======================================//

- (void)formSetupForBeddingType;
- (void)formSetupForContactType;
- (void)formSetupForJointSetType;
- (void)formSetupForFaultType;
- (void)formSetupForOtherType;

- (void)updateFormForRecord:(Record *)record;

//===========================================================================================================//

@end

@implementation RecordViewController
@synthesize scrollView = _scrollView;

@synthesize record=_record;

@synthesize recordImage = _recordImage;
@synthesize recordTypeLabel = _recordTypeLabel;
@synthesize recordNameTextField = _recordNameTextField;
@synthesize recordLatitudeLabel = _recordLatitudeLabel;
@synthesize recordLongitudeLabel = _recordLongitudeLabel;
@synthesize recordDateLabel = _recordDateLabel;
@synthesize recordTimeLabel = _recordTimeLabel;
@synthesize strikeTextField = _strikeTextField;
@synthesize dipTextField = _dipTextField;
@synthesize dipDirectionTextField = _dipDirectionTextField;
@synthesize dipLabel = _dipLabel;
@synthesize formationTextField = _formationTextField;
@synthesize dipDirectionLabel = _dipDirectionLabel;
@synthesize trendLabel = _trendLabel;
@synthesize trendTextField = _trendTextField;
@synthesize plungeLabel = _plungeLabel;
@synthesize plungeTextField = _plungeTextField;
@synthesize lowerFormationLabel = _lowerFormationLabel;
@synthesize lowerFormationTextField = _lowerFormationTextField;
@synthesize upperFormationLabel = _upperFormationLabel;
@synthesize upperFormationTextField = _upperFormationTextField;
@synthesize fieldObservationTextArea = _fieldObservationTextArea;
@synthesize formationLabel = _formationLabel;
@synthesize strikeLabel = _strikeLabel;

@synthesize editing=_editing;

@synthesize toolbar=_toolbar;
@synthesize splitViewBarButtonItem=_splitViewBarButtonItem;

@synthesize delegate=_delegate;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    //Update the bar button presenter
    [self updateSplitViewBarButtonPresenterWith:splitViewBarButtonItem];
    
    _splitViewBarButtonItem=splitViewBarButtonItem;
}

- (void)setRecord:(Record *)record {
    _record=record;
    
    //Update the text fields and labels
    [self updateFormForRecord:self.record];
}

- (void)updateSplitViewBarButtonPresenterWith:(UIBarButtonItem *)splitViewBarButtonItem {
    //Add the button to the toolbar
    NSMutableArray *items=[self.toolbar.items mutableCopy];
    
    //Remove the old button if it exists
    if (self.splitViewBarButtonItem)
        [items removeObject:self.splitViewBarButtonItem];
        
    //Add the new button on the leftmost if it's not nil
    if (splitViewBarButtonItem)
        [items insertObject:splitViewBarButtonItem atIndex:0];
    
    //Set the items to be the toolbar's items
    self.toolbar.items=[items copy];
}

- (NSArray *)textFields {
    return [NSArray arrayWithObjects:self.recordNameTextField,self.strikeTextField,self.dipTextField,self.dipDirectionTextField,self.formationTextField,self.trendTextField,self.plungeTextField,self.lowerFormationTextField,self.upperFormationTextField, nil];
}

- (BOOL)inEdittingMode {
    return self.editing;
}

//Creates and returns the user-modified info dictionary
- (NSDictionary *)dictionaryFromForm {
    //Create a NSDictionary with the user-modified information
    NSMutableDictionary *recordDictionary=[NSMutableDictionary dictionary];
    [recordDictionary setObject:self.recordNameTextField.text forKey:RECORD_NAME];
    //[recordDictionary setObject:self.recordLatitudeLabel.text forKey:RECORD_LATITUDE];
    //[recordDictionary setObject:self.recordLongitudeLabel.text forKey:RECORD_LONGITUDE];
    //[recordDictionary setObject:self.recordDateLabel.text forKey:RECORD_DATE];
    //[recordDictionary setObject:self.recordTimeLabel.text forKey:RECORD_TIME];
    [recordDictionary setObject:self.strikeTextField.text forKey:RECORD_STRIKE];
    [recordDictionary setObject:self.dipTextField.text forKey:RECORD_DIP];
    [recordDictionary setObject:self.dipDirectionTextField.text forKey:RECORD_DIP_DIRECTION];
    [recordDictionary setObject:self.formationTextField.text forKey:RECORD_FORMATION];
    [recordDictionary setObject:self.fieldObservationTextArea.text forKey:RECORD_FIELD_OBSERVATION];
    
    //Specific update for specific of records
    [recordDictionary setObject:self.plungeTextField.text forKey:RECORD_PLUNGE];
    [recordDictionary setObject:self.trendTextField.text forKey:RECORD_TREND];
    [recordDictionary setObject:self.lowerFormationTextField.text forKey:RECORD_LOWER_FORMATION];
    [recordDictionary setObject:self.upperFormationTextField.text forKey:RECORD_UPPER_FORMATION];
    
    return [recordDictionary copy];
}

- (void)userDoneEditingRecord {
    //Pass the user-modified info dictionary to the delegate for processing
    [self.delegate recordViewController:self userDidModifyRecord:self.record withNewRecordInfo:[self dictionaryFromForm]];
}

//Resign all text fields and text areas
- (void)resignAllTextFieldsAndAreas {
    [self.textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
    [self.fieldObservationTextArea resignFirstResponder];
}

#pragma mark - Gesture Handlers

- (void)dismissKeyboard:(UITapGestureRecognizer *)tapGesture {
    //dismiss the keyboard
    [self resignAllTextFieldsAndAreas];
}

#pragma mark - Target-Action Handlers

- (IBAction)editPressed:(UIBarButtonItem *)sender {
    //Toggle the editting mode
    [self setEditing:!self.editing animated:YES];
    
    //Change the style of the button to edit or done
    sender.style=self.editing ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    sender.title=self.editing ? @"Done" : @"Edit";
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:YES];
    
    //If the record name is empty, focus on its text field and the user wants the editing mode
    self.recordNameTextField.text=[TextInputFilter filterDatabaseInputText:self.recordNameTextField.text];
    if (![self.recordNameTextField.text length] && !editing) 
        [self.recordNameTextField becomeFirstResponder];
    
    //Else proceed as normal
    else {
        _editing=editing;
        
        //If in editing mode, enable all the text fields; otherwise, disable them (YES is 1, NO is 0)
        for (UITextField *textField in self.textFields)
            textField.enabled=self.editing;
        
        //Enable or disable the text area
        self.fieldObservationTextArea.editable=editing;
        self.fieldObservationTextArea.backgroundColor=self.editing ? [UIColor whiteColor] : [UIColor clearColor];
        
        if (editing) {
            //Make the background color of the textfields white
            [self.textFields makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor whiteColor]];
            
            //Add border to the textfields
            for (UITextField *textField in self.textFields)
                textField.borderStyle=UITextBorderStyleRoundedRect;
            
        } else {
            //Make the background color of the textfields clear
            [self.textFields makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor]];
            
            //Remove borders of the textfields
            for (UITextField *textField in self.textFields)
                textField.borderStyle=UITextBorderStyleNone;
            
            //Proceed to editing the record with the user-modified info
            [self userDoneEditingRecord];
        }
    }
}

- (IBAction)acquireData:(UIBarButtonItem *)sender {
}

- (IBAction)browsePressed:(UIBarButtonItem *)sender {
}

- (IBAction)takePhoto:(UIBarButtonItem *)sender {
}

#pragma mark - Handles when the keyboard slides up

- (void)registerForKeyboardNotifications {
    //Get the NSNotificationCenter and set self up to receive notifications when the keyboard slides in and slides out
    NSNotificationCenter *notiCenter=[NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self 
                   selector:@selector(keyboardDidAppear:) 
                       name:UIKeyboardDidShowNotification 
                     object:nil];
    
    [notiCenter addObserver:self 
                   selector:@selector(keyboardWillHide:) 
                       name:UIKeyboardDidHideNotification 
                     object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    //If the UITextArea is currently the first responder (the keyboard caller), scroll it to visible
    if (self.fieldObservationTextArea.isFirstResponder) {
        //Get the info dictionary sent with the notification and get the size of the keyboard from it
        NSDictionary *notificationInfo=[notification userInfo];
        CGSize keyboardSize=[[notificationInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        //Set the insets of the scroll view to fit the keyboard
        UIEdgeInsets contentInsets=UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
        self.scrollView.contentInset=contentInsets;
        self.scrollView.scrollIndicatorInsets=contentInsets;
        CGRect aRect=self.view.frame;
        aRect.size.height-=keyboardSize.height;
        if (!CGRectContainsPoint(aRect, self.fieldObservationTextArea.frame.origin)) {
            CGPoint scrollPoint=CGPointMake(0.0,keyboardSize.height-self.fieldObservationTextArea.frame.origin.y);
            [self.scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets=UIEdgeInsetsZero;
    self.scrollView.contentInset=contentInsets;
    self.scrollView.scrollIndicatorInsets=contentInsets;
}

#pragma mark - Target-Action Handlers for picker-using text fields

- (IBAction)textFieldDidBeginEdit:(UITextField *)sender {
    //Dismiss the keyboard
    [sender resignFirstResponder];
}

#pragma mark - Delegate methods for all Picker View Controller protocols

- (void)strikePickerViewController:(StrikePickerViewController *)sender 
          userDidSelectStrikeValue:(NSString *)strike
{
    //Set the strike text field's text
    self.strikeTextField.text=strike;
}

- (void)dipPickerViewController:(DipPickerViewController *)sender 
          userDidSelectDipValue:(NSString *)dip
{
    //Set the dip text field's text
    self.dipTextField.text=dip;
}

- (void)dipDirectionPickerViewController:(DipDirectionPickerViewController *)sender 
          userDidSelectDipDirectionValue:(NSString *)dipDirection
{
    //Set the dip direction text field's text
    self.dipDirectionTextField.text=dipDirection;
}

- (void)trendPickerViewController:(TrendPickerViewController *)sender 
          userDidSelectTrendValue:(NSString *)trend
{
    //Set the trend text field's text
    self.trendTextField.text=trend;
}

- (void)plungePickerViewController:(PlungePickerViewController *)sender 
          userDidSelectPlungeValue:(NSString *)plunge
{
    //Set the plunge text field's text
    self.plungeTextField.text=plunge;
}

#pragma mark - UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)newMaster animated:(BOOL)animated {
    //Change the splitview button's title if it exists
    if (self.splitViewBarButtonItem)
        self.splitViewBarButtonItem.title=newMaster.navigationItem.title;
}

#pragma mark - Prepare for segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //Strike picker segue
    NSSet *pickerSegueIdentifiers=[NSSet setWithObjects:@"Strike Picker",@"Dip Picker",@"Dip Direction Picker",@"Plunge Picker",@"Trend Picker", nil];
    if ([pickerSegueIdentifiers containsObject:segue.identifier]) {
        //Set self as the delegate of the popup Strike Picker
        [segue.destinationViewController setDelegate:self];
    }
    
    //Controls whether the PickerVC popovers would pass initial values back when they appear
    if ([segue.identifier isEqualToString:@"Strike Picker"]) {
        //Will send initial value to strike picker text field only if its value is currently 0
        [segue.destinationViewController setInitialSelectionEnabled:[self.strikeTextField.text isEqualToString:@"0"]];
    } else if ([segue.identifier isEqualToString:@"Dip Picker"]) {
        //Will send initiali value to dip text field only if its value is currently 0
        [segue.destinationViewController setInitialSelectionEnabled:[self.dipTextField.text isEqualToString:@"0"]];
    } else if ([segue.identifier isEqualToString:@"Dip Direction Picker"]) {
        //Will send initial value to dip direction text field only if it's currently blank (no direction selected)
        [segue.destinationViewController setInitialSelectionEnabled:![self.dipDirectionTextField.text length]];
    } else if ([segue.identifier isEqualToString:@"Trend Picker"]) {
        //Will send initial value to trend text field only if it's currently blank (no value selected)
        [segue.destinationViewController setInitialSelectionEnabled:![self.trendTextField.text length]];
    } else if ([segue.identifier isEqualToString:@"Plunge Picker"]) {
        //Will send initial value to plunge picker text field only if it's currently blank
        [segue.destinationViewController setInitialSelectionEnabled:![self.plungeTextField.text length]];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
        
    //Update the form
    [self updateFormForRecord:self.record];
    
    //Set self up to receive notifications when the keyboard appears and disappears (to adjust the text fields and areas when keyboard shows up)
    [self registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated   
{
    [super viewWillAppear:animated];
    
    //Set self to be the master's navigation controller's delegate to change the button's title when a push segue in master happens
    UINavigationController *masterNavigation=[self.splitViewController.viewControllers objectAtIndex:0];
    masterNavigation.delegate=self;
    
    //Update the bar button presenter if self.splitViewBarButtonItem exists (transferred from somewhere else when this vc got segued to)
    [self updateSplitViewBarButtonPresenterWith:self.splitViewBarButtonItem];
    
    //Add double tap recognizer (a double tap outside the text fields or text areas will dismiss the keyboard)
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //If self is still in editing mode, notify the delegate before going off screen
    if (self.editing && [self.delegate respondsToSelector:@selector(userDidNavigateAwayFrom:whileModifyingRecord:withNewRecordInfo:)]) {
        //If the delegate has not been deallocated yet, pass the user-modified info to it
        if (self.delegate)
            [self.delegate userDidNavigateAwayFrom:self whileModifyingRecord:self.record withNewRecordInfo:[self dictionaryFromForm]];
    }
}

- (void)viewDidUnload {
    [self setRecordImage:nil];
    [self setRecordTypeLabel:nil];
    [self setRecordNameTextField:nil];
    [self setRecordLatitudeLabel:nil];
    [self setRecordLongitudeLabel:nil];
    [self setRecordDateLabel:nil];
    [self setRecordTimeLabel:nil];
    [self setStrikeTextField:nil];
    [self setDipTextField:nil];
    [self setFormationTextField:nil];
    [self setDipDirectionTextField:nil];
    [self setFieldObservationTextArea:nil];
    [self setFormationLabel:nil];
    [self setStrikeLabel:nil];
    [self setDipLabel:nil];
    [self setDipDirectionLabel:nil];
    [self setScrollView:nil];
    [self setTrendLabel:nil];
    [self setTrendTextField:nil];
    [self setPlungeLabel:nil];
    [self setPlungeTextField:nil];
    [self setLowerFormationLabel:nil];
    [self setLowerFormationTextField:nil];
    [self setUpperFormationLabel:nil];
    [self setUpperFormationTextField:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Set up the record form for each individual type of record

- (void)updateFormForRecord:(Record *)record {
    //Reset all the textfields to empty strings
    [self.textFields makeObjectsPerformSelector:@selector(setText:) withObject:@""];
    
    //Clear the color of the field observation text area
    self.fieldObservationTextArea.backgroundColor=[UIColor clearColor];
    
    //Hide the formation, trend, plunge. lower, upper formations textfields and will put them up again if the record type requires them (WHITELISTING)
    NSSet *hiddenFields=[NSSet setWithObjects:self.trendTextField,self.trendLabel,self.plungeLabel,self.plungeTextField,self.formationLabel,self.formationTextField,self.lowerFormationLabel,self.lowerFormationTextField,self.upperFormationLabel,self.upperFormationTextField, nil];
    [hiddenFields makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
    
    //Fill in the information from the record
    self.recordNameTextField.text=self.record.name ? self.record.name : @"";
    self.recordLatitudeLabel.text=self.record.latitude;
    self.recordLongitudeLabel.text=self.record.longitude;
    self.strikeTextField.text=[NSString stringWithFormat:@"%@",self.record.strike];
    self.dipTextField.text=[NSString stringWithFormat:@"%@",self.record.dip];
    self.dipDirectionTextField.text=self.record.dipDirection ? self.record.dipDirection : @"";
    self.fieldObservationTextArea.text=self.record.fieldOservations ? self.record.fieldOservations : @"";
    self.recordTypeLabel.text=[self.record.class description];
    
    //Setup the textfields and labels depending on the type of record
    if ([record isKindOfClass:[Bedding class]]) {
        [self formSetupForBeddingType];
    } else if ([record isKindOfClass:[Contact class]]) {
        [self formSetupForContactType];
    } else if ([record isKindOfClass:[Fault class]]) {
        [self formSetupForFaultType];
    } else if ([record isKindOfClass:[JointSet class]]) {
        [self formSetupForJointSetType];
    } else if ([record isKindOfClass:[Other class]]) {
        [self formSetupForOtherType];
    }    
}

- (void)formSetupForBeddingType {
    Bedding *bedding=(Bedding *)self.record;
    
    //Show the formation label and formation textfield set the textfield's value
    self.formationLabel.hidden=NO;
    self.formationTextField.hidden=NO;
    self.formationTextField.text=bedding.formation ? bedding.formation.formationName : @"";
}

- (void)formSetupForContactType {
    //Show the plunge and trend text labels and text fields
    NSSet *showedFields=[NSSet setWithObjects:self.plungeLabel,self.plungeTextField,self.trendTextField,self.trendLabel, nil];
    [showedFields makeObjectsPerformSelector:@selector(setHidden:) withObject:nil];
    
    //Setup the two text fields
    Contact *contact=(Contact *)self.record;
    self.lowerFormationTextField.text=contact.lowerFormation ? contact.lowerFormation.formationName : @"";
    self.upperFormationTextField.text=contact.upperFormation ? contact.upperFormation.formationName : @"";
}

- (void)formSetupForJointSetType {
    //Show the formation label and text field
    self.formationTextField.hidden=NO;
    self.formationLabel.hidden=NO;
    
    //Set the formation text field
    JointSet *jointSet=(JointSet *)self.record;
    self.formationTextField.text=jointSet.formation ? jointSet.formation.formationName : @"";
}

- (void)formSetupForFaultType {
    Fault *fault=(Fault *)self.record;
    
    //Show the trend, plunge and formation labels and text fields
    NSSet *showedFields=[NSSet setWithObjects:self.plungeLabel,self.plungeTextField,self.trendLabel,self.trendTextField,self.formationLabel,self.formationTextField, nil];
    [showedFields makeObjectsPerformSelector:@selector(setHidden:) withObject:nil];
    
    //Set the trend and plunge text fields
    self.plungeTextField.text=fault.plunge ? fault.plunge : @"";
    self.trendTextField.text=fault.trend ? fault.trend : @"";

    //Set the formation text field
    self.formationTextField.text=fault.formation ? fault.formation.formationName : @"";    
}

- (void)formSetupForOtherType {
    //Hide all the textfields except for the name textfield
    [self.textFields makeObjectsPerformSelector:@selector(setHidden:) withObject:nil];
    self.recordNameTextField.hidden=NO;
    
    //Hide the strike, dip, and dip direction
    NSSet *hiddenFields=[NSSet setWithObjects:self.strikeLabel,self.strikeTextField,self.dipLabel,self.dipTextField,self.dipDirectionLabel,self.dipDirectionTextField, nil];
    [hiddenFields makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES]];
}

@end