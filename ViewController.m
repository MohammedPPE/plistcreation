//
//  ViewController.m
//  PlistFileCreation
//
//  Created by RamKumar Balasubramanian on 20/01/15.
//  Copyright (c) 2015 Pearson English. All rights reserved.
//

#import "ViewController.h"
#import "sqlite3.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //PList File Automation
    //NSUserDomaiMask -  User's Current Local Machine Directory
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[paths objectAtIndex:0];
    //Name of the Plist -  going to create
    NSString *filePath=[documentPath stringByAppendingString:@"IndexCount.plist"];
    NSFileManager *fileManager=[NSFileManager defaultManager];

    if(![fileManager fileExistsAtPath:filePath])
    {
        filePath=[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"IndexCount.plist"]];
    }
    //store all the first level Index Objects
    NSMutableArray *firstLevelindex;
    //checking for .sqlite DB -- path in which DB is stored
    NSString* dbFilePath = [[NSBundle mainBundle] pathForResource:@"LDOCE"
                                                         ofType:@"sqlite"];
    firstLevelindex=[NSMutableArray arrayWithObjects:  @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    
    NSMutableDictionary *final=[[NSMutableDictionary alloc]init];
    NSMutableArray *allKeys;
    FMDatabase *db = [FMDatabase databaseWithPath:dbFilePath];
    [db open];
    for(int i=0;i<[firstLevelindex count];i++)
    {
        NSMutableDictionary *sectionTitleAndItsCount=[[NSMutableDictionary alloc]init];
        NSString *currentChar=firstLevelindex[i];
        //adding % with the Current Character
        NSString *currentCharWith=[currentChar stringByAppendingString:@"%"];
        FMResultSet *results = [db executeQuery:@"SELECT DISTINCT upper( substr(updatedhwd, 1, 2) ) FROM lookup where updatedhwd like ?  and (substr(updatedhwd, 2,1)BETWEEN 'A' and 'z')",currentCharWith];
       // TO take the special characters in each section
        FMResultSet *resultForSymbols=[db executeQuery:@"SELECT count(DISTINCT (hwd)) from lookup where updatedhwd like ? and (SUBSTR (upper(updatedhwd),2,1)NOT BETWEEN 'A' AND 'Z') COLLATE NOCASE",currentCharWith];
        {
            while ([resultForSymbols next])
            {
                int count=[resultForSymbols intForColumnIndex:0];
                NSString *intString = [NSString stringWithFormat:@"%d", count];
                [sectionTitleAndItsCount setObject:intString forKey:currentChar];
            }
        }
        allKeys=[[NSMutableArray alloc] init];
        [allKeys addObject:currentChar];
        while ([results next])
        {
            NSString *currentSectionTitle=[results objectForColumnIndex:0];
            NSString *currentSectionWith=[currentSectionTitle stringByAppendingString:@"%"];
            //Retrieve the count in each sectionTitles
            FMResultSet *resultCount=[db executeQuery:@"SELECT count(DISTINCT(updatedhwd)) as count from lookup where updatedhwd like ? COLLATE NOCASE",currentSectionWith];
            while ([resultCount next])
            {
                int count=[resultCount intForColumnIndex:0];
                NSString *intString = [NSString stringWithFormat:@"%d", count];
                [sectionTitleAndItsCount setObject:intString forKey:currentSectionTitle];
            }
            [allKeys addObject:currentSectionTitle];
        }
        [sectionTitleAndItsCount setObject:allKeys forKey:@"AllKeys"];
        [final setObject:sectionTitleAndItsCount forKey:firstLevelindex[i]];
    }
    [db close];
    NSMutableDictionary *items=[[NSMutableDictionary alloc] init];
    [items setObject:final forKey:@"Items"];
    [items writeToFile:filePath atomically:YES];

    
}




@end
