//
//  Answer+DateFormatter.m
//  GeoFieldBook
//
//  Created by Kien Hoang on 7/26/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "Answer+DateFormatter.h"

@implementation Answer (DateFormatter)

- (NSString *)day {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/yy";
    return [dateFormatter stringFromDate:self.date];
    
}
- (NSString *)time {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm:ss";
    return [timeFormatter stringFromDate:self.date];
}

@end
