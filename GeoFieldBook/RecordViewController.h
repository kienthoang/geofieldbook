//
//  RecordViewController.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 6/22/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "CoreLocation/CoreLocation.h"
#import "Record+Creation.h"
#import "Record+DictionaryKeys.h"
#import "Image.h"
#import "Record+DateAndTimeFormatter.h"

#import "RecordViewControllerDelegate.h"

@interface RecordViewController : UIViewController

@property (nonatomic,strong) Record *record;
@property (nonatomic,weak) id <RecordViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (NSDictionary *)dictionaryFromForm;
- (BOOL) isInEdittingMode;

#define RECORD_DEFAULT_GPS_STABLILIZING_INTERVAL_LENGTH 12

@end
