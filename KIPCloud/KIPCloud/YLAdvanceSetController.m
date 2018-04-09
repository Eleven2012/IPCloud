//
//  YLAdvanceSetController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLAdvanceSetController.h"
#import "YLCommonActivityCell.h"
#import "YLTimeZoneListController.h"
#import "YLDeviceInfoController.h"
#import "YLWiFiListController.h"
#import "YLSDCardSetController.h"
#import "YLVideoFlipSetController.h"
#import "YLVideoQualitySetController.h"
#import "YLMontionDetectSetController.h"
#import "YLRecordModeSetController.h"
#import "YLSecurityCodeSetController.h"
#import "YLEnvironmentModeController.h"
#import "YLTimeZoneItemCell.h"
#import "YLTimeZoneInfo.h"

@interface YLAdvanceSetController ()<UIGestureRecognizerDelegate,YLSecurityCodeSetControllerDelegate,YLTimeZoneListControllerDelegate,YLEnvironmentModeControllerDelegate,YLRecordModeSetControllerDelegate,YLVideoFlipSetControllerDelegate,YLVideoQualitySetControllerDelegate,
YLMontionDetectSetControllerDelegate,MyCameraDelegate>
{
    BOOL isRecvWiFi;
    BOOL isNeedReconn;
    BOOL isChangePasswd;
    SMsgAVIoctrlTimeZone mIoCtrlData_SetTimeZoneBefore;
    BOOL isWaitingForSetTimeZoneResp;
    BOOL bTimerListWifiApResp;
    int nTotalWaitingTime;
}

@property (assign, nonatomic) BOOL bSupportSecuritySection;
@property (assign, nonatomic) BOOL bSupportVideoSetSection;
@property (assign, nonatomic) BOOL bSupportVideoQualityRow;
@property (assign, nonatomic) BOOL bSupportVideoFlipRow;
@property (assign, nonatomic) BOOL bSupportEnvironmentModeRow;
@property (assign, nonatomic) BOOL bSupportTimeZoneSection;
@property (assign, nonatomic) BOOL bSupportWiFiSection;
@property (assign, nonatomic) BOOL bSupportMontionDetectSection;
@property (assign, nonatomic) BOOL bSupportRecordModeSection;
@property (assign, nonatomic) BOOL bSupportRecordSetRow;
@property (assign, nonatomic) BOOL bSupportSDCardSetRow;
@property (assign, nonatomic) BOOL bSupportDeviceInfoSection;


@property (strong, nonatomic) NSString *sNewPassword;
@property (strong, nonatomic) NSString *wifiSSID;
@property (assign, nonatomic) NSInteger videoQuality;
@property (assign, nonatomic) NSInteger videoFlip;
@property (assign, nonatomic) NSInteger envMode;
@property (assign, nonatomic) NSInteger motionDetection;
@property (assign, nonatomic) NSInteger recordingMode;
@property (assign, nonatomic) NSInteger wifiStatus;
@property (nonatomic, strong) NSMutableArray* arrRequestIoCtrl;
@property (nonatomic, strong) NSTimer* timerTimeZoneTimeOut;
@property (nonatomic, strong) NSTimer* timerListWifiApResp;



@end

@implementation YLAdvanceSetController

-(void) dealloc
{
    self.camera.delegate = nil;
    self.camera.delegate2 = nil;
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Advanced Setting", @"")];
    self.navigationItem.title = title;
    [self addGesture];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.camera.delegate = self;
    self.camera.delegate2 = self;
    //[self getCameraInfo];
    [self doRefresh];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.camera.delegate2 = self;
    //[self doRefresh];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 添加手势
- (void) addGesture
{
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1; // 单击
    singleTapRecognizer.delegate = self;
    [self.view addGestureRecognizer:singleTapRecognizer];
    //free memory
}

// 单击
- (void)handleSingleTapFrom:(UITapGestureRecognizer*)recognizer {
    [self hideTheKeyboard];
}

- (void) hideTheKeyboard
{
    [self.view endEditing:YES];
}

-(NSMutableArray *) arrRequestIoCtrl
{
    if(_arrRequestIoCtrl == nil)
    {
        _arrRequestIoCtrl = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _arrRequestIoCtrl;
}

#pragma mark - datasource
-(NSString *) getMontionDetectionDescribe:(NSInteger) nValue
{
    NSString *strValue = nil;
    if (nValue == 0)
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Off", @"")];
    else if (nValue > 0 && nValue <= 25)
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Low", @"")];
    else if (nValue > 25 && nValue <= 50)
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Medium", @"")];
    else if (nValue > 50 && nValue <= 75)
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"High", @"")];
    else if (nValue == 100)
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Max", @"")];
    return strValue;
}

-(NSString *) getRecordModeDescribe:(NSInteger) nValue
{
    NSString *strValue = nil;
    if (nValue == 0)
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Off", @"")];
    else if (nValue == 1)
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Full Time", @"")];
    else if (nValue == 2)
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Alarm", @"")];
    return strValue;
}

-(NSString *) getWiFiDescribe:(NSInteger) nValue
{
    NSString *strValue = nil;
    if (nValue == 0) {
        strValue = [[NSString alloc] initWithString:NSLocalizedString(@"None", @"")];
    } else if (nValue == 1) {
        strValue = [self.wifiSSID copy];
    } else if (nValue == 2) {
        strValue = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", self.wifiSSID, NSLocalizedString(@"Wrong password", @"")]];
    } else if (nValue == 3) {
        strValue = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", self.wifiSSID, NSLocalizedString(@"Weak signal", @"")]];
    } else if (nValue == 4) {
        strValue = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", self.wifiSSID, NSLocalizedString(@"Ready", @"")]];
    } else if (nValue == 10) {
        strValue = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@", NSLocalizedString(@"Remote Device Timeout", @"")]];
    }
    return strValue;
}

-(NSString *) getEnironmentModeDescribe:(NSInteger) nValue
{
    NSString *strValue = nil;
    switch (nValue) {
        case 0:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Indoor(50Hz)", @"")];
            break;
        case 1:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Indoor(60Hz)", @"")];
            break;
        case 2:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Outdoor", @"")];
            break;
        case 3:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Night", @"")];
            break;
        default:
            strValue = nil;
            break;
    }
    return strValue;
}

-(NSString *) getVideoFlipDescribe:(NSInteger) nValue
{
    NSString *strValue = nil;
    switch (nValue) {
        case 0:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Normal", @"")];
            break;
        case 1:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Vertical Flip", @"")];
            break;
        case 2:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Mirror", @"")];
            break;
        case 3:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Flip & Mirror", @"")];
            break;
        default:
            strValue = nil;
            break;
    }
    return strValue;
}

-(NSString *) getVideoQualityDescribe:(NSInteger) nValue
{
    NSString *strValue = nil;
    switch (nValue) {
        case 0:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Unknown", @"")];;
            break;
        case 1:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Max", @"")];;
            break;
        case 2:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"High", @"")];
            break;
        case 3:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Medium", @"")];
            break;
        case 4:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Low", @"")];
            break;
        case 5:
            strValue = [[NSString alloc] initWithString:NSLocalizedString(@"Min", @"")];
            break;
        default:
            strValue = nil;
            break;
    }
    return strValue;
}


#pragma mark GestureDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

-(BOOL) bSupportWiFiSection
{
    if(_camera)
    {
        return [_camera getWiFiSettingSupportOfChannel:0];
    }
    return NO;
}


-(BOOL) bSupportSecuritySection
{
    if(_camera)
    {
        return [_camera getWiFiSettingSupportOfChannel:0];
    }
    return NO;
}

-(BOOL) bSupportTimeZoneSection
{
    if(_camera)
    {
        return _camera.bIsSupportTimeZone;
    }
    return NO;
}


-(BOOL) bSupportVideoSetSection
{
    if(self.bSupportVideoFlipRow
       || self.bSupportVideoQualityRow
       || self.bSupportEnvironmentModeRow)
    {
        return YES;
    }
    return NO;
        
}
-(BOOL) bSupportVideoQualityRow
{
    if(_camera)
    {
        return [_camera getVideoQualitySettingSupportOfChannel:0];
    }
    return NO;
}
-(BOOL) bSupportVideoFlipRow
{
    if(_camera)
    {
        return [_camera getVideoFlipSupportOfChannel:0];
    }
    return NO;
}
-(BOOL) bSupportEnvironmentModeRow
{
    if(_camera)
    {
        return [_camera getEnvironmentModeSupportOfChannel:0];
    }
    return NO;
}
-(BOOL) bSupportDeviceInfoSection
{
    if(_camera)
    {
        return [_camera getDeviceInfoSupportOfChannel:0];
    }
    return NO;
}

-(BOOL) isSupportRecordSetRow
{
    if(_camera)
    {
        return ([_camera getRecordSettingSupportOfChannel:0]);
    }
    return NO;
}

-(BOOL) isBSupportSDCardSetRow
{
    if(_camera)
    {
        return ([_camera getFormatSDCardSupportOfChannel:0]);
    }
    return NO;
}

-(BOOL) bSupportRecordModeSection
{
    if(_camera)
    {
        return (self.bSupportRecordSetRow ||
                self.bSupportSDCardSetRow);
    }
    return NO;
}

-(BOOL) bSupportMontionDetectSection
{
    if(_camera)
    {
        return [_camera getMotionDetectionSettingSupportOfChannel:0];
    }
    return NO;
}
- (int)getSecurityCodeRow
{
    return self.bSupportSecuritySection ? 0 : -1;
}

- (int)getVideoQualitySettingRow
{
    return self.bSupportVideoQualityRow ? 0 : -1;
}

- (int)getVideoFlipSettingRow
{
    int idx = 1;
    
    if (!self.bSupportVideoQualityRow)
        idx--;
    
    return self.bSupportVideoFlipRow ? idx : -1;
}

- (int)getEnvironmentSettingRow
{
    int idx = 2;
    
    if (!self.bSupportVideoQualityRow)
        idx--;
    
    if (!self.bSupportVideoFlipRow)
        idx--;
    
    return self.bSupportEnvironmentModeRow ? idx : -1;
}

- (int)getTimeZoneSettingRow
{
    return self.bSupportTimeZoneSection ? 0 : -1;
}

- (int)getWifiSettingRow
{
    return self.bSupportWiFiSection ? 0 : -1;
}

- (int)getMotionDetectionSettingRow
{
    return self.bSupportMontionDetectSection ? 0 : -1;
}

- (int)getRecordSettingRow
{
    return self.bSupportRecordSetRow ? 0 : -1;
}

- (int)getFormatSDCardRow
{
    int idx = 1;
    
    if (!self.bSupportRecordSetRow)
        idx--;
    
    return self.bSupportSDCardSetRow ? idx : -1;
}

- (int)getDeviceInfoRow
{
    return self.bSupportDeviceInfoSection ? 0 : -1;
}

#pragma mark

- (int)getSecurityCodeSection
{
    return (self.bSupportSecuritySection) ? 0 : -1;
}

- (int)getVideoSettingSection
{
    int idx = 1;
    
    if (!self.bSupportSecuritySection)
        idx--;
    
    return self.bSupportVideoSetSection ? idx : -1;;
}

- (int)getTimeZoneSection
{
    int idx = 2;
    
    if (!self.bSupportSecuritySection)
        idx--;
    if (!self.bSupportVideoSetSection)
        idx--;
    
    return self.bSupportTimeZoneSection ? idx : -1;
}

- (int)getWifiSection
{
    int idx = 3;
    
    if (!self.bSupportSecuritySection)
        idx--;
    if (!self.bSupportVideoSetSection)
        idx--;
    if( !self.bSupportTimeZoneSection )
        idx--;
    
    return self.bSupportWiFiSection ? idx : -1;
}

- (int)getMontionDetectSection
{
    int idx = 4;
    
    if (!self.bSupportSecuritySection)
        idx--;
    if (!self.bSupportVideoSetSection)
        idx--;
    if( !self.bSupportTimeZoneSection )
        idx--;
    if( !self.bSupportWiFiSection )
        idx--;
    
    return self.bSupportMontionDetectSection ? idx : -1;
}

- (int)getRecordSettingSection
{
    int idx = 5;
    
    if (!self.bSupportSecuritySection)
        idx--;
    if (!self.bSupportVideoSetSection)
        idx--;
    if( !self.bSupportTimeZoneSection )
        idx--;
    if( !self.bSupportWiFiSection )
        idx--;
    if( !self.bSupportMontionDetectSection )
        idx--;
    
    return self.bSupportRecordModeSection ? idx : -1;
}

- (int)getDeviceInfoSectionIndex
{
    int idx = 6;
    
    if (!self.bSupportSecuritySection)
        idx--;
    if (!self.bSupportVideoSetSection)
        idx--;
    if( !self.bSupportTimeZoneSection )
        idx--;
    if( !self.bSupportWiFiSection )
        idx--;
    if( !self.bSupportMontionDetectSection )
        idx--;
    if( !self.bSupportRecordModeSection )
        idx--;
    
    return self.bSupportDeviceInfoSection ? idx : -1;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    int row = 0;
    if (self.bSupportSecuritySection) row++;
    if (self.bSupportVideoSetSection) row++;
    if (self.bSupportTimeZoneSection) row++;
    if (self.bSupportWiFiSection) row++;
    if (self.bSupportMontionDetectSection) row++;
    if (self.bSupportRecordModeSection) row++;
    if (self.bSupportDeviceInfoSection) row++;
    
    return row;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title=nil;
    if (section == [self getSecurityCodeSection]) {
    }
    else if (section == [self getVideoSettingSection]) {
    }
    else if (section == [self getTimeZoneSection]) {
    }
    else if (section == [self getWifiSection]) {
    }
    else if (section == [self getMontionDetectSection]) {
    }
    else if (section == [self getRecordSettingSection]) {
    }
    else if (section == [self getDeviceInfoSectionIndex]) {
    }
    else {
        
    }
    return title;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    int row = 0;
    if (section == [self getSecurityCodeSection]) {
        if(self.bSupportSecuritySection) row++;
    }
    else if (section == [self getVideoSettingSection]) {
        if(self.bSupportVideoQualityRow) row++;
        if(self.bSupportVideoFlipRow) row++;
        if(self.bSupportEnvironmentModeRow) row++;
    }
    else if (section == [self getTimeZoneSection]) {
        if(self.bSupportTimeZoneSection) row++;
    }
    else if (section == [self getWifiSection]) {
        if(self.bSupportWiFiSection) row++;
    }
    else if (section == [self getMontionDetectSection]) {
        if(self.bSupportMontionDetectSection) row++;
    }
    else if (section == [self getRecordSettingSection]) {
        if(self.bSupportRecordSetRow) row++;
        if(self.bSupportSDCardSetRow) row++;
    }
    else if (section == [self getDeviceInfoSectionIndex]) {
        if(self.bSupportDeviceInfoSection) row++;
    }
    else {
        
    }
    return row;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat gHeight = 5;
    if (section == [self getSecurityCodeSection]) {
    }
    else if (section == [self getVideoSettingSection]) {
    }
    else if (section == [self getTimeZoneSection]) {
    }
    else if (section == [self getWifiSection]) {
    }
    else if (section == [self getMontionDetectSection]) {
    }
    else if (section == [self getRecordSettingSection]) {
    }
    else if (section == [self getDeviceInfoSectionIndex]) {
    }
    else {
        
    }
    return gHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat gHeight = 1;
    if (section == [self getSecurityCodeSection]) {
    }
    else if (section == [self getVideoSettingSection]) {
    }
    else if (section == [self getTimeZoneSection]) {
    }
    else if (section == [self getWifiSection]) {
    }
    else if (section == [self getMontionDetectSection]) {
    }
    else if (section == [self getRecordSettingSection]) {
    }
    else if (section == [self getDeviceInfoSectionIndex]) {
    }
    else {
        
    }
    return gHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CGFloat height = 44;
    if (section == [self getTimeZoneSection]) {
        if(row == [self getTimeZoneSettingRow])
        {
            height = 60;
        }
    }
    else{
        
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier1 = @"YLCommonActivityCell";
    static NSString *cellIdentifier2 = @"YLCommonActivityCell";
    
    UITableViewCell *cell = nil;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YLCommonActivityCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSString *strTitle = nil;
    NSString *strValue = nil;
    YLCommonActivityCell *cell0 = (YLCommonActivityCell *)cell;
    if (section == [self getSecurityCodeSection]) {
        if(row == [self getSecurityCodeRow])
        {
            strTitle = NSLocalizedString(@"Security Code", @"");
            [cell0.activity stopAnimating];
            cell0.activity.hidden = YES;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
    else if (section == [self getVideoSettingSection]) {
        if(row == [self getVideoQualitySettingRow])
        {
            strTitle = NSLocalizedString(@"Video Quality", @"");
            if(_videoQuality < 0)
            {
                [cell0.activity startAnimating];
                cell0.activity.hidden = NO;
            }
            else{
                [cell0.activity stopAnimating];
                cell0.activity.hidden = YES;
            }
            strValue = [self getVideoQualityDescribe:_videoQuality];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            
        }
        else if(row == [self getVideoFlipSettingRow])
        {
            strTitle = NSLocalizedString(@"Video Flip", @"");
            if (_videoFlip < 0)
            {
                [cell0.activity startAnimating];
                cell0.activity.hidden = NO;
            }
            else{
                [cell0.activity stopAnimating];
                cell0.activity.hidden = YES;
            }
            strValue = [self getVideoFlipDescribe:_videoFlip];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        else if(row == [self getEnvironmentSettingRow])
        {
            strTitle = NSLocalizedString(@"Environment Mode", @"");
            if (_envMode < 0)
            {
                [cell0.activity startAnimating];
                cell0.activity.hidden = NO;
            }
            else{
                [cell0.activity stopAnimating];
                cell0.activity.hidden = YES;
            }
            strValue = [self getEnironmentModeDescribe:_envMode];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
    else if (section == [self getTimeZoneSection]) {
        if(row == [self getTimeZoneSettingRow])
        {
            cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YLTimeZoneItemCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            YLTimeZoneItemCell *cell0 = (YLTimeZoneItemCell*)cell;
            strTitle = NSLocalizedString(@"Time Zone", @"");
            cell0.labelTitle.text = strTitle;
            if( isWaitingForSetTimeZoneResp ) {
                [cell0.activity startAnimating];
                cell0.activity.hidden = NO;
                //YLTimeZoneItemCell
                cell0.labelDetail.text = nil;
                cell0.labelDescribe.text = nil;
            }
            else {
                [cell0.activity stopAnimating];
                cell0.activity.hidden = YES;
                NSString *strTime = [NSString stringWithFormat:@"GMT %@%d:%02d", (_camera.nGMTDiff>=0)?@"+":@"", _camera.nGMTDiff/60, abs(_camera.nGMTDiff%60)];
                cell0.labelDetail.text = strTime;
                cell0.labelDescribe.text = _camera.strTimeZone;
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            }
            return cell;
        }
    }
    else if (section == [self getWifiSection]) {
        if(row == [self getWifiSettingRow])
        {
            strTitle = NSLocalizedString(@"WiFi", @"");
            if (isRecvWiFi) {
                strValue = [self getWiFiDescribe:_wifiStatus];
                [cell0.activity stopAnimating];
                cell0.activity.hidden = YES;
            }
            else {
                [cell0.activity startAnimating];
                cell0.activity.hidden = NO;
            }
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
    else if (section == [self getMontionDetectSection]) {
        if(row == [self getMotionDetectionSettingRow])
        {
            strTitle = NSLocalizedString(@"Motion Detection", @"");
            if (_motionDetection < 0) {
                
                [cell0.activity startAnimating];
                cell0.activity.hidden = NO;
            }
            else {
                [cell0.activity stopAnimating];
                cell0.activity.hidden = YES;
            }
            strValue = [self getMontionDetectionDescribe:_motionDetection];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
    else if (section == [self getRecordSettingSection]) {
        if(row == [self getRecordSettingRow])
        {
            strTitle = NSLocalizedString(@"Recording Mode", @"");
            if (_recordingMode < 0) {
                
                [cell0.activity startAnimating];
                cell0.activity.hidden = NO;
            }
            else {
                [cell0.activity stopAnimating];
                cell0.activity.hidden = YES;
            }
            strValue = [self getRecordModeDescribe:_recordingMode];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
        else if(row == [self getFormatSDCardRow])
        {
            strTitle = NSLocalizedString(@"Format SDCard", @"");
            [cell0.activity stopAnimating];
            cell0.activity.hidden = YES;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
    else if (section == [self getDeviceInfoSectionIndex]) {
        if(row == [self getDeviceInfoRow])
        {
            strTitle = NSLocalizedString(@"About Device", @"");
            [cell0.activity stopAnimating];
            cell0.activity.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else {
        
    }
    
    cell0.labelTitle.text = strTitle;
    cell0.labelDetail.text = strValue;
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (section == [self getSecurityCodeSection]) {
        if(row == [self getSecurityCodeRow])
        {
            [self gotoSecurityCodePage];
        }
    }
    else if (section == [self getVideoSettingSection]) {
        if(row == [self getVideoQualitySettingRow])
        {
            [self gotoVideoQualityPage];
        }
        else if(row == [self getVideoFlipSettingRow])
        {
            [self gotoVideoFlipSetPage];
        }
        else if(row == [self getEnvironmentSettingRow])
        {
            [self gotoEnvironmentModePage];
        }
    }
    else if (section == [self getTimeZoneSection]) {
        if(row == [self getTimeZoneSettingRow])
        {
            [self gotoTimeZonePage];
        }
    }
    else if (section == [self getWifiSection]) {
        if(row == [self getWifiSettingRow])
        {
            [self gotoWifiListPage];
        }
    }
    else if (section == [self getMontionDetectSection]) {
        if(row == [self getMotionDetectionSettingRow])
        {
            [self gotoMonitionDetectPage];
        }
    }
    else if (section == [self getRecordSettingSection]) {
        if(row == [self getRecordSettingRow])
        {
            [self gotoRecordModePage];
        }
        else if(row == [self getFormatSDCardRow])
        {
            [self gotoSDCardSetPage];
        }
    }
    else if (section == [self getDeviceInfoSectionIndex]) {
        if(row == [self getDeviceInfoRow])
        {
            [self gotoDeviceInfoPage];
        }
    }
    else {
        
    }
}

-(void) gotoSecurityCodePage
{
    DebugLog(@"");
    YLSecurityCodeSetController *vc = [[YLSecurityCodeSetController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    vc.delegate = self;
    vc.sOldPwd = self.camera.viewPwd;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void) gotoTimeZonePage
{
    DebugLog(@"");
    YLTimeZoneListController *vc = [[YLTimeZoneListController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    vc.delegate = self;
    YLTimeZoneInfo *timeInfo = [[YLTimeZoneInfo alloc] init];
    timeInfo.sDiffGMT = _camera.strTimeZone;
    timeInfo.nGMTMins = _camera.nGMTDiff;
    timeInfo.sDescribe = _camera.strTimeZone;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) gotoDeviceInfoPage
{
    DebugLog(@"");
    YLDeviceInfoController *vc = [[YLDeviceInfoController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    //vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) gotoWifiListPage
{
    DebugLog(@"");
    YLWiFiListController *vc = [[YLWiFiListController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    //vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) gotoSDCardSetPage
{
    DebugLog(@"");
    YLSDCardSetController *vc = [[YLSDCardSetController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    //vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) gotoVideoFlipSetPage
{
    DebugLog(@"");
    YLVideoFlipSetController *vc = [[YLVideoFlipSetController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    vc.delegate = self;
    vc.origValue = _videoFlip;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) gotoVideoQualityPage
{
    DebugLog(@"");
    YLVideoQualitySetController *vc = [[YLVideoQualitySetController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    vc.delegate = self;
    vc.origValue = _videoQuality;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) gotoEnvironmentModePage
{
    DebugLog(@"");
    YLEnvironmentModeController *vc = [[YLEnvironmentModeController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    vc.delegate = self;
    vc.origValue = _envMode;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void) gotoMonitionDetectPage
{
    DebugLog(@"");
    YLMontionDetectSetController *vc = [[YLMontionDetectSetController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    vc.delegate = self;
    vc.origValue = _motionDetection;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) gotoRecordModePage
{
    DebugLog(@"");
    YLRecordModeSetController *vc = [[YLRecordModeSetController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = self.camera;
    vc.delegate = self;
    vc.origValue = _recordingMode;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void) sendCommandToDeviceSetTheQuality:(NSInteger) _qulityValue
{
    if(nil == _camera) return;
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
// end add by kongyulu at 2013-11-11

-(void) updateTableView
{
    [self.tableView reloadData];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == _camera) {
        for( NSNumber* number in self.arrRequestIoCtrl ) {
            if( [number intValue] == (int)type ) {
                [self.arrRequestIoCtrl removeObject:number];
                break;
            }
        }
        if (type == IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP) {
            SMsgAVIoctrlGetStreamCtrlResq *s = (SMsgAVIoctrlGetStreamCtrlResq*)data;
            _videoQuality = s->quality;
            _videoQuality = self.camera.mVideoQuality;
            NSLog(@"获得设备的视频质量为：%zd", _videoQuality);
            /*影像品質: 最高(1) 高(2) 適中(3) 低(4) 最低(5)*/
            //发送命令，设置设备的视频质量为手机端一样
            //[self sendCommandToDeviceSetTheQuality:videoQuality];
        }
        else if (type == IOTYPE_USER_IPCAM_GET_VIDEOMODE_RESP) {
            SMsgAVIoctrlGetVideoModeResp *s = (SMsgAVIoctrlGetVideoModeResp*)data;
            _videoFlip = s->mode;
        }
        else if (type == IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP) {
            SMsgAVIoctrlGetEnvironmentResp *s = (SMsgAVIoctrlGetEnvironmentResp*)data;
            _envMode = s->mode;
        }
        else if(type == (int)IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP) {
            isWaitingForSetTimeZoneResp = FALSE;
        }
        else if( type == IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP ) {
            SMsgAVIoctrlTimeZone *s = (SMsgAVIoctrlTimeZone *)data;
            if( s->cbSize == sizeof(SMsgAVIoctrlTimeZone) &&
               s->nIsSupportTimeZone != 0 ) {
                NSLog( @">>>> IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP <OK>\n\tbIsSupportTimeZone:%d\n\tnGMTDiff:%d\n\tstrTimeZone:%@", s->nIsSupportTimeZone, s->nGMTDiff, ( strlen(s->szTimeZoneString) > 0 ) ? [NSString stringWithUTF8String:s->szTimeZoneString]:@"(null)" );
                _camera.strTimeZone = [[NSString stringWithFormat:@"%s", s->szTimeZoneString] copy];
                _camera.nGMTDiff = s->nGMTDiff;
            }
            isWaitingForSetTimeZoneResp = FALSE;

            [self.timerTimeZoneTimeOut invalidate];
            self.timerTimeZoneTimeOut = nil;
        }
        else if (type == IOTYPE_USER_IPCAM_LISTWIFIAP_RESP) {
            if( bTimerListWifiApResp ) {
                [self.timerTimeZoneTimeOut invalidate];
                self.timerTimeZoneTimeOut = nil;
                bTimerListWifiApResp = FALSE;
            }
            SMsgAVIoctrlListWifiApResp *s = (SMsgAVIoctrlListWifiApResp *)data;
            _wifiStatus = 0;
            NSLog( @"AP num:%d", s->number );
            for (int i = 0; i < s->number; ++i) {
                
                SWifiAp ap = s->stWifiAp[i];
                NSLog( @" [%d] ssid:%s status => %d", i, ap.ssid, ap.status );
                if (ap.status == 1 || ap.status == 2 || ap.status == 3 || ap.status == 4) {
                    self.wifiSSID = [NSString stringWithCString:ap.ssid encoding:NSUTF8StringEncoding];
                    _wifiStatus = ap.status;
                }
            }
            isRecvWiFi = true;
        }
        else if (type == IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP) {
            SMsgAVIoctrlGetMotionDetectResp *s = (SMsgAVIoctrlGetMotionDetectResp*)data;
            _motionDetection = s->sensitivity;
        }
        else if (type == IOTYPE_USER_IPCAM_GETRECORD_RESP) {
            
            SMsgAVIoctrlGetRecordResq *s = (SMsgAVIoctrlGetRecordResq*)data;
            _recordingMode = s->recordType;
        }
        else if (type == IOTYPE_USER_IPCAM_GETWIFI_RESP) {
            _wifiStatus = 0;
            SMsgAVIoctrlGetWifiResp *s = (SMsgAVIoctrlGetWifiResp *)data;
            self.wifiSSID = [NSString stringWithCString:(const char*)s->ssid encoding:NSUTF8StringEncoding];
            _wifiStatus = s->status;
            isRecvWiFi = true;
        }
        else if (type == IOTYPE_USER_IPCAM_GETWIFI_RESP_2) {
            _wifiStatus = 0;
            SMsgAVIoctrlGetWifiResp2 *s = (SMsgAVIoctrlGetWifiResp2 *)data;
            self.wifiSSID = [NSString stringWithCString:(const char*)s->ssid encoding:NSUTF8StringEncoding];
            _wifiStatus = s->status;
            isRecvWiFi = true;
        }
    }
    [self updateTableView];
}

#pragma mark YLSecurityCodeControllerDelegate

-(void) YLSecurityCodeSetController_savePasswordSucceed:(NSString *)sNewPwd
{
    isNeedReconn = true;
    isChangePasswd = true;
    self.sNewPassword = sNewPwd;
}

#pragma mark - WiFiNetworkDelegate Methods
- (void)didChangeWiFiAp:(NSString *)wifiSSID_ {
    
    self.wifiSSID = wifiSSID_;
    [self updateTableView];
}

#pragma mark YLTimeZoneListControllerDelegate
-(void) YLTimeZoneListControllerDelegate_didSelectItem:(id)item
{
    YLTimeZoneInfo *timeInfo = (YLTimeZoneInfo *)item;
    //NSString* tszTimeZone = timeInfo.sDescribe;
    NSInteger nGMTDiff_In_Mins = timeInfo.nGMTMins;
    mIoCtrlData_SetTimeZoneBefore.cbSize = sizeof(mIoCtrlData_SetTimeZoneBefore);
    mIoCtrlData_SetTimeZoneBefore.nIsSupportTimeZone = 1;
    mIoCtrlData_SetTimeZoneBefore.nGMTDiff = _camera.nGMTDiff;
    strcpy( mIoCtrlData_SetTimeZoneBefore.szTimeZoneString, [_camera.strTimeZone UTF8String] );
    
    SMsgAVIoctrlTimeZone setTimeZone;
    memset(&setTimeZone, 0, sizeof(setTimeZone));
    setTimeZone.cbSize = sizeof(setTimeZone);
    setTimeZone.nIsSupportTimeZone = 1;
    setTimeZone.nGMTDiff = (int)nGMTDiff_In_Mins;
    strcpy( setTimeZone.szTimeZoneString, [timeInfo.sDescribe UTF8String] );
    
    NSLog( @"更新时区，<<< recv IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ\n\tnIsSupportTimeZone: %d\n\tnGMTDiff: %d\n\tszTimeZoneString: %s\n---- Rise timer ----", setTimeZone.nIsSupportTimeZone, setTimeZone.nGMTDiff, setTimeZone.szTimeZoneString );
    [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SET_TIMEZONE_REQ Data:(char *)&setTimeZone DataSize:sizeof(SMsgAVIoctrlTimeZone)];
    
    isWaitingForSetTimeZoneResp = TRUE;
    self.timerTimeZoneTimeOut = [NSTimer scheduledTimerWithTimeInterval:12.0 target:self selector:@selector(timeoutSetTimeZoneResp:) userInfo:nil repeats:NO];
    
    [self updateTableView];
}

#pragma mark - getSetInfo
- (void)timeoutSetTimeZoneResp:(NSTimer *)timer
{
    NSLog( @"!!! IOTYPE_USER_IPCAM_SET_TIMEZONE_RESP TimeOut !!!" );
    isWaitingForSetTimeZoneResp = FALSE;
    self.timerTimeZoneTimeOut = nil;
    [self.tableView reloadData];
}

- (void)timeOutGetListWifiAPResp:(NSTimer *)timer
{
    bTimerListWifiApResp = FALSE;
    int timeOut = [(NSNumber*)timer.userInfo intValue];
    nTotalWaitingTime += timeOut;
    NSLog( @"!!! IOTYPE_USER_IPCAM_LISTWIFIAP_RESP TimeOut %dsec !!!", nTotalWaitingTime );
    if( nTotalWaitingTime <= 30 ) {
        timeOut = 20;
    }
    else if( nTotalWaitingTime <= 50 ) {
        timeOut = 10;
    }
    else if( nTotalWaitingTime > 50 ) {
        timeOut = 0;
        isRecvWiFi = true;
        _wifiStatus = 10;
        dispatch_async( dispatch_get_main_queue(), ^{
            [self updateTableView];
        });
    }
    if( timeOut > 0 ) {
        bTimerListWifiApResp = TRUE;
        self.timerListWifiApResp = [NSTimer scheduledTimerWithTimeInterval:timeOut target:self selector:@selector(timeOutGetListWifiAPResp:) userInfo:[NSNumber numberWithInt:timeOut] repeats:FALSE];
    }
}


#pragma mark YLEnvironmentModeControllerDelegate
-(void) YLEnvironmentModeControllerDelegate_didSetEnvironmentMode:(NSInteger)value
{
    self.envMode = value;
    [self updateTableView];
}

#pragma mark YLRecordModeSetControllerDelegate
-(void) YLRecordModeSetControllerDelegate_didRecordModeSetFinished:(NSInteger)value
{
    self.recordingMode = value;
    [self updateTableView];
}

#pragma mark YLMontionDetectSetControllerDelegate
-(void) YLMontionDetectSetControllerDelegate_didSetMontionDetectFinished:(NSInteger)value
{
    self.motionDetection = value;
    [self updateTableView];
}


#pragma mark YLVideoFlipSetControllerDelegate
-(void) YLVideoFlipSetControllerDelegate_didSetFinished:(NSInteger) value
{
    self.videoFlip = value;

    [self updateTableView];
}

#pragma mark YLVideoQualitySetControllerDelegate
-(void) YLVideoQualitySetControllerDelegate_didSetFinished:(NSInteger) value
{
    self.videoQuality = value;
    isNeedReconn = true;
    // begin add by kongyulu at 2013-11-11
    self.camera.mVideoQuality = value;
    [[YLGlobal shareInstance] updateCameraReso:(int)value uid:self.camera.uid];
    [self updateTableView];
}




-(void) getCameraInfo
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){

        SMsgAVIoctrlSetStreamCtrlReq *s0 = (SMsgAVIoctrlSetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        memset(s0, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        s0->channel = 0;
        s0->quality = _camera.mVideoQuality;
        [_camera sendIOCtrlToChannel:0
                               Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                               Data:(char *)s0
                           DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
        free(s0);
        
        SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
        s->channel = 0;
        [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
        free(s);
        
        SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
        [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
        free(s2);
        
        SMsgAVIoctrlTimeZone s3={0};
        s3.cbSize = sizeof(s3);
        [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
				
    });
}

-(void) initOrigeData
{
    isRecvWiFi = false;
    _wifiStatus = 0;
    isNeedReconn = false;
    isChangePasswd = false;
    self.sNewPassword = nil;
    
    _videoQuality = -1;
    _videoFlip = -1;
    _envMode = -1;
    self.wifiSSID = nil;
    
    _motionDetection = -1;
    _recordingMode = -1;
}

- (void)doRefresh
{
    
    [self initOrigeData];
    // register notification center
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIOCtrl:) name:@"didReceiveIOCtrl" object:nil];
    
    //	arrRequestIoCtrl = [[NSMutableArray alloc] initWithObjects:
    //							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP],
    //							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GET_VIDEOMODE_RESP],
    //							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP],
    //							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GET_TIMEZONE_RESP],
    //							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_LISTWIFIAP_RESP],
    //							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP],
    //							[NSNumber numberWithInt:IOTYPE_USER_IPCAM_GETRECORD_RESP],
    //						nil];
    
    // get video quality
    SMsgAVIoctrlGetStreamCtrlReq *structVideoQuality = malloc(sizeof(SMsgAVIoctrlGetStreamCtrlReq));
    memset(structVideoQuality, 0, sizeof(SMsgAVIoctrlGetStreamCtrlReq));
    
    [_camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETSTREAMCTRL_REQ
                           Data:(char *)structVideoQuality
                       DataSize:sizeof(SMsgAVIoctrlGetStreamCtrlReq)];
    free(structVideoQuality);
    
    // get video flip
    SMsgAVIoctrlGetVideoModeReq *structVideoFlip = malloc(sizeof(SMsgAVIoctrlGetVideoModeReq));
    memset(structVideoFlip, 0, sizeof(SMsgAVIoctrlGetVideoModeReq));
    structVideoFlip->channel = 0;
    
    [_camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GET_VIDEOMODE_REQ
                           Data:(char *)structVideoFlip
                       DataSize:sizeof(SMsgAVIoctrlGetVideoModeReq)];
    free(structVideoFlip);
    
    
    // get Env Mode
    SMsgAVIoctrlGetEnvironmentReq *structEnvMode = malloc(sizeof(SMsgAVIoctrlGetEnvironmentReq));
    memset(structEnvMode, 0, sizeof(SMsgAVIoctrlGetEnvironmentReq));
    structEnvMode->channel = 0;
    
    [_camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GET_ENVIRONMENT_REQ
                           Data:(char *)structEnvMode
                       DataSize:sizeof(SMsgAVIoctrlGetEnvironmentReq)];
    free(structEnvMode);
    
    // get TimeZone
    isWaitingForSetTimeZoneResp = TRUE;
    SMsgAVIoctrlTimeZone s3={0};
    s3.cbSize = sizeof(s3);
    [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
    
    // get WiFi info
    SMsgAVIoctrlListWifiApReq *structWiFi = malloc(sizeof(SMsgAVIoctrlListWifiApReq));
    memset(structWiFi, 0, sizeof(SMsgAVIoctrlListWifiApReq));
    
    bTimerListWifiApResp = TRUE;
    nTotalWaitingTime = 0;
    self.timerListWifiApResp = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timeOutGetListWifiAPResp:) userInfo:[NSNumber numberWithInt:30] repeats:FALSE];
    [_camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_LISTWIFIAP_REQ
                           Data:(char *)structWiFi
                       DataSize:sizeof(SMsgAVIoctrlListWifiApReq)];
    free(structWiFi);
    
    
    // get MotionDetection info
    SMsgAVIoctrlGetMotionDetectReq *structMotionDetection = malloc(sizeof(SMsgAVIoctrlGetMotionDetectReq));
    memset(structMotionDetection, 0, sizeof(SMsgAVIoctrlGetMotionDetectReq));
    
    structMotionDetection->channel = 0;
    [_camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETMOTIONDETECT_REQ
                           Data:(char *)structMotionDetection
                       DataSize:sizeof(SMsgAVIoctrlGetMotionDetectReq)];
    free(structMotionDetection);
    
    
    // get RecordingMode info
    SMsgAVIoctrlGetRecordReq *structRecordingMode = malloc(sizeof(SMsgAVIoctrlGetRecordReq));
    memset(structRecordingMode, 0, sizeof(SMsgAVIoctrlGetRecordReq));
    
    structRecordingMode->channel = 0;
    [_camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_GETRECORD_REQ
                           Data:(char *)structRecordingMode
                       DataSize:sizeof(SMsgAVIoctrlGetRecordReq)];
    free(structRecordingMode);
}

@end
