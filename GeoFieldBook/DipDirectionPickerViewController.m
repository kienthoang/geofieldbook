//
//  DipDirectionPickerViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/24/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "DipDirectionPickerViewController.h"

@interface DipDirectionPickerViewController() <UIPickerViewDelegate>

@end

@implementation DipDirectionPickerViewController

@synthesize delegate=_delegate;

- (NSArray *)dipDirectionComponentMatrix {
    //First component
    NSArray *firstComponent=[NSArray arrayWithObjects: DIP_DIRECTION_PICKER_BLANK_OPTION,@"N", @"NE", @"E",@"SE" , @"S", @"SW", @"W", @"NW", nil];
    
    return [NSArray arrayWithObjects:firstComponent, nil];
}

- (void)handleUserSelection {
    [super handleUserSelection];
    
    //Notify the delegate of user selection if user did not select blank option; otherwise pass an empty stirng to the delegate
    NSString *userSelection=[[self userSelection] isEqualToString:DIP_DIRECTION_PICKER_BLANK_OPTION] ? @"" : [self userSelection];
    [self.delegate dipDirectionPickerViewController:self userDidSelectDipDirectionValue:userSelection];
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //Handle selection
    [self handleUserSelection];
}


#pragma mark - View Controller Lifecycles

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //Set up the component matrix
    self.componentMatrix=[self dipDirectionComponentMatrix];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
