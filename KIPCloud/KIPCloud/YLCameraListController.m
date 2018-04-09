//
//  YLCameraListController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLCameraListController.h"
#import "AppDelegate.h"
#import "YLCameraInfoCell.h"
#import "YLAddCameraController.h"
#import "YLLiveVideoController.h"


#define HIRESDEVICE (((int)rintf([[[UIScreen mainScreen] currentMode] size].width/[[UIScreen mainScreen] bounds].size.width ) > 1))

#define CAMERA_NAME_TAG 1
#define CAMERA_STATUS_TAG 2
#define CAMERA_UID_TAG 3
#define CAMERA_SNAPSHOT_TAG 4

@interface YLCameraListController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,MyCameraDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *searchCameraArr;
@property (strong, nonatomic) NSMutableArray *reconnectFlagArr;

@end

@implementation YLCameraListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self initUI];
    _searchBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initUI
{
    self.navigationItem.title = NSLocalizedString(@"Camera List", @"");
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Edit", @"")
                                   style:UIBarButtonItemStyleBordered
                                   target:self action:@selector(btnRightBarEdit:)];
    self.navigationItem.rightBarButtonItem = editButton;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.searchCameraArr removeAllObjects];
    [self.searchCameraArr addObjectsFromArray:[YLGlobal shareInstance].cameraArr];
    self.navigationItem.rightBarButtonItem.enabled = [self.searchCameraArr count] > 0;
    
    [self.reconnectFlagArr removeAllObjects];
    for (MyCamera *camera in [YLGlobal shareInstance].cameraArr) {
        camera.delegate2 = self;
        
        [self.reconnectFlagArr addObject:[NSMutableArray arrayWithObjects:[NSString stringWithString:camera.uid], [NSNumber numberWithInt:0], nil]];
    }
    [self.tableView reloadData];
    
    AppDelegate* currentAppDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if( currentAppDelegate.mOpenUrlCmdStore.cmd == emShowLiveViewByUID ) {
        NSIndexPath *nip = [NSIndexPath indexPathForRow:currentAppDelegate.mOpenUrlCmdStore.tabIdx inSection:0];
        [self tableView:[self tableView] didSelectRowAtIndexPath:nip];
        [currentAppDelegate urlCommandDone];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [self.searchCameraArr removeAllObjects];
    for( NSMutableArray* store in self.reconnectFlagArr ) {
        if( [store count] == 3 ) {
            NSTimer* timer = [store objectAtIndex:2];
            [timer invalidate];
        }
    }
    [self.searchCameraArr removeAllObjects];
    [super viewDidDisappear:animated];
}

#pragma mark actions

-(NSMutableArray *) searchCameraArr
{
    if(_searchCameraArr == nil)
    {
        _searchCameraArr = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _searchCameraArr;
}

-(NSMutableArray *) reconnectFlagArr
{
    if(_reconnectFlagArr == nil)
    {
        _reconnectFlagArr = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _reconnectFlagArr;
}



- (void)btnRightBarEdit:(id)sender {
    
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing)
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Done", @"")];
    else
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"Edit", @"")];
}


- (NSString *) getCameraStatusDescribe:(MyCamera *) camera
{
    NSString *strDescribe = nil;
    if (camera.sessionState == CONNECTION_STATE_CONNECTING) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Connecting...", @""), camera.connTimes, camera.connFailErrCode];
        }
        else {
            strDescribe = NSLocalizedString(@"Connecting...", @"");
        }
        NSLog(@"%@ connecting", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Off line", @""), camera.connTimes, camera.connFailErrCode];
        }
        else {
            strDescribe = NSLocalizedString(@"Off line", @"");
        }
        NSLog(@"%@ off line", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Unknown Device", @""), camera.connTimes, camera.connFailErrCode];
        }
        else {
            strDescribe = NSLocalizedString(@"Unknown Device", @"");
        }
        NSLog(@"%@ unknown device", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Timeout", @""), camera.connTimes, camera.connFailErrCode];
        }
        else {
            strDescribe = NSLocalizedString(@"Timeout", @"");
        }
        NSLog(@"%@ timeout", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Unsupported", @""), camera.connTimes, camera.connFailErrCode];
        }
        else {
            strDescribe = NSLocalizedString(@"Unsupported", @"");
        }
        NSLog(@"%@ unsupported", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Connect Failed", @""), camera.connTimes, camera.connFailErrCode];
        }
        else {
            strDescribe = NSLocalizedString(@"Connect Failed", @"");
        }
        NSLog(@"%@ connected failed", camera.uid);
    }
    
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
        if( g_bDiagnostic ) {
            
            strDescribe = [NSString stringWithFormat:@"%@ [%@]%zd,C:%zd,D:%zd,r%d", NSLocalizedString(@"Online", @""), [MyCamera getConnModeString:camera.sessionMode], camera.connTimes, camera.natC, camera.natD, camera.nAvResend ];
        }
        else {
            strDescribe = NSLocalizedString(@"Online", @"");
        }
        NSLog(@"%@ online", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_CONNECTING)", NSLocalizedString(@"Connecting...", @""), camera.connTimes];
        }
        else {
            strDescribe = NSLocalizedString(@"Connecting...", @"");
        }
        NSLog(@"%@ connecting", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED)
    {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_DISCONNECTED)", NSLocalizedString(@"Off line", @""), camera.connTimes];
        }
        else {
            strDescribe = NSLocalizedString(@"Off line", @"");
        }
        NSLog(@"%@ off line", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_UNKNOWN_DEVICE)", NSLocalizedString(@"Unknown Device", @""), camera.connTimes];
        }
        else {
            strDescribe = NSLocalizedString(@"Unknown Device", @"");
        }
        NSLog(@"%@ unknown device", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_WRONG_PASSWORD)", NSLocalizedString(@"Wrong Password", @""), camera.connTimes];
        }
        else {
            strDescribe = NSLocalizedString(@"Wrong Password", @"");
        }
        NSLog(@"%@ wrong password", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_TIMEOUT)", NSLocalizedString(@"Timeout", @""), camera.connTimes];
        }
        else {
            strDescribe = NSLocalizedString(@"Timeout", @"");
        }
        NSLog(@"%@ timeout", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_UNSUPPORTED)", NSLocalizedString(@"Unsupported", @""), camera.connTimes];
        }
        else {
            strDescribe = NSLocalizedString(@"Unsupported", @"");
        }
        NSLog(@"%@ unsupported", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
        if( g_bDiagnostic ) {
            strDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_NONE)", NSLocalizedString(@"Connecting...", @""), camera.connTimes];
        }
        else {
            strDescribe = NSLocalizedString(@"Connecting...", @"");
        }
        NSLog(@"%@ wait for connecting", camera.uid);
    }
    return strDescribe;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.searchCameraArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat gHeight = 5;
    return gHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sTitle = nil;
    return sTitle;
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat gHeight = 1;
    return gHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier1 = @"DefaultCell";
    static NSString *cellIdentifier2 = @"YLCameraInfoCell";
    UITableViewCell *cell = nil;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YLCameraInfoCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    //disable selected cell
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    YLCameraInfoCell * cell2 = (YLCameraInfoCell*)cell;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

    if( [self.searchCameraArr count] > 0 && row < [self.searchCameraArr count] )
    {
        MyCamera *camera = [self.searchCameraArr objectAtIndex:row];
        
        cell2.labelCameraDID.text = camera.device.uid;
        cell2.labelCameraName.text = camera.device.dev_nickname;
        cell2.labelCameraStatus.text = [self getCameraStatusDescribe:camera];
        UIImage *iconHead = nil;
        NSString *imgFullName = [YLComFun pathForDocumentsResource:[NSString stringWithFormat:@"%@.jpg", camera.uid]];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imgFullName];
        iconHead = fileExists ? [UIImage imageWithContentsOfFile:imgFullName] : [UIImage imageNamed:@"videoClip.png"];
        cell2.imgHead.image = iconHead;
    }
    return cell;
}

#pragma mark - TableView Delegate Methods

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_searchBar resignFirstResponder];
    return indexPath;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row1 = [indexPath row];
    if( [self.searchCameraArr count] > 0 && row1 < [self.searchCameraArr count] ) {
        MyCamera *camera = [self.searchCameraArr objectAtIndex:row1];
        YLLiveVideoController *controller = [[YLLiveVideoController alloc] init];
        controller.camera = camera;
        
        // controller.selectedAudioMode = AUDIO_MODE_SPEAKER;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        

    }
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *uid = nil;
    
    Camera *camera = [self.searchCameraArr objectAtIndex:[indexPath row]];
    [camera stop:0];
    [camera disconnect];
    
    uid = camera.uid;
    
    for( NSArray* store in self.reconnectFlagArr ) {
        NSString* uidInStore = [store objectAtIndex:0];
        if( NSOrderedSame == [uid compare:uidInStore options:NSCaseInsensitiveSearch] ) {
            if( [store count] == 3 ) {
                NSTimer* timer = [store objectAtIndex:2];
                [timer invalidate];
            }
            [self.reconnectFlagArr  removeObjectAtIndex:[indexPath row]];
            break;
        }
    }
    
    [self.searchCameraArr removeObjectAtIndex:[indexPath row]];
    [[YLGlobal shareInstance].cameraArr removeObject:camera];
    
    if (uid != nil) {
        
        // delete camera & snapshot file in db
        [[YLGlobal shareInstance] deleteCamera:uid];
        [[YLGlobal shareInstance] deleteSnapshotRecords:uid];
        
        // unregister from apns server
        dispatch_queue_t queue = dispatch_queue_create("apns-reg_client", NULL);
        dispatch_async(queue, ^{
            if (true) {
                NSError *error = nil;
                NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
#ifndef DEF_APNSTest
                NSString *hostString = @"http://push.iotcplatform.com/apns/apns.php";
#else
                NSString *hostString = @"http://54.225.191.150/test_gcm/apns.php"; //測試Host
#endif
                NSString *argsString = @"%@?cmd=unreg_mapping&token=%@&uid=%@&appid=%@";
                NSString *getURLString = [NSString stringWithFormat:argsString, hostString, [YLGlobal shareInstance].deviceTokenString, uid, appidString];
#ifdef DEF_APNSTest
                NSLog( @"==============================================");
                NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
                NSLog( @"==============================================");
#endif
                NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
#ifdef DEF_APNSTest
                NSLog( @"==============================================");
                NSLog( @">>> %@", registerResult );
                NSLog( @"==============================================");
                if (error != NULL) {
                    NSLog(@"%@",[error localizedDescription]);
                }
#endif
            }
        });
        //dispatch_release(queue);
    }
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //跳转到设备编辑页面
    MyCamera *camera = [self.searchCameraArr objectAtIndex:indexPath.row];
    if(camera)
    {
        YLAddCameraController *editVC = [[YLAddCameraController alloc] init];
        editVC.camera =camera;
        editVC.name = camera.device.dev_nickname;
        editVC.did = camera.device.uid;
        editVC.password = camera.device.view_pwd;
        editVC.bAddCameraPage = NO;
        editVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editVC animated:YES];
    }

}

#pragma mark - SearchBar Delegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
    self.navigationItem.rightBarButtonItem.enabled = [self.searchCameraArr count] > 0;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
    
    [_searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    
    [self.searchCameraArr removeAllObjects];
    
    if ([searchText isEqualToString:@""]) {
        [self.tableView reloadData];
        return;
    }
    else if( [searchText isEqualToString:@"diagnostic"] ) {
        g_bDiagnostic = TRUE;
    }
    
    for (Camera *camera in [YLGlobal shareInstance].cameraArr) {
        
        NSRange range = [camera.name rangeOfString:searchText];
        if (range.location != NSNotFound && range.location == 0)
            [self.searchCameraArr addObject:camera];
    }
    self.navigationItem.rightBarButtonItem.enabled = [self.searchCameraArr count] > 0;
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.searchCameraArr removeAllObjects];
    [self.searchCameraArr addObjectsFromArray:[YLGlobal shareInstance].cameraArr];
    
    @try {
        [self.tableView reloadData];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [self.searchBar resignFirstResponder];
        self.searchBar.text = @"";
    }
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera _didChangeSessionStatus:(NSInteger)status
{
    if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera disconnect];
            
        });
    }
    
    if (!self.tableView.editing)
        [self.tableView reloadData];
    
    if( camera.sessionState == CONNECTION_STATE_DISCONNECTED ||
       camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE ||
       camera.sessionState == CONNECTION_STATE_TIMEOUT ||
       camera.sessionState == CONNECTION_STATE_UNSUPPORTED ||
       camera.sessionState == CONNECTION_STATE_CONNECT_FAILED ) {
        
        NSMutableArray* storeToSetTimer = nil;
        int nReConntFlag = -1;
        for( NSMutableArray* store in self.reconnectFlagArr ) {
            NSString* uidInStore = [store objectAtIndex:0];
            if( NSOrderedSame == [camera.uid compare:uidInStore options:NSCaseInsensitiveSearch] ) {
                NSNumber* num = [store objectAtIndex:1];
                nReConntFlag = [num intValue];
                [store replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:++nReConntFlag]];
                storeToSetTimer = store;
                break;
            }
        }
        if( nReConntFlag == 1 ) {
            NSLog( @"Camera UID:%@ will re-connect in 30sec...", camera.uid );
            [storeToSetTimer addObject:[NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(ReConnectAfter30Sec:) userInfo:[NSArray arrayWithObjects:[NSString stringWithString:camera.uid], [NSValue valueWithPointer:(__bridge const void * _Nullable)(camera)], nil] repeats:NO]];
        }
        else {
            NSLog( @"Camera UID:%@ give up re-connect nReConntFlag:%d", camera.uid, nReConntFlag );
        }
    }
    else if( camera.sessionState == CONNECTION_STATE_CONNECTED ) {
        for( NSMutableArray* store in _reconnectFlagArr ) {
            NSString* uidInStore = [store objectAtIndex:0];
            if( NSOrderedSame == [camera.uid compare:uidInStore options:NSCaseInsensitiveSearch] ) {
                [store replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
                NSLog( @"Camera UID:%@ reset re-connect flag as -0-", camera.uid );
                break;
            }
        }
    }
}

- (void)camera:(MyCamera *)camera _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    if (status == CONNECTION_STATE_TIMEOUT) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [camera stop:channel];
            
            usleep(500 * 1000);
            
            [camera disconnect];
        });
    }
    
    if (!self.tableView.editing)
        [self.tableView reloadData];    
}

- (void)ReConnectAfter30Sec:(NSTimer*)theTimer
{
    NSArray* arrParam = (NSArray*)theTimer.userInfo;
    NSString* strUid = [arrParam objectAtIndex:0];
    MyCamera* camera = (MyCamera*)[(NSValue*)[arrParam objectAtIndex:1] pointerValue];
    
    BOOL bIsValid_Camera = FALSE;
    for( NSMutableArray* store in self.reconnectFlagArr ) {
        NSString* uidInStore = [store objectAtIndex:0];
        if( NSOrderedSame == [strUid compare:uidInStore options:NSCaseInsensitiveSearch] ) {
            bIsValid_Camera = TRUE;
            if( [store count] == 3 ) {
                NSTimer* timer = [store objectAtIndex:2];
                [store removeObjectAtIndex:2];
                break;
            }
        }
    }
    if( bIsValid_Camera ) {
        [camera connect:camera.uid];
        [camera start:0];
        
        SMsgAVIoctrlSetStreamCtrlReq *s0 = (SMsgAVIoctrlSetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        memset(s0, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        
        s0->channel = 0;
        s0->quality = camera.mVideoQuality;
        
        [camera sendIOCtrlToChannel:0
                               Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                               Data:(char *)s0
                           DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
        free(s0);
    }
    else {
        NSLog( @"ReConnectAfter30Sec with deallocated instance!!!" );
    }
}


@end
