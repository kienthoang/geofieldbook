//
//  FolderSelectTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolderTableViewControllerPrototype.h"

#import "FolderSelectTableViewControllerDelegate.h"

@interface FolderSelectTableViewController : FolderTableViewControllerPrototype

@property (nonatomic,weak) id <FolderSelectTableViewControllerDelegate> delegate;

@end
