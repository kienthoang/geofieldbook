//
//  ExportFormationFolderTableViewController.h
//  GeoFieldBook
//
//  Created by excel2011 on 7/16/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "PrototypeFormationFolderTableViewController.h"
#import "UIDoubleTableViewController.h"
#import "UIDoubleTableViewControllerChildren.h"

@interface ExportFormationFolderTableViewController : PrototypeFormationFolderTableViewController <UIDoubleTableViewControllerChildren>

@property (nonatomic,strong) NSArray *selectedFormations;

@end
