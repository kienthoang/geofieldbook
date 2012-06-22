//
//  FolderTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/21/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface FolderTableViewController : CoreDataTableViewController <SplitViewBarButtonItemPresenter>       //Making this inherit the FetchedResultsController from CoreDataTVC

@property (nonatomic,strong) UIManagedDocument *database;   //The database to fetch folders from

@end
