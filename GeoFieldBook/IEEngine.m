//
//  IEEngine.m
//  GeoFieldBook
//
//  Created by excel 2012 on 7/9/12.
//  Copyright (c) 2012 Lafayette College. All rights reserved.
//

#import "IEEngine.h"

#import "TransientRecord.h"
#import "TransientFault.h"
#import "TransientBedding.h"
#import "TransientContact.h"
#import "TransientJointSet.h"
#import "TransientOther.h"
#import "TransientFormation.h"
#import "TransientImage.h"
#import "TransientFormation_Folder.h"
#import "TransientProject.h"

#import "ValidationMessageBoard.h"

#import "IEEngineNotificationNames.h"

#import "TextInputFilter.h"

#import "ExportFormatter.h"

@interface IEEngine()

@property (nonatomic, strong) NSArray *selectedFilePaths;
@property (nonatomic, strong) NSMutableArray *records;
@property (nonatomic, strong) NSMutableArray *formations;
@property (nonatomic, strong) NSDictionary *foldersByFolderNames;
@property (nonatomic, strong) NSArray *formationFolders;

@property (nonatomic, strong) ValidationMessageBoard *validationMessageBoard;

@end

@implementation IEEngine

@synthesize handler=_handler;
@synthesize selectedFilePaths=_selectedFilePaths;
@synthesize records=_records;
@synthesize formations=_formations;
@synthesize foldersByFolderNames=_foldersByFolderNames;
@synthesize formationFolders=_formationFolders;

@synthesize validationMessageBoard=_validationMessageBoard;

//enum for columnHeadings
typedef enum columnHeadings{Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, dipDirection, Observations, FormationField, LowerFormation, UpperFormation, Trend, Plunge, imageName}columnHeadings;

#pragma mark - Getters

-(NSMutableArray *) projects {
    if(!_records) 
        _records = [[NSMutableArray alloc] init];
    
    return _records;
}

-(NSMutableArray *) formations {
    if(!_formations) 
        _formations = [[NSMutableArray alloc] init];
    
    return _formations;
}

- (NSArray *)formationFolders {
    if (!_formationFolders)
        _formationFolders=[NSArray array];
    
    return _formationFolders;
}

- (ValidationMessageBoard *)validationMessageBoard {
    if (!_validationMessageBoard)
        _validationMessageBoard=[[ValidationMessageBoard alloc] init];
    
    return _validationMessageBoard;
}

- (NSMutableArray *)records {
    if (!_records)
        _records=[NSMutableArray array];
    return _records;
}

#pragma mark - Notification Management Mechanisms

- (void)postNotificationWithName:(NSString *)notificationName withUserInfo:(NSDictionary *)userInfo {
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:notificationName object:self userInfo:userInfo];
}

#pragma mark - Data Managers

- (NSDate *)dateFromDateToken:(NSString *)dateToken andTimeToken:(NSString *)timeToken {
    //Get date and time components and create a NSDate from them
    NSArray *dateComponents = [dateToken componentsSeparatedByString:@"/"];
    NSArray *timeComponents = [timeToken componentsSeparatedByString:@":"];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    //Set the date components
    comps.year=[[NSString stringWithFormat:@"20%@",[dateComponents objectAtIndex:2]] intValue];
    comps.month=[[dateComponents objectAtIndex:0] intValue];
    comps.day=[[dateComponents objectAtIndex:1] intValue];
    
    //Set the time components
    comps.hour=[[timeComponents objectAtIndex:0] intValue];
    comps.minute=[[timeComponents objectAtIndex:1] intValue];
    comps.second=[[timeComponents objectAtIndex:2] intValue];
    
    //Create a NSDate obj from the date and time components
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:comps];
}

- (NSData *)imageInDocumentDirectoryForName:(NSString *)imageFileName {
    NSData *imageData=nil;
    
    //to set the image, first get the image from the images directory
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentsDirectory = [urlArray.lastObject path];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:imageFileName];
    
    //Get the image data if the file exists
    if([fileManager fileExistsAtPath:imageFilePath])
        imageData=[NSData dataWithContentsOfFile:imageFilePath];
    
    return imageData;
}

#pragma mark - Record Importing

- (TransientRecord *)recordForTokenArray:(NSArray *)tokenArray withFolderName:(NSString *)folderName {
    //Initialize the transient record
    NSString *typeToken=[tokenArray objectAtIndex:1];
    TransientRecord *transientRecord=[TransientRecord recordWithType:typeToken];
    NSString *errorMessage=nil;
    
    //Populate the common fields for all the records and save the errors messages if there's any
    //Populate the name
    transientRecord.name = [tokenArray objectAtIndex:Name];
    
    //Set the strike value with validations
    if ((errorMessage=[transientRecord setStrikeWithValidations:[tokenArray objectAtIndex:Strike]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the dip value with validations
    if ((errorMessage=[transientRecord setDipWithValidations:[tokenArray objectAtIndex:Dip]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];

    //Set the dip direction value with validations
    if ((errorMessage=[transientRecord setDipDirectionWithValidations:[tokenArray objectAtIndex:dipDirection]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the field observation value with validations
    if ((errorMessage=[transientRecord setFieldObservationWithValidations:[tokenArray objectAtIndex:Observations]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the latitude value with validations
    if ((errorMessage=[transientRecord setLatitudeWithValidations:[tokenArray objectAtIndex:Latitude]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Set the longitude value with validations
    if ((errorMessage=[transientRecord setLongitudeWithValidations:[tokenArray objectAtIndex:Longitude]]))
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
    
    //Populate the date field
    NSString *dateToken = [[tokenArray objectAtIndex:Date] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *timeToken = [[tokenArray objectAtIndex:Time] stringByReplacingOccurrencesOfString:@" " withString:@""];
    transientRecord.date = [self dateFromDateToken:dateToken andTimeToken:timeToken];
    
    //Set the image of the record using the given image file name in the csv file
    NSData *imageData=[self imageInDocumentDirectoryForName:[tokenArray objectAtIndex:imageName]];
    if (imageData) {
        TransientImage *image=[[TransientImage alloc] init];
        image.imageData=imageData;
        transientRecord.image=image;
    }
    
    //Set the folder
    transientRecord.folder=[self.foldersByFolderNames objectForKey:folderName];
    
    //identify the record type and populate record specific fields
    if([typeToken isEqualToString:@"Contact"]) {
        TransientContact *contact=(TransientContact *)transientRecord;
        
        //Set lower formation
        TransientFormation *lowerFormation=[[TransientFormation alloc] init];
        lowerFormation.formationName=[tokenArray objectAtIndex:LowerFormation];
        [contact setLowerFormation:lowerFormation];
        
        //Set upper formation
        TransientFormation *upperFormation=[[TransientFormation alloc] init];
        upperFormation.formationName=[tokenArray objectAtIndex:UpperFormation];
        [contact setUpperFormation:upperFormation];
    } else if ([typeToken isEqualToString:@"Bedding"]) {
        TransientBedding *bedding=(TransientBedding *)transientRecord;
        
        //Set formation
        TransientFormation *formation=[[TransientFormation alloc] init];
        formation.formationName=[tokenArray objectAtIndex:FormationField];
        [bedding setFormation:formation];
    } else if([typeToken isEqualToString:@"Joint Set"]) {
        TransientJointSet *jointSet=(TransientJointSet *)transientRecord;
        
        //Set formation
        TransientFormation *formation=[[TransientFormation alloc] init];
        formation.formationName=[tokenArray objectAtIndex:FormationField];
        [jointSet setFormation:formation];
    } else if([typeToken isEqualToString:@"Fault"]) {        
        //Set the plunge and trend (need to populate name in case validaiton error occurs)
        TransientFault *transientFault=(TransientFault *)transientRecord;
        transientFault.name = [tokenArray objectAtIndex:Name];
        if ((errorMessage=[transientFault setPlungeWithValidations:[tokenArray objectAtIndex:Plunge]]))
            [self.validationMessageBoard addErrorWithMessage:errorMessage];
        if ((errorMessage=[transientFault setTrendWithValidations:[tokenArray objectAtIndex:Trend]]))
            [self.validationMessageBoard addErrorWithMessage:errorMessage];
        
        //Set formation
        TransientFormation *formation=[[TransientFormation alloc] init];
        formation.formationName=[tokenArray objectAtIndex:FormationField];
        [(TransientFault *)transientRecord setFormation:formation];
    } else if([typeToken isEqualToString:@"Other"]) {
        //Nothing to populate
    }
        
    return transientRecord;
}

- (NSArray *)constructRecordsFromCSVFileWithPath:(NSString *)path {
    NSMutableArray *transientRecords=[NSMutableArray array];;
    
    //Get all the token arrays 9each of them corresponding to a line in the csv file)
    NSMutableArray *tokenArrays = [self tokenArraysFromFile:path].mutableCopy;
    
    //Remove the first token array which contains the column headings
    [tokenArrays removeObjectAtIndex:0];
    
    //Now create transient records from the rest
    for(NSArray *tokenArray in tokenArrays) {
        
        //If the current token array does not have enough tokens, add an error message to the message board
        if(tokenArray.count!=NUMBER_OF_COLUMNS_PER_RECORD_LINE)
            [self.validationMessageBoard addErrorWithMessage:@"Invalid CSV File Format. Please ensure that your csv file has the required format."];
        
        //Else, process the token array and contruct a corresponding transient record
        else {
            //Create a transient record from the token array
            NSString *folderName=[[path.lastPathComponent componentsSeparatedByString:@"."] objectAtIndex:0];
            TransientRecord *record=[self recordForTokenArray:tokenArray withFolderName:folderName];
            
            //add the record to the array of records
            [transientRecords addObject:record];
        }
    }
    
    return transientRecords.copy;
}

- (NSDictionary *)createFoldersFromCSVFiles:(NSArray *)files {
    NSMutableDictionary *foldersByFolderNames=[NSMutableDictionary dictionaryWithCapacity:files.count];
    for (NSString *csvFile in files) {
        //Create a folder with the folder name specified in the csv file
        NSString *folderName=[[csvFile componentsSeparatedByString:@"."] objectAtIndex:0];
        TransientProject *folder=[[TransientProject alloc] init];
        folder.folderName=folderName;
        
        //Add it the dictionary as value with its name as key
        [foldersByFolderNames setObject:folder forKey:folderName];
    }
    
    return foldersByFolderNames.copy;
}

/*
 Column Headings:
 "Name, Type, Longitude, Latitude, Date, Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \r\n"
 */
-(void)createRecordsFromCSVFiles:(NSArray *)files
{   
    //Post a notification
    [self postNotificationWithName:GeoNotificationIEEngineRecordImportingDidStart withUserInfo:[NSDictionary dictionary]];
    
    //get paths to the selected files
    self.selectedFilePaths = [self getSelectedFilePaths:files];
    
    //Create the folders
    self.foldersByFolderNames=[self createFoldersFromCSVFiles:files];
    
    //Iterate through each csv files and create transient records from each of them
    for (NSString *path in self.selectedFilePaths) {
        //Construct the records
        NSArray *records=[self constructRecordsFromCSVFileWithPath:path];
        
        //Add them to self.records
        [self.records addObjectsFromArray:records];
    }
    
   
    //now call the handler and pass it the array of records created ... 
    //If there is any error message, pass nil to the handler as well as the error log
    if (self.validationMessageBoard.errorCount) {
        [self.handler processTransientRecords:nil 
                                   andFolders:nil
                     withValidationMessageLog:self.validationMessageBoard.allMessages];
        
        //Reset the validation message board
        [self.validationMessageBoard clearBoard];
    }
    else {
        [self.handler processTransientRecords:self.records 
                                   andFolders:self.foldersByFolderNames.allValues 
                     withValidationMessageLog:self.validationMessageBoard.warningMessages];

    }
}

#pragma mark - Reading of Formation files

- (void)constructFormationsFromCSVFilePath:(NSString *)path {
    //this is an array lines, which is an array of tokens
    NSMutableDictionary *formationImportMatrix = [self formationImportMatrixFromFile:path].mutableCopy;
        
    //for each array of tokens 
    NSMutableArray *formationFolders=self.formationFolders.mutableCopy;
    for (int index=0;index<tokenArrays.count;index++) {
        //Create one formation for each line
        NSMutableArray *tokenArray=[[tokenArrays objectAtIndex:index] mutableCopy];
        NSString *folder = [tokenArray objectAtIndex:0];
        [tokenArray removeObjectAtIndex:0];
        TransientFormation_Folder *newFormationFolder = [[TransientFormation_Folder alloc] init];
        newFormationFolder.folderName = [TextInputFilter filterDatabaseInputText:folder];
        
        //Save the newly created transient formation folder
        [formationFolders addObject:newFormationFolder];
        
        //Keep track of the sort number (formations will be sorted by the order they are in the csv file)
        int sortNumber=1;
        
        //for each token(formation) in such an array of line record(formation folder)
        for (NSString *formation in tokenArray) {
            //if the formation name is not empty
            NSString *formationName=[TextInputFilter filterDatabaseInputText:formation];
            if (formationName.length) {
                TransientFormation *newFormation = [[TransientFormation alloc] init];
                newFormation.formationFolder = newFormationFolder;
                newFormation.formationName = formationName;
                newFormation.formationSortNumber=[NSNumber numberWithInt:sortNumber++];
                [self.formations addObject:newFormation];
            }
        }
    }
    
    self.formationFolders=formationFolders.copy;
}

- (void)createFormationsFromCSVFiles:(NSArray *)files
{
    //Post a notification
    [self postNotificationWithName:GeoNotificationIEEngineFormationImportingDidStart withUserInfo:[NSDictionary dictionary]];
    
    //get the complete file paths for the selected files that exist
    self.selectedFilePaths=[self getSelectedFilePaths:files];
    
    //read each of those files line by line and create the formation objects and add it to self.formations array.
    for(NSString *path in self.selectedFilePaths) {
        //Construct formations from the file path
        [self constructFormationsFromCSVFilePath:path];
    }
    
       
    //If there is any error message, pass nil to the handler as well as the error log
    if (self.validationMessageBoard.errorCount)
        [self.handler processTransientFormations:nil 
                             andFormationFolders:nil
                        withValidationMessageLog:self.validationMessageBoard.allMessages];
    else
        [self.handler processTransientFormations:self.formations.copy 
                             andFormationFolders:self.formationFolders 
                        withValidationMessageLog:self.validationMessageBoard.warningMessages];
}

#pragma mark - CSV File Parsing

-(NSDictionary *)formationImportMatrixFromFile:(NSString *)filePath
{
    //if file does not exist, add the error message to the validation message board
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]) {
        NSString *errorMessage=[NSString stringWithFormat:@"CSV File with name %@ cannot be found!",filePath.lastPathComponent];
        [self.validationMessageBoard addErrorWithMessage:errorMessage];
        return nil;
    }
    
    //Dictionary: key-column headings (folder_name_key,folder name, @"Red",@"Blue",@"Green")
    NSMutableDictionary *formationImportMatrix = [NSMutableDictionary dictionary];
    
    //read the contents of the file
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    //get all lines in the file
    NSArray *allLines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    //fix the case where newline characters (record separators) appear in the data field themselves
    allLines = [self fixNewLineCharactersInData:allLines];
    
    //Skip blank lines and parse the rest
    for(int index=0;index<allLines.count;index++) {
        NSString *line=[allLines objectAtIndex:index];
        if (line.length) {
            NSMutableArray *tokenArray=[self tokenArrayForLine:line].mutableCopy;
            NSString *firstToken=[tokenArray objectAtIndex:0];
            [tokenArray removeObject:firstToken];
            
            //If the dictionary does not contain a key-value entry for the folder name, create it
            if (![formationImportMatrix objectForKey:IMPORT_MATRIX_FOLDER_NAME])
                [formationImportMatrix setObject:firstToken forKey:IMPORT_MATRIX_FOLDER_NAME];
            
            //Set the rest as a whole token array
            [formationImportMatrix setObject:tokenArray.copy forKey:firstToken];
            
        }
    }
    
    return formationImportMatrix.copy;
}

-(NSArray *)getSelectedFilePaths:(NSArray *)fileNames;
{   
    //Get the document directory path
    NSMutableArray *paths = [NSMutableArray array];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentDirPath = [urlArray.lastObject path];
    
    //Get the csv file paths from the document directory
    for (NSString *fileName in fileNames)
        [paths addObject:[documentDirPath stringByAppendingPathComponent:fileName]];
    
    return paths.copy;
}

- (NSArray *)tokenArrayForLine:(NSString *)line
{
    //Get tokens from each line
    NSMutableArray *tokenArray = [line componentsSeparatedByString:@","].mutableCopy;
    tokenArray = [self separateRecordsOrFieldsByCountingQuotations:tokenArray byAppending:@","];
        
    //Filter each token (get rid of extra quotation marks or any auxiliary, csv-added symbols)
    NSArray *filteredTokenArray=[self filterTokenArray:tokenArray.copy];
    
    return filteredTokenArray;
}
-(NSMutableArray *) fixNewLineCharactersInData:(NSArray *)records {
    return [self separateRecordsOrFieldsByCountingQuotations:records byAppending:@"\n"];
}

-(NSMutableArray *) separateRecordsOrFieldsByCountingQuotations:(NSArray *) array byAppending:(NSString *) separator {
    NSString *merged=@"";
    NSString *current=@"";
    BOOL repeat=NO;
    NSMutableArray *copy = [array mutableCopy];
    do {
        repeat = NO;
        int length = copy.count;
        for(int i = 0; i<length; i++) {
            current = [copy objectAtIndex:i];
            int quotes = [[current componentsSeparatedByString:@"\""] count]-1; //number of quotes
            if(quotes%2) { // if odd, merge with the next string value
                merged = [current stringByAppendingFormat:@"%@%@",separator,[copy objectAtIndex:i+1]];
                [copy replaceObjectAtIndex:i withObject:merged];
                [copy removeObjectAtIndex:i+1];
                repeat = YES;
                length = copy.count;
                break;
            }
        }
    } while (repeat);
        
    return copy;
}

- (NSArray *)filterTokenArray:(NSArray *)tokenArray {
    NSMutableArray *mutableTokenArray=tokenArray.mutableCopy;
    for (int i=0;i<tokenArray.count;i++) {
        NSString *token=[tokenArray objectAtIndex:i];
        [mutableTokenArray replaceObjectAtIndex:i withObject:[TextInputFilter stringFromCSVCompliantString:token]];
    }        
    
    return mutableTokenArray.copy;
}

#pragma mark - Creation of CSV files

-(void) createCSVFilesFromRecords:(NSArray *)records
{
    //Use a set so that we won't get any folder duplicates
    NSMutableSet *folders = [NSMutableSet set];
    
    //get the names of the folders from the array of records so you could create them
    for(Record *record in records)
        [folders addObject:record.folder.folderName];
        
    //Get the document directory path
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentDirPath = [urlArray.lastObject path];
    
    //create an dictionary of filehandlers. Key - folder name, Value - FileHandler for that folder
    NSMutableDictionary *fileHandlers = [NSMutableDictionary dictionary];
    NSMutableDictionary *mediaDirectories = [NSMutableDictionary dictionary];
    
    //for each project name, create a project folder in the documents directory with the same name. if the folder already exists, empty it. also create a media folder with the same name inside the directory
    for(NSString *newFolder in folders.allObjects) {
        //first create the paths
        NSString *dataDirectory = [documentDirPath stringByAppendingPathComponent:newFolder];
        NSString *mediaDirectory = [dataDirectory stringByAppendingPathComponent:@"media"];
        [mediaDirectories setObject:mediaDirectory forKey:newFolder]; 
        NSString *csvFileName=[NSString stringWithFormat:@"%@.record.csv",newFolder];
        NSString *dataFile = [dataDirectory stringByAppendingPathComponent:csvFileName];
        
        //then create the directories...
        //create the data directory if not there already
        if (![fileManager fileExistsAtPath:dataDirectory])
            [fileManager createDirectoryAtPath:dataDirectory withIntermediateDirectories:NO attributes:nil error:NULL]; 
        else {
            //If the folder already, delete it and recreate it
            [fileManager removeItemAtPath:dataDirectory error:NULL];
            [fileManager createDirectoryAtPath:dataDirectory withIntermediateDirectories:NO attributes:nil error:NULL];             
        }
        
        //Create the media directory
        [fileManager createDirectoryAtPath:mediaDirectory withIntermediateDirectories:NO attributes:nil error:NULL];
        
        //create the file if it does not exist
        if(![fileManager fileExistsAtPath:dataFile])
            [fileManager createFileAtPath: dataFile contents:nil attributes:nil];
        NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:dataFile];
        [fileHandlers setObject:handler forKey:newFolder];
        
        //clear all contents of the file
        [handler truncateFileAtOffset:0]; 
        
        //write the column headings to the csv
        NSString *titles = [NSString stringWithFormat:@"Name, Type, Longitude, Latitude, Date,Time, Strike, Dip, Dip Direction, Observations, Formation, Lower Formation, Upper Formation, Trend, Plunge, Image file name \n"];
        [handler writeData:[titles dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //now call the method that writes onto the array of records into their respective csv files
    [self writeRecords:records withFileHandlers:fileHandlers.copy andSaveImagesInPath:mediaDirectories.copy];
    
    //Post a notification when done
    [self postNotificationWithName:GeoNotificationIEEngineExportingDidEnd withUserInfo:[NSDictionary dictionary]];
}

- (void)writeRecord:(Record *)record withFileHandler:(NSFileHandle *)fileHandler mediaDirectoryPath:(NSString *)mediaDirPath {    
    //get all the common fields
    NSString *name = [TextInputFilter csvCompliantStringFromString:record.name];
    NSString *observation = [TextInputFilter csvCompliantStringFromString:record.fieldOservations];
    NSString *longitude = [TextInputFilter csvCompliantStringFromString:record.longitude];
    NSString *latitude = [TextInputFilter csvCompliantStringFromString:record.latitude];
    NSString *dip = [TextInputFilter csvCompliantStringFromString:[NSString stringWithFormat:@"%@", record.dip]];
    NSString *dipDir = [TextInputFilter csvCompliantStringFromString:record.dipDirection];
    NSString *strike = [TextInputFilter csvCompliantStringFromString:[NSString stringWithFormat:@"%@", record.strike]];
        
    //get the date and time
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];        
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init]; 
    [timeFormatter setDateFormat:@"HH:mm:ss"];
    
    NSString *date = [TextInputFilter csvCompliantStringFromString:[dateFormatter stringFromDate:record.date]];
    NSString *time = [TextInputFilter csvCompliantStringFromString:[timeFormatter stringFromDate:record.date]];
    NSString *type = [TextInputFilter csvCompliantStringFromString:[record.class description]];
        
    //now get the type, and type-specific fields   
    NSString *formation=@"";
    NSString *lowerFormation=@"";
    NSString *upperFormation=@"";
    NSString *plunge=@"";
    NSString *trend=@"";
    if([record isKindOfClass:[Bedding class]] || [record isKindOfClass:[JointSet class]] || [record isKindOfClass:[Fault class]]) {
        Formation *recordFormation=[(id)record formation];
        formation = recordFormation ? recordFormation.formationName : @"";
    } else if([record isKindOfClass:[Contact class]]) {
        Formation *recordLowerFormation=[(Contact *)record lowerFormation];
        Formation *recordUpperFormation=[(Contact *)record upperFormation];
        lowerFormation = recordLowerFormation ? recordLowerFormation.formationName : @"";
        upperFormation = recordUpperFormation ? recordUpperFormation.formationName : @"";
    } else if([record isKindOfClass:[Fault class]]) {
        Fault *fault=(Fault *)record;
        plunge = [NSString stringWithFormat:@"%@", fault.plunge];
        trend = [NSString stringWithFormat:@"%@", fault.trend];
    } else if([record isKindOfClass:[Other class]]) {
        //nothing to populate
    }       
    
    //Filter the type-specific fields
    formation=[TextInputFilter csvCompliantStringFromString:formation];
    lowerFormation=[TextInputFilter csvCompliantStringFromString:lowerFormation];
    upperFormation=[TextInputFilter csvCompliantStringFromString:upperFormation];
    plunge=[TextInputFilter csvCompliantStringFromString:plunge];
    trend=[TextInputFilter csvCompliantStringFromString:trend];
    
    //save the image file  
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *imageFileName=@"";
    if(record.image) {                  
       imageFileName = [NSString stringWithFormat:@"%@_%@.jpeg", record.folder.folderName, record.name];
        NSString *imageFilePath = [mediaDirPath stringByAppendingPathComponent:imageFileName];
        if(![fileManager fileExistsAtPath:imageFilePath]){
            [fileManager createFileAtPath:imageFilePath contents:nil attributes:nil];
            
            NSFileHandle *mediaFileHandler = [NSFileHandle fileHandleForWritingAtPath:imageFilePath];
            NSData *image=UIImageJPEGRepresentation([[UIImage alloc] initWithData:record.image.imageData], 1.0);
            [mediaFileHandler writeData:image];
            [mediaFileHandler closeFile];
        }
    }
    
    //finally write the string tokens to the csv file
    NSString *recordData=@"";
    recordData = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
                  name,type,longitude,latitude,date,time,strike,dip,dipDir,observation,formation,lowerFormation,upperFormation,trend,plunge,imageFileName];
    [fileHandler writeData:[recordData dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)writeRecords:(NSArray *)records withFileHandlers:(NSDictionary *)fileHandlers andSaveImagesInPath:(NSDictionary *) mediaDirectories 
{        
    //Get the data from each record
    for(Record *record in records) {
        //Write each record out
        NSString *folderName=record.folder.folderName;
        NSFileHandle *fileHandler=[fileHandlers objectForKey:folderName];
        [self writeRecord:record withFileHandler:fileHandler mediaDirectoryPath:[mediaDirectories objectForKey:folderName]];
    }
    
    //close all the filehandlers
    for(NSFileHandle *handler in [fileHandlers allValues])
        [handler closeFile];
}

#pragma mark - Creation of CSV for formations

-(void) createCSVFilesFromFormations:(NSArray *)formations 
{
    //Get the "export dictionary"
    NSDictionary *formationByFolders=[self formationByFolderDictionaryFromFormations:formations];
    
    //now write the csv files with the transposed 2d array created from the dictionary
    for (NSString *formationFolderName in formationByFolders.allKeys) {
        //Get the matrix to write to file
        NSArray *formations=[formationByFolders objectForKey:formationFolderName];
        NSArray *exportFormationMatrix=[self transposedFormationExportMatrixForFormations:formations withFormationFolderName:formationFolderName];
        
        //Write to file
        [self writeFormationMatrix:exportFormationMatrix withFormationFolderName:formationFolderName];
    }
    
    //Post a notification when done
    [self postNotificationWithName:GeoNotificationIEEngineExportingDidEnd withUserInfo:[NSDictionary dictionary]];
}

- (NSDictionary *)formationByFolderDictionaryFromFormations:(NSArray *)formations {
    //a multiset type data structure. Key-foldername; Value-array of formations for that folder
    NSMutableDictionary *formationsByFolders = [NSMutableDictionary dictionary]; 
    for(Formation *formation in formations) {
        //if the folder name has already been encountered, add to it
        if([formationsByFolders.allKeys containsObject:formation.formationFolder.folderName]) { 
            NSMutableArray *formationArray = [[formationsByFolders objectForKey:formation.formationFolder.folderName] mutableCopy];
            [formationArray addObject:formation];
            [formationsByFolders setObject:formationArray.copy forKey:formation.formationFolder.folderName];
        } else {
            //otherwise create a new array and add to the dictionary with the foldername as the key to that array
            NSMutableArray *formationArray = [NSMutableArray arrayWithObject:formation];
            [formationsByFolders setObject:formationArray.copy forKey:formation.formationFolder.folderName];
        }
    }
    
    return formationsByFolders.copy;
}

- (NSArray *)transposedFormationExportMatrixForFormations:(NSArray *)formations withFormationFolderName:(NSString *)formationFolderName {
    //Get the pre-transposed matrix
    NSArray *exportMatrix=[self formationExportMatrixForFormations:formations withFormationFolderName:formationFolderName];
    
    //Return the transposed version
    return [ExportFormatter transposeTwoDimensionalArray:exportMatrix];
}

- (NSArray *)formationExportMatrixForFormations:(NSArray *)formations withFormationFolderName:(NSString *)formationFolderName {
    //First line: folder name and following list of formation names
    NSMutableArray *formationLine=[NSMutableArray arrayWithObject:formationFolderName];
    
    //Second line: red color components
    NSMutableArray *redColorComponentLine=[NSMutableArray arrayWithObject:@"Red"];
    
    //Third line: blue color components
    NSMutableArray *blueColorComponentLine=[NSMutableArray arrayWithObject:@"Blue"];
    
    //Fourth line: green color components
    NSMutableArray *greenColorComponentLine=[NSMutableArray arrayWithObject:@"Green"];
    
    //Populate the lines
    for (Formation *formation in formations) {
        [formationLine addObject:formation.formationName];
        [redColorComponentLine addObject:[NSString stringWithFormat:@"%d",formation.redColorComponent.intValue]];
        [blueColorComponentLine addObject:[NSString stringWithFormat:@"%d",formation.blueColorComponent.intValue]];
        [greenColorComponentLine addObject:[NSString stringWithFormat:@"%d",formation.greenColorComponent.intValue]];
    }
    
    //Return a two dimensional array from 4 lines
    return [NSArray arrayWithObjects:formationLine.copy,redColorComponentLine.copy,blueColorComponentLine.copy,greenColorComponentLine.copy, nil];
}

-(void)writeFormationMatrix:(NSArray *)formationMatrix withFormationFolderName:(NSString *)formationFolderName {
    //Format the date
    NSDate *current = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yy"];        
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init]; 
    [timeFormatter setDateFormat:@"HH:mm:ss"];

    //create the file in the documents directory
    NSString *formationFileName = [NSString stringWithFormat:@"%@_%@_%@.formation.csv",formationFolderName,[dateFormatter stringFromDate:current], [timeFormatter stringFromDate:current]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *urlsArray = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *documentsDirectory = [urlsArray.lastObject path];
    
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:formationFileName];
    [fileManager createFileAtPath:destinationPath contents:nil attributes:nil];
    NSFileHandle *handler = [NSFileHandle fileHandleForWritingAtPath:destinationPath];
    
    //now write the records to the csv file
    for (NSArray *line in formationMatrix) {
        NSString *csvLine=[line componentsJoinedByString:@", "];
        csvLine=[csvLine stringByAppendingString:@"\r\n"];
        [handler writeData:[csvLine dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [handler closeFile];
}

@end