//
//  YLVideoQualitySetController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLVideoQualitySetController.h"

@interface YLVideoQualitySetController ()<MyCameraDelegate>

@property (nonatomic, strong) NSArray *labelItems;
@end

@implementation YLVideoQualitySetController

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
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Video Quality", @"")];
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
        [self showTips2:NSLocalizedString(@"Set video quality successfully!", @"")];
        if(_delegate && [_delegate respondsToSelector:@selector(YLVideoQualitySetControllerDelegate_didSetFinished:)])
        {
            [_delegate YLVideoQualitySetControllerDelegate_didSetFinished:_newValue];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self showTips2:NSLocalizedString(@"Set video quality failed!", @"")];
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
        _labelItems = @[NSLocalizedString(@"Max", @""),
                        NSLocalizedString(@"High", @""),
                        NSLocalizedString(@"Medium", @""),
                        NSLocalizedString(@"Low", @""),
                        NSLocalizedString(@"Min", @"")];
    }
    return _labelItems;
}

-(BOOL) saveData
{
    if (_newValue != -1 && _origValue != _newValue) {
//        SMsgAVIoctrlSetMotionDetectReq *structSetMotionDetection = malloc(sizeof(SMsgAVIoctrlSetMotionDetectReq));
//        memset(structSetMotionDetection, 0, sizeof(SMsgAVIoctrlSetMotionDetectReq));
//        structSetMotionDetection->channel = 0;
//        structSetMotionDetection->sensitivity = (int)_newValue;
//        [_camera sendIOCtrlToChannel:0
//                                Type:IOTYPE_USER_IPCAM_SETMOTIONDETECT_REQ
//                                Data:(char *)structSetMotionDetection
//                            DataSize:sizeof(SMsgAVIoctrlSetMotionDetectReq)];
//        free(structSetMotionDetection);
        return YES;
    }
    return NO;
}

//begin add by kongyulu at 2013-11-11
- (void) updateTheQualityInDB
{
//    if (database != NULL) {
//        NSString *sql = [NSString stringWithFormat:@"UPDATE device set dev_videoQuality = %d where dev_uid = %@",self.camera.mVideoQuality, self.camera.mDeviceUID];
//        BOOL m_bResult = [database executeUpdate:sql];
//        if (m_bResult) {
//            NSLog(@"成功更新本地数据库中设备的视频质量 uid = %@, 视频质量 = %d",self.camera.mDeviceUID,self.camera.mVideoQuality);
//        }
//    }
    
}

- (void) sendCommandToDeviceSetTheQuality:(NSInteger) _qulityValue
{
    SMsgAVIoctrlSetStreamCtrlReq *s = malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
    memset(s, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
    
    s->channel = 0;
    s->quality = _qulityValue;
    
    [_camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
    
    free(s);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return [self.labelItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CheckMarkCellIdentifier = @"CheckMarkCellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CheckMarkCellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckMarkCellIdentifier]
                ;
    }
    
    NSUInteger row = [indexPath row];
    
    cell.textLabel.text = [self.labelItems objectAtIndex:row];
    cell.accessoryType = (row == (self.origValue - 1)) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.newValue = [indexPath row] + 1;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CameraDelegate Delegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    // begin delete by kongyulu at 2013-11-11
    /*
     if (camera_ == camera && type == IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP) {
     
     SMsgAVIoctrlGetStreamCtrlResq *s = (SMsgAVIoctrlGetStreamCtrlResq*) data;
     self.origValue = s->quality;
     
     [self.tableView reloadData];
     }
     */
    // end delete by kongyulu at 2013-11-11
    
}

@end
