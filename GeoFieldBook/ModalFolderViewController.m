//
//  ModalFolderViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "ModalFolderViewController.h"

@interface ModalFolderViewController()

@property (weak, nonatomic) IBOutlet UITextField *folderNameTextField;

@end

@implementation ModalFolderViewController
@synthesize folderNameTextField = _folderNameTextField;

@synthesize delegate=_delegate;
@synthesize folderName=_folderName;

- (void)setFolderName:(NSString *)folderName {
    if (_folderName!=folderName) {
        _folderName=folderName;
        self.folderNameTextField.text=self.folderName;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the text field's text to the folder name if the folder name is not nil
    if ([self.folderName length])
        self.folderNameTextField.text=self.folderName;
    
    //Add tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    tapGestureRecognizer.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Focus on the folder name text field
    [self.folderNameTextField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setFolderNameTextField:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view. (generated automatically by xcode)
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Target-Action Handlers

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)confirmPressed:(UIBarButtonItem *)sender {
    //if the folder name text field is blank, focus on it
    if (![self.folderNameTextField.text length])
        [self.folderNameTextField becomeFirstResponder];
    
    //Else call the delegate and pass on the name of the folder
    else {
        //If the folder name has not been set before
        if (![self.folderName length]) {
            self.folderName=self.folderNameTextField.text;
            [self.delegate modalFolderViewController:self 
                               obtainedNewFolderName:self.folderNameTextField.text];
        } else {
            NSString *originalName=self.folderName;
            self.folderName=self.folderNameTextField.text;
            [self.delegate modalFolderViewController:self 
                            didAskToModifyFolderName:originalName 
                          obtainedModifiedFolderName:self.folderName];
        }
    }
}

#pragma mark - Gesture Handlers

- (void)hideKeyBoard:(UITapGestureRecognizer *)tapGesture {
    //Dismiss keyboard
    [self.folderNameTextField resignFirstResponder];
}

@end