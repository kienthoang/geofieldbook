//
//  GeoFilter.m
//  GeoFieldBook
//
//  Created by excel2011 on 7/2/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "GeoFilter.h"

@interface GeoFilter()

@property (nonatomic,strong) NSSet *selectedRecordTypes;
@property (nonatomic,strong) NSSet *selectedFolderName;

@end

@implementation GeoFilter

@synthesize selectedRecordTypes=_selectedRecordTypes;
@synthesize selectedFolderName=_selectedFolderName;

- (void)userDidSelectRecordType:(NSString *)recordType {
    //Add the selected record type to the set
    
}

- (void)userDidSelectFolderName:(NSString *)folderName {
    //Add the selected folder name to the set
}

- (NSSet *)selectedRecordTypes {
    return [self.selectedRecordTypes copy];
}

- (NSSet *)selectedFolderNames {
    return [self.selectedFolderName copy];
}

- (NSArray *)filterRecordCollection:(NSArray *)records {
    //iterate through the given records and filter out records of types that were not selected by the user
    
    return nil;
}

@end
