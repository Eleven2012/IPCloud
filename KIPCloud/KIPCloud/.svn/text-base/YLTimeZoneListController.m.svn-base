//
//  YLTimeZoneListController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLTimeZoneListController.h"
#import "YLTimeZoneInfo.h"

@interface YLTimeZoneListController ()
{
    int mInitSelectedSection;
    int mInitSelectedRow;
}

@property (strong, nonatomic) NSMutableArray *listTimeZone;


@end

@implementation YLTimeZoneListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDatas];
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Time Zones", @"")];
    self.navigationItem.title = title;
    
}

-(void) loadDatas
{
    dispatch_async( dispatch_get_main_queue(), ^{
        
        mInitSelectedRow = -1;
        mInitSelectedSection = -1;
        
        DebugLog(@"%@",self.listTimeZone);
        [self.tableView reloadData];
        
        if( mInitSelectedRow != -1 && mInitSelectedSection != -1 ) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:mInitSelectedRow inSection:mInitSelectedSection];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSMutableArray *) listTimeZone
{
    if(_listTimeZone == nil)
    {
        _listTimeZone = [[NSMutableArray alloc] initWithCapacity:30];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray* tableArray = [NSArray arrayWithObjects:@"asia",@"europe",@"america",@"oceania",@"africa",nil];
        
        BOOL bBingo = FALSE;
        int nRegionIdx = 0;
        for (NSString* tableFileName in tableArray)
        {
            //DebugLog(@"for %@",tableFileName);
            NSString *tableFilePath = [[NSBundle mainBundle] pathForResource:tableFileName ofType:@"csv"];
            if( [fileManager fileExistsAtPath:tableFilePath] )
            {
                
                NSMutableArray *dataArr = [NSMutableArray arrayWithCapacity:50];
                NSString *strName = NSLocalizedString(tableFileName, @"");

                // read everything from text
                NSString* fileContents = [NSString stringWithContentsOfFile:tableFilePath encoding:NSASCIIStringEncoding error:nil];
                // first, separate by new line
                NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                int nLineIdx = 0;
                for( NSString* lineString in allLinedStrings ) {
                    //if( nLineIdx >= 1 )
                    {
                        NSArray* singleStrs = [lineString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                        DebugLog(@"singleStrs= %@",singleStrs);
                        if(singleStrs && [singleStrs count] >= 3)
                        {
                            NSString* strTimeZoneString = [singleStrs objectAtIndex:1];
                            
                            //NSString* strGMTDiffString = [[singleStrs objectAtIndex:2] substringFromIndex:4];
                            NSString* strGMTDiffString = [singleStrs objectAtIndex:2];
                            NSArray* timeStrings0 = [strGMTDiffString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                            if(timeStrings0 && [timeStrings0 count] >= 2)
                            {
                                NSString *str1 = [timeStrings0 objectAtIndex:1];
                                NSArray* timeStrings1 = [str1 componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
                                DebugLog(@"timeStrings= %@",timeStrings1);
                                if(timeStrings1 && [timeStrings1 count] >= 2)
                                {
                                    NSInteger nDiff_Hours = [[timeStrings1 objectAtIndex:0] integerValue];
                                    NSInteger nDiff_Minutes = [[timeStrings1 objectAtIndex:1] integerValue];
                                    YLTimeZoneInfo *timeZone = [[YLTimeZoneInfo alloc] init];
                                    timeZone.nGMTMins = nDiff_Hours*60 + nDiff_Minutes;
                                    timeZone.sDescribe = strTimeZoneString;
                                    timeZone.sDiffGMT = strGMTDiffString;
                                    [dataArr addObject:timeZone];
                                }
                            }
                            
                            if( !bBingo && [strTimeZoneString isEqualToString:self.curTimeZone.sDescribe]) {
                                mInitSelectedRow = nLineIdx - 1;
                                mInitSelectedSection = nRegionIdx - 1;
                                bBingo = TRUE;
                            }
                        }
                    }
                    nLineIdx++;
                }
                NSDictionary *dic = @{@"data":dataArr,@"name":strName};
                [_listTimeZone addObject:dic];
            }
        }
    }
    return _listTimeZone;
}

#pragma mark - Table view data source

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.listTimeZone count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic = [self.listTimeZone objectAtIndex:section];
    NSArray *dataArr = (NSArray *)[dic objectForKey:@"data"];
    NSInteger count = [dataArr count];
    DebugLog(@"section=%zd, row=%zd",section, count);
    return count;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dic = [self.listTimeZone objectAtIndex:section];
    NSString *str = [dic objectForKey:@"name"];
    return str;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DefaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSDictionary *dic = [self.listTimeZone objectAtIndex:section];
    
    YLTimeZoneInfo *timeZone = [[dic objectForKey:@"data"] objectAtIndex:row];
    cell.textLabel.text = timeZone.sDescribe;
    cell.detailTextLabel.text = timeZone.sDiffGMT;
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSDictionary *dic = [self.listTimeZone objectAtIndex:section];
    YLTimeZoneInfo *timeZone = [[dic objectForKey:@"data"] objectAtIndex:row];
    if(_delegate && [_delegate respondsToSelector:@selector(YLTimeZoneListControllerDelegate_didSelectItem:)])
    {
        [_delegate YLTimeZoneListControllerDelegate_didSelectItem:timeZone];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}



@end
