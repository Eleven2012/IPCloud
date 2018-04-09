//
//  YLWiFiListController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLWiFiListController.h"
#import "YLWiFiPasswordController.h"

@interface YLWiFiListController ()<MyCameraDelegate,YLWiFiPasswordControllerDelegate>
{
    NSInteger nTotalWaitingTime;
    BOOL bRemoteDevTimeout;
    BOOL bTimerListWifiApResp;
    NSInteger nLastSelIdx;
    SWifiAp wifiSSIDList[28];
    NSInteger wifiSSIDListCount;
    Boolean isRecvWiFi;
    Boolean isChangeWiFi;
}

@property (nonatomic, strong) NSTimer* timerListWifiApResp;
@property (nonatomic, copy) NSString *wifiSSID;
@end

@implementation YLWiFiListController

-(void) dealloc
{
    DebugLog(@"");
    self.camera.delegate2 = nil;
    self.camera = nil;
    [self.timerListWifiApResp invalidate];
    self.timerListWifiApResp = nil;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.camera.delegate2 = nil;
    self.camera = nil;
    [self.timerListWifiApResp invalidate];
    self.timerListWifiApResp = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self doRefresh];
    
}

-(void) initData
{
    [super initData];
    self.camera.delegate2 = self;
    
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"WiFi Networks", @"")];
    self.navigationItem.title = title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return wifiSSIDList != NULL && wifiSSIDListCount >= 0 ? wifiSSIDListCount : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    
    static NSString *WiFiNetworkCellIdentifier = @"WiFiNetworkCellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WiFiNetworkCellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:WiFiNetworkCellIdentifier]
                ;
    }
    
    SWifiAp wifiAp = wifiSSIDList[row];
    NSLog(@"wifi AP: %s \t%d", wifiAp.ssid, wifiAp.status);
    NSString *ssid = [NSString stringWithUTF8String: wifiAp.ssid];
    if ([ssid length] > 0)
        cell.textLabel.text = ssid;
    else
        cell.textLabel.text = NSLocalizedString(@"Unknown", @"");
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (([ssid length] > 0) &&
        ((self.wifiSSID != nil && [ssid length] > 0 && [ssid isEqualToString:self.wifiSSID]) ||
         (wifiAp.status == 1 || wifiAp.status == 3 || wifiAp.status == 4)))
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if( !bRemoteDevTimeout ) {
        if (wifiSSIDListCount < 0)
            return NSLocalizedString(@"Scanning...", @"");
        else if (wifiSSIDListCount == 0)
            return NSLocalizedString(@"No Wi-Fi network found", @"");
        else
            return NSLocalizedString(@"Choose a Network...", @"");
    }
    else {
        return NSLocalizedString(@"Remote Device Timeout", @"");
    }
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger idx = [indexPath row];
    SWifiAp wifiAp = wifiSSIDList[idx];
    
    YLWiFiPasswordController *controller = [[YLWiFiPasswordController alloc] init];
    controller.delegate = self;
    controller.camera = self.camera;
    controller.ssid = [NSString stringWithFormat:@"%s", wifiAp.ssid];
    controller.ssid_length = 32;
    controller.mode = wifiAp.mode;
    controller.enctype = wifiAp.enctype;
    [self.navigationController pushViewController:controller animated:YES];
    nLastSelIdx = idx;
}

-(void) updateTableView
{
    [self.tableView reloadData];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    DebugLog(@"");
    if (camera_ == _camera) {
        
        if (type == IOTYPE_USER_IPCAM_LISTWIFIAP_RESP) {
            if( bTimerListWifiApResp ) {
                [self.timerListWifiApResp invalidate];
                bTimerListWifiApResp = FALSE;
            }
            
            if (!isRecvWiFi) {
                memset(wifiSSIDList, 0, sizeof(wifiSSIDList));
                
                SMsgAVIoctrlListWifiApResp *p = (SMsgAVIoctrlListWifiApResp *)data;
                
                wifiSSIDListCount = p->number;
                memcpy(wifiSSIDList, p->stWifiAp, size - sizeof(p->number));
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self updateTableView];
                });
                isRecvWiFi = true;
            }
        }
    }
}

#pragma mark - EditWiFiPasswordDelegate Methods
-(void) YLWiFiPasswordControllerDelegate_didSetFinished:(id)userInfo ssid:(NSString *)ssid
{
    isChangeWiFi = true;
    self.wifiSSID = ssid;
    NSArray *visableCells = [self.tableView visibleCells];
    int i;
    for (i = 0; i< [visableCells count]; i++) {
        UITableViewCell *currentCell = [visableCells objectAtIndex:i];
        
        if ([currentCell.textLabel.text isEqualToString:ssid]) {
            currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            currentCell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}


- (void)timeOutGetListWifiAPResp:(NSTimer *)timer
{
    bTimerListWifiApResp = FALSE;
    
    int timeOut = [(NSNumber*)timer.userInfo intValue];
    nTotalWaitingTime += timeOut;
    
    NSLog( @"!!! IOTYPE_USER_IPCAM_LISTWIFIAP_RESP TimeOut %zd sec !!!", nTotalWaitingTime );
    
    if( nTotalWaitingTime <= 30 ) {
        timeOut = 20;
    }
    else if( nTotalWaitingTime <= 50 ) {
        timeOut = 10;
    }
    else if( nTotalWaitingTime > 50 ) {
        timeOut = 0;
        
        bRemoteDevTimeout = TRUE;
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self updateTableView];
        });
    }
    
    if( timeOut > 0 ) {
        bTimerListWifiApResp = TRUE;
        self.timerListWifiApResp = [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(timeOutGetListWifiAPResp:) userInfo:[NSNumber numberWithInt:timeOut] repeats:FALSE];
    }
}

- (void)doRefresh
{
    // send list wifi request
    SMsgAVIoctrlListWifiApReq *structListWiFi = malloc(sizeof(SMsgAVIoctrlListWifiApReq));
    memset(structListWiFi, 0, sizeof(SMsgAVIoctrlListWifiApReq));
    
    bTimerListWifiApResp = TRUE;
    bRemoteDevTimeout = FALSE;
    nTotalWaitingTime = 0;
    self.timerListWifiApResp = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timeOutGetListWifiAPResp:) userInfo:[NSNumber numberWithInt:30] repeats:FALSE];
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_LISTWIFIAP_REQ Data:(char *)structListWiFi DataSize:sizeof(SMsgAVIoctrlListWifiApReq)];
    free(structListWiFi);
    
    
    wifiSSIDListCount = -1;
    memset(wifiSSIDList, 0, sizeof(wifiSSIDList));
    isRecvWiFi = false;
    isChangeWiFi = false;
    
    // send get wifi request
    SMsgAVIoctrlGetWifiReq *structGetWiFi = malloc(sizeof(SMsgAVIoctrlGetWifiReq));
    memset(structGetWiFi, 0, sizeof(SMsgAVIoctrlGetWifiReq));
    
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETWIFI_REQ Data:(char *)structGetWiFi DataSize:sizeof(SMsgAVIoctrlGetWifiReq)];
    free(structGetWiFi);	
}


@end
