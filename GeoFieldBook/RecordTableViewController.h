//
//  RecordTableViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Record+Modification.h"
#import "CustomRecordCell.h"

@class RecordTableViewController;

@protocol RecordTVCAutosaverDelegate <NSObject>

typedef void (^autosaver_block_t)(void);

- (void)recordTableViewController:(RecordTableViewController *)sender 
                        showAlert:(UIAlertView *)alertView 
          andExecuteBlockOnCancel:(autosaver_block_t)cancelBlock 
                  andExecuteBlock:(autosaver_block_t)confirmBlock 
         whenClickButtonWithTitle:(NSString *)buttonTitle;
@end

@protocol RecordTableViewControllerDelegate <NSObject>

- (void)recordTableViewController:(RecordTableViewController *)sender 
                needsUpdateFolder:(Folder *)folderName 
           setFormationFolderName:(NSString *)formationFolder;

@end

@interface RecordTableViewController : CoreDataTableViewController

@property (nonatomic,strong) Folder *folder;
@property (nonatomic,strong) UIManagedDocument *database;

@property (nonatomic,weak) id <RecordTVCAutosaverDelegate> autosaveDelegate;
@property (nonatomic,weak) id <RecordTableViewControllerDelegate> delegate;

@end
