//
//  YLRecordModeSetController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLRecordModeSetController.h"

@interface YLRecordModeSetController ()<MyCameraDelegate>
@property (nonatomic, retain) NSArray *labelItems;

@end

@implementation YLRecordModeSetController

-(void) dealloc
{
    self.camera.delegate2 = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void) initData
{
    [super initData];
    self.camera.delegate2 = self;
    self.newValue = -1;
    
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Recording Mode", @"")];
    self.navigationItem.title = title;
}

-(void) initBarButton
{
    [super initBarButton];
    
    UIBarButtonItem *rightNavBar =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_finish"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBarRightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightNavBar;
    
}

-(void) btnBarRightButtonClicked:(id) sender
{
    if([self saveData])
    {
        [self showTips2:NSLocalizedString(@"Set record mode successfully!", @"")];
        if(_delegate && [_delegate respondsToSelector:@selector(YLRecordModeSetControllerDelegate_didRecordModeSetFinished:)])
        {
            [_delegate YLRecordModeSetControllerDelegate_didRecordModeSetFinished:_newValue];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self showTips2:NSLocalizedString(@"Set record mode failed!", @"")];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSArray*) labelItems
{
    if(_labelItems == nil)
    {
        _labelItems = @[NSLocalizedString(@"Off", @""),
                        NSLocalizedString(@"Full Time", @""),
                        NSLocalizedString(@"Alarm", @"")];
    }
    return _labelItems;
}

-(BOOL) saveData
{
    if (_newValue != -1 && _origValue != _newValue) {
        SMsgAVIoctrlSetRecordReq *structSetRecord = malloc(sizeof(SMsgAVIoctrlSetRecordReq));
        memset(structSetRecord, 0, sizeof(SMsgAVIoctrlSetRecordReq));
        structSetRecord->channel = 0;
        structSetRecord->recordType = (int)_newValue;
        [_camera sendIOCtrlToChannel:0
                               Type:IOTYPE_USER_IPCAM_SETRECORD_REQ
                               Data:(char *)structSetRecord
                           DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
        free(structSetRecord);
        return YES;
    }
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? [self.labelItems count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    
    static NSString *RecordingModeTableIdentifier = @"RecordingModeTableIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RecordingModeTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RecordingModeTableIdentifier]
                ;
    }
    
    cell.textLabel.text = [self.labelItems objectAtIndex:row];
    cell.accessoryType = (row == self.origValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.newValue = [indexPath row];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == _camera && type == IOTYPE_USER_IPCAM_GETRECORD_RESP) {
        
        SMsgAVIoctrlGetRecordResq *s = (SMsgAVIoctrlGetRecordResq*)data;
        memcpy(s, data, size);
        self.origValue = s->recordType;
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self updateTableView];
        });
    }
}

-(void) updateTableView
{
    [self.tableView reloadData];
}

@end
