//
//  GeoMapDelegate.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/4/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

@protocol GeoMapDelegate <NSObject>

- (NSArray *)recordsForMapViewController:(UIViewController *)mapViewController;
- (void)mapViewController:(UIViewController *)mapViewController userDidSelectAnnotationForRecord:(Record *)record switchToDataView:(BOOL)willSwitchToDataView;

@optional

- (void)mapViewControllerDidAppearOnScreen:(UIViewController *)mapViewController;
- (void)mapViewControllerDidDisappear:(UIViewController *)mapViewController;
- (void)mapViewController:(UIViewController *)mapViewController userDidUpdateRecordTypeFilterList:(NSArray *)selectedRecordTypes;

@end
