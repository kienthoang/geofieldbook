//
//  SettingsSplitViewController.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "SettingsSplitViewController.h"

#import "MainSettingsTableViewController.h"

#import "IASKAppSettingsViewController.h"
#import "GroupSettingsTableViewController.h"
#import "RecordSettingsTVC.h"

#import "SettingManagerNotificationNames.h"

@interface SettingsSplitViewController() <MainSettingsTableViewControllerDelegate,IASKSettingsDelegate>

@property (nonatomic,readonly) MainSettingsTableViewController *leftSideSettingViewController;
@property (nonatomic,readonly) IASKAppSettingsViewController *rightSideSettingViewController;

@end

@implementation SettingsSplitViewController 

@synthesize delegate=_delegate;

#pragma mark - Getters and Setters

- (MainSettingsTableViewController *)leftSideSettingViewController {
    UINavigationController *masterNav=(UINavigationController *)self.masterViewController;
    return (MainSettingsTableViewController *)masterNav.topViewController;
}

- (UINavigationController *)rightSideNav {
    UINavigationController *detailNav=(UINavigationController *)self.detailViewController;
    return detailNav;
}

- (UIViewController *)rightSideSettingViewController {
    return self.rightSideNav.topViewController;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set the customSplitViewController properties of the master and detail
    if ([self.masterViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *masterNav=(UINavigationController *)self.masterViewController;
        if ([masterNav.topViewController conformsToProtocol:@protocol(CustomSplitViewControllerChildren)]) {
            UIViewController<CustomSplitViewControllerChildren> *masterViewController=(UIViewController<CustomSplitViewControllerChildren> *)masterNav.topViewController;
            masterViewController.customSplitViewController=self;
        }
    }
    
    if ([self.detailViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *detailNav=(UINavigationController *)self.detailViewController;
        if ([detailNav.topViewController conformsToProtocol:@protocol(CustomSplitViewControllerChildren)]) {
            UIViewController<CustomSplitViewControllerChildren> *detailViewController=(UIViewController<CustomSplitViewControllerChildren> *)detailNav.topViewController;
            detailViewController.customSplitViewController=self;
        }
        
        //Set the initial settings for right hand side
        self.rightSideSettingViewController.file=@"Map Symbols";
    }
    
    //Set the title of the right side view controller
    self.rightSideSettingViewController.navigationItem.title=@"Color";
    
    //Set the delegate of the settings tvc
    self.leftSideSettingViewController.delegate=self;
}

#pragma mark - MainSettingsTableViewControllerDelegate methods

- (void)mainSettingsTVC:(MainSettingsTableViewController *)sender userDidSelectSettingPaneWithTitle:(NSString *)paneTitle {
    NSSet *generalPanes=[NSSet setWithObjects:@"Color",@"Map Symbols",@"Feedback",@"Gestures", nil];
    //If the pane title is one of the general pane titles, make sure the general settings vc is on screen, and pass it the pane title
    if ([generalPanes containsObject:paneTitle]) {
        //Push the general settings vc on screen
        if (![self.rightSideSettingViewController isKindOfClass:[IASKAppSettingsViewController class]]) {
            IASKAppSettingsViewController *generalSettingsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"General Settings"];
            [self replaceDetailSideWithViewController:generalSettingsVC];
        }
        
        //Set the .plist file to be loaded of the left side settings tvc to the pane title
         self.rightSideSettingViewController.file=paneTitle;
        
        //Set the title
        self.rightSideSettingViewController.navigationItem.title=paneTitle;
    }
    
    //Else if the pane title is Group Settings, make sure it's on screen
    else if ([paneTitle isEqualToString:@"Group Settings"]) {
        if (![self.rightSideSettingViewController isKindOfClass:[GroupSettingsTableViewController class]]) {
            GroupSettingsTableViewController *groupSettingsVC=[self.storyboard instantiateViewControllerWithIdentifier:@"Group Settings"];
            [self replaceDetailSideWithViewController:groupSettingsVC];
        }
    }
    
    //Else if the pane title is Record Settings
    else if ([paneTitle isEqualToString:@"Record Settings"]) {
        //Push the record settings tvc on screen
        if (![self.rightSideSettingViewController isKindOfClass:[RecordSettingsTVC class]]) {
            UIViewController *recordSettingsNav=[self.storyboard instantiateViewControllerWithIdentifier:@"Record Settings"];
            [self replaceDetailSideWithViewController:recordSettingsNav];
            RecordSettingsTVC *recordSettingsTVC=(RecordSettingsTVC *)self.rightSideSettingViewController;
            recordSettingsTVC.currentFolder=[self.delegate currentFolderTitleForSettingsViewController:self];
        }
    }
}

- (void)userDidSelectGroupSettingsInMainSettingsTVC:(MainSettingsTableViewController *)sender {
    //Segue to the group settings table view
    if (![self.rightSideSettingViewController isKindOfClass:[GroupSettingsTableViewController class]])
        [self.rightSideSettingViewController performSegueWithIdentifier:@"Group Settings" sender:nil];
}

- (void)userDidPressCancel:(MainSettingsTableViewController *)sender {
    //Dismiss self
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - iASKSettingsDelegate Protocol Methods

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender {
    //Broadcast
    [[NSNotificationCenter defaultCenter] postNotificationName:SettingManagerUserPreferencesDidChange object:self];
}

@end
