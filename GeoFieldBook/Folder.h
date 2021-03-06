//
//  Folder.h
//  GeoFieldBook
//
//  Created by Kien Hoang on 8/15/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Formation_Folder, Record;

@interface Folder : NSManagedObject

@property (nonatomic, retain) NSString * folderDescription;
@property (nonatomic, retain) NSNumber * folderID;
@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSNumber * prefixEnabled;
@property (nonatomic, retain) NSString * prefixText;
@property (nonatomic, retain) NSNumber * prefixCounter;
@property (nonatomic, retain) Formation_Folder *formationFolder;
@property (nonatomic, retain) NSSet *records;
@end

@interface Folder (CoreDataGeneratedAccessors)

- (void)addRecordsObject:(Record *)value;
- (void)removeRecordsObject:(Record *)value;
- (void)addRecords:(NSSet *)values;
- (void)removeRecords:(NSSet *)values;

@end
