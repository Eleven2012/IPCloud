//
//  YLLiveVideoController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/21.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLLiveVideoController.h"
//#import "YLPhotoListController.h"
#import "YLOpenGLView.h"
#import "WEPopoverController.h"
#import "YLChannelListController.h"
#import "YLPictureListController.h"

@interface YLLiveVideoController ()<YLChannelListControllerDelegate,MyCameraDelegate, MonitorTouchDelegate, UIScrollViewDelegate, WEPopoverControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    NSInteger selectedChannel;
    ENUM_AUDIO_MODE selectedAudioMode;
    unsigned short mCodecId;
    BOOL bStopShowCompletedLock;
    int wrongPwdRetryTime;
}
@property (weak, nonatomic) IBOutlet UIButton *btnConnectMode;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelVideo;
@property (weak, nonatomic) IBOutlet UILabel *labelFrame;
@property (weak, nonatomic) IBOutlet UILabel *labelQuality;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoActivity;
@property (weak, nonatomic) IBOutlet UIScrollView *videoBgScrollView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbarDirection;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemUp;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemDown;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemLeft;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemRight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemAlbum;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemSnap;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemAudio;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemTextField;
@property (weak, nonatomic) IBOutlet UITextField *textFieldStatus;
@property (weak, nonatomic) IBOutlet Monitor *monitorPortrait;
@property (weak, nonatomic) IBOutlet Monitor *monitorLandscape;

@property (weak, nonatomic) IBOutlet UIScrollView *videoBgScrollView2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoActivity2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemAlbum2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemSnap2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemAudio2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemTextField2;
@property (weak, nonatomic) IBOutlet UITextField *textFieldStatus2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemUp2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemDown2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemLeft2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemRight2;

@property (nonatomic, strong) YLOpenGLView *glView;
@property (nonatomic, strong) WEPopoverController *multiStreamPopoverController;

@property (strong, nonatomic) IBOutlet UIView *viewPortrait;
@property (strong, nonatomic) IBOutlet UIView *viewLandscape;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewTest;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBarLandcape;

@end

@implementation YLLiveVideoController


-(void) dealloc
{
    [self registerNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


-(void) initData
{
    [super initData];
    [self registerNotifications];

    wrongPwdRetryTime = 0;
    selectedChannel = _camera.lastChannel;
    
    self.labelFrame.text = nil;
    self.labelVideo.text = nil;
    self.labelStatus.text = nil;
    self.labelQuality.text = nil;
}

-(void) initBarButton
{
    [super initBarButton];
#ifndef MacGulp
    self.navigationItem.title = NSLocalizedString(@"Live View", @"");
    
#else
    self.title = camera.name;
#endif
    
#ifdef MacGulp
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"Reload", nil)
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(reload:)];
    self.navigationItem.rightBarButtonItem = reloadButton;
#endif
}



-(void) btnBarLeftButtonClicked:(id)sender
{
    [self closeVideo];
}


-(void) initUI
{
    [super initUI];

    [_monitorPortrait setMinimumGestureLength:100 MaximumVariance:50];
    [_monitorPortrait setUserInteractionEnabled:YES];
    _monitorPortrait.contentMode = UIViewContentModeScaleToFill;
    _monitorPortrait.backgroundColor = [UIColor blackColor];
    _monitorPortrait.delegate = self;
    
    [_monitorLandscape setMinimumGestureLength:100 MaximumVariance:50];
    [_monitorLandscape setUserInteractionEnabled:YES];
    _monitorLandscape.contentMode = UIViewContentModeScaleAspectFit;
    _monitorLandscape.backgroundColor = [UIColor blackColor];
    _monitorLandscape.delegate = self;
    
    self.videoBgScrollView.minimumZoomScale = ZOOM_MIN_SCALE;
    self.videoBgScrollView.maximumZoomScale = ZOOM_MAX_SCALE;
    self.videoBgScrollView.contentMode = UIViewContentModeScaleAspectFit;
    self.videoBgScrollView.contentSize = self.videoBgScrollView.frame.size;
    self.videoBgScrollView.delegate = self;
    self.videoBgScrollView2.minimumZoomScale = ZOOM_MIN_SCALE;
    self.videoBgScrollView2.maximumZoomScale = ZOOM_MAX_SCALE;
    self.videoBgScrollView2.contentMode = UIViewContentModeScaleAspectFit;
    self.videoBgScrollView2.contentSize = self.videoBgScrollView2.frame.size;
    self.videoBgScrollView2.delegate = self;

    self.textFieldStatus.enabled = FALSE;
    self.textFieldStatus.text = NSLocalizedString(@"Mute", @"");

    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
    {
        // 7.0 系统的适配处理。
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.navigationController.navigationBar.translucent = NO;
        self.tabBarController.tabBar.translucent = NO;
    }
    else
    {
        //设置导航栏，背景颜色和字体颜色
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        self.navigationController.navigationBar.titleTextAttributes = dict;
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    self.labelQuality.hidden = YES;
    if (g_bDiagnostic) {
        self.labelQuality.hidden = NO;
    }
    
    _videoActivity.hidden = YES;
    _videoActivity2.hidden = YES;
}

-(void) registerNotifications
{
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cameraStopShowCompleted:) name: @"CameraStopShowCompleted" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTheCameraVideoQualityFromDB)
                                                 name:@"updateTheCameraVideoquality"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

-(void) removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updateTheCameraVideoquality"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"CameraStopShowCompleted"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self changeOrientation:self.interfaceOrientation];
    // begin add by kongyulu at 2013-11-13
    [self updateTheCameraVideoQualityFromDB];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_camera != nil) {
        _camera.delegate2 = self;
#ifndef MacGulp
        if ([_camera getMultiStreamSupportOfChannel:0] && [[_camera getSupportedStreams] count] > 1) {
            if (self.navigationItem.rightBarButtonItem == nil) {
                UIBarButtonItem *streamButton = [[UIBarButtonItem alloc]
                                                 initWithTitle:NSLocalizedString(@"Channel", @"")
                                                 style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(selectChannel:)];
                self.navigationItem.rightBarButtonItem = streamButton;
            }
            self.navigationItem.prompt = [NSString stringWithFormat:@"%@ - CH%zd", _camera.name, selectedChannel + 1];
        }
        else {
            self.navigationItem.prompt = _camera.name;
            self.navigationItem.rightBarButtonItem = nil;
        }
#endif
        //set status
        [self getCameraStatus];
        if (_camera.sessionState != CONNECTION_STATE_CONNECTED)
            [_camera connect:_camera.uid];
        
        if ([_camera getConnectionStateOfChannel:0] != CONNECTION_STATE_CONNECTED) {
            [_camera start:0];
            
            SMsgAVIoctrlSetStreamCtrlReq *s0 = (SMsgAVIoctrlSetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
            memset(s0, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
            
            s0->channel = 0;
            s0->quality = _camera.mVideoQuality;
            
            [_camera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                                   Data:(char *)s0
                               DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
            free(s0);
            // begin add by kongyulu at 2013-11-13
            NSLog(@"-----Set the device's videoqulity");
            // end add by kongyulu at 2013-11-13
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
        }
        
        if ( selectedChannel != 0 && [_camera getConnectionStateOfChannel:selectedChannel] != CONNECTION_STATE_CONNECTED) {
            [_camera start:selectedChannel];
        }
        
        //设置设备的视频质量
        [self setTheDeviceQulity];
        [_camera startShow:selectedChannel];
        
        [self showHUD:NSLocalizedString(@"Loading...", @"")];
        [self activeAudioSession];
        
        if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
            [_camera startSoundToPhone:selectedChannel];
            _textFieldStatus.text = NSLocalizedString(@"Listening", @"");
            _barItemAudio.image = [UIImage imageNamed:@"speaker.png"];
        }
        
        if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {
            [_camera startSoundToDevice:selectedChannel];
            _textFieldStatus.text = NSLocalizedString(@"Speaking", @"");
            _barItemAudio.image = [UIImage imageNamed:@"microphone.png"];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_camera != nil) {
        [_camera stopShow:selectedChannel];
        [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
        [_camera stopSoundToDevice:selectedChannel];
        [_camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark datasource
-(YLOpenGLView *) glView
{
    if(_glView == nil)
    {
        _glView = [[YLOpenGLView alloc] initWithFrame:self.monitorLandscape.frame];
        [_glView setMinimumGestureLength:100 MaximumVariance:50];
        _glView.delegate = self;
        [_glView attachCamera:_camera];
    }
    return _glView;
}

-(WEPopoverController *) multiStreamPopoverController
{
    if(_multiStreamPopoverController == nil)
    {
        YLChannelListController *controller = [[YLChannelListController alloc] init];
        controller.camera = _camera;
        controller.selectedChannel = selectedChannel;
        controller.delegate = self;
        _multiStreamPopoverController = [[WEPopoverController alloc] initWithContentViewController:controller];
    }
    return _multiStreamPopoverController;
}

#pragma actions
- (IBAction)barItemUpClicked:(id)sender {
    [self startPTZ:DirectionTiltUp];
}

- (IBAction)barItemDownClicked:(id)sender {
    [self startPTZ:DirectionTiltDown];
}

- (IBAction)barItemLeftClicked:(id)sender {
    [self startPTZ:DirectionPanLeft];
}

- (IBAction)barItemRightClicked:(id)sender {
    [self startPTZ:DirectionPanRight];
}

- (IBAction)barAlbumClicked:(id)sender {
    [_monitorPortrait deattachCamera];
    [_monitorLandscape deattachCamera];
    [self gotoThePhotoListPage];
    
}

- (IBAction)barItemSnapClicked:(id)sender {
    [self snapOneImage];
}

- (IBAction)barItemAuidoClicked:(id)sender {
    [self showAudioMenu];
}

- (IBAction)barItemTextFieldClicked:(id)sender {
}

- (void)selectChannel:(id)sender {
    [self showChooseChannelMenu:sender];
}


-(void) closeVideo
{

    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", _camera.uid];;
    UIImage *img = [_camera getImageByChannel:selectedChannel];
    if([[YLGlobal shareInstance] saveOneSnapImage:img fileName:imgName cameraUID:self.camera.uid])
    {
        //[self showTips2:NSLocalizedString(@"Snapshot saved", @"")];
    }
    [self.monitorLandscape deattachCamera];
    [self.monitorPortrait deattachCamera];
    
    if ([self.camera isKindOfClass:[MyCamera class]]) {
        MyCamera *cam = (MyCamera *)_camera;
        cam.lastChannel = selectedChannel;
    }
    
    if (_camera != nil) {
        [_camera stopShow:selectedChannel];
        [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
        [_camera stopSoundToDevice:selectedChannel];
        [_camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];
        self.camera = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}


- (BOOL) updateTheCameraVideoQualityFromDB
{
    if (_camera) {
        _camera.mVideoQuality = [[YLGlobal shareInstance] getVideoQuality:_camera.uid];
        return YES;
    }
    return NO;
}


- (void) setTheDeviceQulity
{
    if (_camera != nil) {
        SMsgAVIoctrlSetStreamCtrlReq *s0 = (SMsgAVIoctrlSetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        memset(s0, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        s0->channel = 0;
        s0->quality = _camera.mVideoQuality;
        [_camera sendIOCtrlToChannel:0
                               Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                               Data:(char *)s0
                           DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
        free(s0);
    }
}

-(void) gotoThePhotoListPage
{
    YLPictureListController *vc = [[YLPictureListController alloc] init];
    vc.camera = self.camera;
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    vc.directoryPath = [dirs objectAtIndex:0];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


-(BOOL) startPTZ:(Direction) _direction
{
    if(nil == _camera) return NO;
    return  [_camera startPT:_direction channel:selectedChannel];
}

-(BOOL) stopPTZ
{
    if(nil == _camera) return NO;
    return  [_camera stopPT];
}

-(void) showChooseChannelMenu:(id) sender
{
    YLChannelListController *controller = (YLChannelListController *)self.multiStreamPopoverController.contentViewController;
    controller.selectedChannel = selectedChannel;
    [self.multiStreamPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void) showAudioMenu
{
    if ([_camera getAudioInSupportOfChannel:selectedChannel] && [_camera getAudioOutSupportOfChannel:selectedChannel]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Mute", @""),
                                      NSLocalizedString(@"Listen", @""),
                                      NSLocalizedString(@"Speak", @""), nil];
        [actionSheet showInView:self.view];

    }
    else if ([_camera getAudioInSupportOfChannel:selectedChannel] && ![_camera getAudioOutSupportOfChannel:selectedChannel]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Mute", @""),
                                      NSLocalizedString(@"Listen", @""), nil];
        [actionSheet showInView:self.view];
    }
    else if (![_camera getAudioInSupportOfChannel:selectedChannel] && [_camera getAudioOutSupportOfChannel:selectedChannel]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Mute", @"") ,
                                      NSLocalizedString(@"Speak", @""), nil];
        [actionSheet showInView:self.view];
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                                                   destructiveButtonTitle:NSLocalizedString(@"Mute", @"")
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
}

-(NSString *) getCameraStatus
{
    NSString *strStatusDescribe = nil;
    if (_camera.sessionState == CONNECTION_STATE_CONNECTING) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Connecting...", @""), _camera.connTimes, _camera.connFailErrCode];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Connecting...", @"");
        }
        NSLog(@"%@ connecting", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Off line", @""), _camera.connTimes, _camera.connFailErrCode];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Off line", @"");
        }
        NSLog(@"%@ off line", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Unknown Device", @""), _camera.connTimes, _camera.connFailErrCode];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Unknown Device", @"");
        }
        NSLog(@"%@ unknown device", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_TIMEOUT) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Timeout", @""), _camera.connTimes, _camera.connFailErrCode];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Timeout", @"");
        }
        NSLog(@"%@ timeout", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Unsupported", @""), _camera.connTimes, _camera.connFailErrCode];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Unsupported", @"");
        }
        NSLog(@"%@ unsupported", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ A.%zd(%zdL)", NSLocalizedString(@"Connect Failed", @""), _camera.connTimes, _camera.connFailErrCode];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Connect Failed", @"");
        }
        NSLog(@"%@ connected failed", _camera.uid);
    }
    
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
        
#ifndef SHOW_SESSION_MODE
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ [%@]%zd,C:%zd,D:%zd,r%zd", NSLocalizedString(@"Online", @""), [MyCamera getConnModeString:_camera.sessionMode], _camera.connTimes, _camera.natC, _camera.natD, _camera.nAvResend];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Online", @"");
        }
#else
        if (_camera.sessionMode == CONNECTION_MODE_P2P) {
            [self.btnConnectMode setImage:[UIImage imageNamed:@"ConnectMode_P2P"] forState:UIControlStateNormal];
            
            strStatusDescribe = [NSString stringWithFormat:@"%@ / P2P", NSLocalizedString(@"Online", @"")];
        }
        else if (_camera.sessionMode == CONNECTION_MODE_RELAY) {
            [self.btnConnectMode setImage:[UIImage imageNamed:@"ConnectMode_RLY"] forState:UIControlStateNormal];
            strStatusDescribe = [NSString stringWithFormat:@"%@ / Relay", NSLocalizedString(@"Online", @"")];
        }
        else if (_camera.sessionMode == CONNECTION_MODE_LAN) {
            [self.btnConnectMode setImage:[UIImage imageNamed:@"ConnectMode_LAN"] forState:UIControlStateNormal];
            strStatusDescribe = [NSString stringWithFormat:@"%@ / %@", NSLocalizedString(@"Online", @""), NSLocalizedString(@"LAN", @"")];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Online", @"");
        }
#endif
        
        self.barItemAudio.enabled = YES;
        NSLog(@"%@ online", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_CONNECTING)", NSLocalizedString(@"Connecting...", @""), _camera.connTimes];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Connecting...", @"");
        }
        NSLog(@"%@ connecting", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_DISCONNECTED)", NSLocalizedString(@"Off line", @""), _camera.connTimes];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Off line", @"");
        }
        NSLog(@"%@ off line", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_UNKNOWN_DEVICE)", NSLocalizedString(@"Unknown Device", @""), _camera.connTimes];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Unknown Device", @"");
        }
        NSLog(@"%@ unknown device", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_WRONG_PASSWORD)", NSLocalizedString(@"Wrong Password", @""), _camera.connTimes];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Wrong Password", @"");
        }
        NSLog(@"%@ wrong password", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_TIMEOUT)", NSLocalizedString(@"Timeout", @""), _camera.connTimes];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Timeout", @"");
        }
        NSLog(@"%@ timeout", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_UNSUPPORTED)", NSLocalizedString(@"Unsupported", @""), _camera.connTimes];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Unsupported", @"");
        }
        NSLog(@"%@ unsupported", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
        if( g_bDiagnostic ) {
            strStatusDescribe = [NSString stringWithFormat:@"%@ B.%zd(CONNECTION_STATE_NONE)", NSLocalizedString(@"Connecting...", @""), _camera.connTimes];
        }
        else {
            strStatusDescribe = NSLocalizedString(@"Connecting...", @"");
        }
        NSLog(@"%@ wait for connecting", _camera.uid);
    }
    self.labelStatus.text = strStatusDescribe;
    return  strStatusDescribe;

}

-(BOOL) snapOneImage
{
    BOOL bResult = NO;
    NSString *imgName = [NSString stringWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970]];
    UIImage *img = [_camera getImageByChannel:selectedChannel];
    //_imgViewTest.image = img;
    if([[YLGlobal shareInstance] saveOneSnapImage:img fileName:imgName cameraUID:self.camera.uid])
    {
        [self showTips2:NSLocalizedString(@"Snapshot saved", @"")];
        bResult = YES;
    }
    return bResult;
}

- (void)reportCodecId:(NSValue*)pointer
{
    unsigned short *pnCodecId = (unsigned short *)[pointer pointerValue];
    mCodecId = *pnCodecId;
    if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
            [self.videoBgScrollView2 bringSubviewToFront:_monitorLandscape/*self.glView*/];
        }
        else {
            [self.videoBgScrollView bringSubviewToFront:_monitorLandscape/*self.glView*/];
        }
    }
    else {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
            [self.videoBgScrollView2 bringSubviewToFront:self.glView];
        }
        else {
            [self.videoBgScrollView bringSubviewToFront:self.glView];
        }		
    }
}

#pragma mark UIScrollViewDelegate
- (CGRect)zoomRectForScrollView:(UIScrollView *)_scrollView withScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = _scrollView.frame.size.height / scale;
    zoomRect.size.width  = _scrollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    
//    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
//        return _videoBgScrollView;
//    }
//    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//             self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        return _videoBgScrollView2;
//    }
//    else return nil;
//}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(CGFloat)scale
{
    if( _glView ) {
        _glView.frame = CGRectMake( 0, 0, scrollView.frame.size.width*scale, scrollView.frame.size.height*scale );
        NSLog( @"{0,0,%d,%d}", (int)(scrollView.frame.size.width*scale), (int)(scrollView.frame.size.height*scale) );
    }
}

#pragma mark - YLChannelListControllerDelegate
-(void) YLChannelListControllerDelegate_didChannelChanged:(NSInteger)nIndex
{
    [self.multiStreamPopoverController dismissPopoverAnimated:YES];
    if( selectedChannel != nIndex ) {
        [_camera stopShow:selectedChannel];
        [self waitStopShowCompleted:3000];
        [_camera stopSoundToDevice:selectedChannel];
        [_camera stopSoundToPhone:selectedChannel];
        [self unactiveAudioSession];
        selectedChannel = nIndex;
        self.navigationItem.prompt = [NSString stringWithFormat:@"%@ - CH%zd", _camera.name, selectedChannel + 1];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(cameraStartShow:) userInfo:nil repeats:NO];
    }
}

#pragma mark - WEPopoverControllerDelegate implementation
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
    //Safe to release the popover here
    thePopoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
    //The popover is automatically dismissed if you click outside it, unless you return NO here
    return NO;
}



#pragma mark - MonitorDelegate
- (void)monitor:(Monitor *)monitor gesturePinched:(CGFloat)scale
{
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if( scale <= self.videoBgScrollView2.maximumZoomScale )
            [self.videoBgScrollView2 setZoomScale:scale animated:YES];
    }
    else {
        NSLog( @"CameraLiveViewController - Pinched scale:%f/%f", scale, self.videoBgScrollView.maximumZoomScale );
        if( scale <= self.videoBgScrollView.maximumZoomScale )
            [self.videoBgScrollView setZoomScale:scale animated:YES];
    }
}


#pragma mark - UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*
    if (buttonIndex == 1) {
        
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        NSString *acc = @"admin";
        NSString *pwd = textField.text;
        
        if (database != NULL) {
            if (![database executeUpdate:@"UPDATE device SET view_pwd=? WHERE dev_uid=?", pwd, camera.uid]) {
                NSLog(@"Fail to update device to database.");
            }
        }
        if (camera.sessionState != CONNECTION_STATE_CONNECTED)
            [camera connect:camera.uid];
        
        [camera setViewAcc:acc];
        [camera setViewPwd:pwd];
        [camera start:selectedChannel];
        [camera startShow:selectedChannel ScreenObject:self];
        
        [loadingViewLandscape setHidden:NO];
        [loadingViewPortrait setHidden:NO];
        [loadingViewPortrait startAnimating];
        [loadingViewLandscape startAnimating];
        
        [self activeAudioSession];
        
        if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
            [camera startSoundToPhone:selectedChannel];
            audioStatusTextField.text = NSLocalizedString(@"Listening", @"");
            audioButton.image = [UIImage imageNamed:@"speaker.png"];
        }
        
        if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {
            [camera startSoundToDevice:selectedChannel];
            audioStatusTextField.text = NSLocalizedString(@"Speaking", @"");
            audioButton.image = [UIImage imageNamed:@"microphone.png"];
        }
    }
     */
}

#pragma mark - UIActionSheetDelegate implementation
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int mode = -1;
    if ([_camera getAudioInSupportOfChannel:selectedChannel] && [_camera getAudioOutSupportOfChannel:selectedChannel]) {
        if (buttonIndex == 0) {
            mode = 0;
        } else if (buttonIndex == 1) { // Device to Phone
            mode = 1;
        } else if (buttonIndex == 2) { // Phone to Device
            mode = 2;
        }
    } else if ([_camera getAudioInSupportOfChannel:selectedChannel] && ![_camera getAudioOutSupportOfChannel:selectedChannel]) {
        if (buttonIndex == 0) {
            mode = 0;
        } else if (buttonIndex == 1) { // Device to Phone
            mode = 1;
        }
    } else if (![_camera getAudioInSupportOfChannel:selectedChannel] && [_camera getAudioOutSupportOfChannel:selectedChannel]) {
        if (buttonIndex == 0) {
            mode = 0;
        } else if (buttonIndex == 1) { // Phone to Device
            mode = 2;
        }
    } else {
        mode = 0;
    }
    if (mode == 0) {
        if (_camera != nil) {
            _textFieldStatus.text = NSLocalizedString(@"Mute", @"");
            _barItemAudio.image = [UIImage imageNamed:@"speaker_mute.png"];
            selectedAudioMode = AUDIO_MODE_OFF;
            [_camera stopSoundToDevice:selectedChannel];
            [_camera stopSoundToPhone:selectedChannel];
            [self unactiveAudioSession];
        }
        
    } else if (mode == 1) { // Device to Phone
        if (_camera != nil) {
            selectedAudioMode = AUDIO_MODE_SPEAKER;
            _textFieldStatus.text = NSLocalizedString(@"Listening", @"");
            _barItemAudio.image = [UIImage imageNamed:@"speaker.png"];
            [_camera stopSoundToDevice:selectedChannel];
            [self unactiveAudioSession];
            [self activeAudioSession];
            [_camera startSoundToPhone:selectedChannel];
        }
    } else if (mode == 2) { // Phone to Device
        if (_camera != nil) {
            selectedAudioMode = AUDIO_MODE_MICROPHONE;
            _textFieldStatus.text = NSLocalizedString(@"Speaking", @"");
            _barItemAudio.image = [UIImage imageNamed:@"microphone.png"];
            [_camera stopSoundToPhone:selectedChannel];
            [self unactiveAudioSession];
            [self activeAudioSession];
            [_camera startSoundToDevice:selectedChannel];
        }
    }
}

#pragma mark - AudioSession implementations
- (void)activeAudioSession
{
    OSStatus error;
    UInt32 category = kAudioSessionCategory_LiveAudio;
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
        category = kAudioSessionCategory_LiveAudio;
        NSLog(@"kAudioSessionCategory_LiveAudio");
    }
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {
        category = kAudioSessionCategory_PlayAndRecord;
        NSLog(@"kAudioSessionCategory_PlayAndRecord");
    }
    error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    if (error) printf("couldn't set audio category!");
    error = AudioSessionSetActive(true);
    if (error) printf("AudioSessionSetActive (true) failed");
}

- (void)unactiveAudioSession {
    AudioSessionSetActive(false);
}
#pragma mark - UIApplication Delegate
- (void)applicationWillResignActive:(NSNotification *)notification
{
    [_camera stopShow:selectedChannel];
    [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
    [_camera stopSoundToDevice:selectedChannel];
    [_camera stopSoundToPhone:selectedChannel];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [_camera startShow:selectedChannel];
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE)
        [_camera startSoundToDevice:selectedChannel];
    if (selectedAudioMode == AUDIO_MODE_SPEAKER)
        [_camera startSoundToPhone:selectedChannel];
}

- (void)waitStopShowCompleted:(unsigned int)uTimeOutInMs
{
    unsigned int uStart = (unsigned int)[YLComFun getTickTime];
    while( bStopShowCompletedLock == FALSE ) {
        usleep(1000);
        unsigned int now = (unsigned int)[YLComFun getTickTime];
        if( now - uStart >= uTimeOutInMs ) {
            NSLog( @"CameraLiveViewController - waitStopShowCompleted !!!TIMEOUT!!!" );
            break;
        }
    }
}

- (void)cameraStopShowCompleted:(NSNotification *)notification
{
    bStopShowCompletedLock = TRUE;
}

- (void)cameraStartShow:(NSTimer*)theTimer
{
    [_camera startShow:selectedChannel];
    [self showHUD:NSLocalizedString(@"Loading...", @"")];
    [self activeAudioSession];
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) [_camera startSoundToPhone:selectedChannel];
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [_camera startSoundToDevice:selectedChannel];
}


#pragma mark - MyCamera Delegate Methods

- (void)camera:(MyCamera *)camera_ _didChangeSessionStatus:(NSInteger)status
{
    if (camera_ == _camera) {
        NSString *strStatus = [self getCameraStatus];
        dispatch_async( dispatch_get_main_queue(), ^{
            self.labelStatus.text = strStatus;
        });
        if (status == CONNECTION_STATE_TIMEOUT) {
            [_camera stopShow:selectedChannel];
            [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
            [_camera stopSoundToDevice:selectedChannel];
            [_camera stopSoundToPhone:selectedChannel];
            [_camera disconnect];
            [self unactiveAudioSession];
            [_camera connect:_camera.uid];
            [_camera start:0];
            [_camera startShow:selectedChannel];
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
            
            dispatch_async( dispatch_get_main_queue(), ^{
                [self showHUD:NSLocalizedString(@"Loading...", @"")];
            });
            
            [self activeAudioSession];
            if (selectedAudioMode == AUDIO_MODE_SPEAKER) [_camera startSoundToPhone:selectedChannel];
            if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [_camera startSoundToDevice:selectedChannel];
        }
    }
}

- (void)camera:(MyCamera *)camera_ _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    if (camera_ == _camera) {
        if (channel == selectedChannel) {
#ifndef MacGulp
            if ([_camera getMultiStreamSupportOfChannel:0] &&
                [[_camera getSupportedStreams] count] > 1) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self showHUD:NSLocalizedString(@"Loading...", @"")];
                    
                    if (self.navigationItem.rightBarButtonItem == nil) {
                        UIBarButtonItem *streamButton = [[UIBarButtonItem alloc]
                                                         initWithTitle:NSLocalizedString(@"Channel", @"")
                                                         style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(selectChannel:)];
                        self.navigationItem.rightBarButtonItem = streamButton;
                    }
                    
                    self.navigationItem.prompt = [NSString stringWithFormat:@"%@ - CH%zd", _camera.name, selectedChannel + 1];
                });

            }
            else {
                dispatch_async( dispatch_get_main_queue(), ^{
                    self.navigationItem.prompt = _camera.name;
                    self.navigationItem.rightBarButtonItem = nil;
                });
            }
#endif
        }
        if (channel == selectedChannel) {
            NSString *strStatus = [self getCameraStatus];
            dispatch_async( dispatch_get_main_queue(), ^{
                self.labelStatus.text = strStatus;
            });
            
            if (status == CONNECTION_STATE_WRONG_PASSWORD) {
                [_camera stopShow:selectedChannel];
                [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                [_camera stop:selectedChannel];
                if (wrongPwdRetryTime++ < 3) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Correct the wrong password", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Dismiss", nil), NSLocalizedString(@"OK", nil), nil];
                    [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
                    [alert show];
                }
                
            } else if (status == CONNECTION_STATE_CONNECTED) {
                
                // self.statusLabel.text = NSLocalizedString(@"Connected", nil);
                
            } else if (status == CONNECTION_STATE_CONNECTING) {
                
                // self.statusLabel.text = NSLocalizedString(@"Connecting...", nil);
                
            } else if (status == CONNECTION_STATE_TIMEOUT) {
                [_camera stopShow:selectedChannel];
                [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                [_camera stopSoundToDevice:selectedChannel];
                [_camera stopSoundToPhone:selectedChannel];
                [_camera disconnect];
                [self unactiveAudioSession];
                [_camera connect:_camera.uid];
                [_camera start:0];
                [_camera startShow:selectedChannel];
                
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
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self showHUD:NSLocalizedString(@"Loading...", @"")];
                });
                
                [self activeAudioSession];
                
                if (selectedAudioMode == AUDIO_MODE_SPEAKER) [_camera startSoundToPhone:selectedChannel];
                if (selectedAudioMode == AUDIO_MODE_MICROPHONE) [_camera startSoundToDevice:selectedChannel];
                
            } else {
                
                // self.statusLabel.text = NSLocalizedString(@"Off line", nil);
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self hideHUD];
                });
            }
        }
    }
}

- (void)camera:(MyCamera *)camera _didReceiveJPEGDataFrame:(const char *)imgData DataSize:(NSInteger)size
{
    dispatch_async( dispatch_get_main_queue(), ^{
        [self hideHUD];
    });
}

- (void)camera:(MyCamera *)camera _didReceiveRawDataFrame:(const char *)imgData VideoWidth:(NSInteger)width VideoHeight:(NSInteger)height
{
    dispatch_async( dispatch_get_main_queue(), ^{
        [self hideHUD];
        if (g_bDiagnostic) {
            self.labelVideo.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Quality", @""), [camera getOverAllQualityString]];
            self.labelVideo.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        }
    });
}

- (void)camera:(MyCamera *)camera_ _didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned long)frameCount IncompleteFrameCount:(unsigned long)incompleteFrameCount {
    
    if (camera_ == _camera) {
        if( videoWidth > 1280 || videoHeight > 720 ) {
            NSLog( @"!!!!!!!! ERROR !!!!!!!!" );
            return;
        }
        
        CGSize maxZoom = CGSizeMake((videoWidth*2.0 > 1280)?1280:videoWidth*2.0, (videoHeight*2.0 > 720)?720:videoHeight*2.0);
        if( _glView && videoWidth > 0 && videoHeight > 0 ) {
            [self recalcMonitorRect:CGSizeMake(videoWidth, videoHeight)];
            self.glView.maxZoom = maxZoom;
        }
        if( maxZoom.width / self.videoBgScrollView.frame.size.width > 1.0 ) {
            self.videoBgScrollView.maximumZoomScale = maxZoom.width / self.videoBgScrollView.frame.size.width;
        }
        else {
            self.videoBgScrollView.maximumZoomScale = 1;
        }
        if( maxZoom.width / self.videoBgScrollView2.frame.size.width > 1.0 ) {
            self.videoBgScrollView2.maximumZoomScale = maxZoom.width / self.videoBgScrollView2.frame.size.width;
        }
        else {
            self.videoBgScrollView2.maximumZoomScale = 1;
        }
        
#ifndef MacGulp
        self.labelVideo.text = [NSString stringWithFormat:@"%zdx%zd / FPS: %zd / BPS: %zd Kbps", videoWidth, videoHeight, fps, (videoBps + audioBps) / 1024];
        self.labelFrame.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %zd / Frame ratio: %zd / %zd", @"Used for display channel information"), onlineNm, incompleteFrameCount, frameCount];
#else
        
        if (onlineNm >= 5) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CAM P" message:NSLocalizedString(@"Exceed multiple viewer limitation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            
            [camera stopShow:selectedChannel];
            [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
            [camera stopSoundToDevice:selectedChannel];
            [camera stopSoundToPhone:selectedChannel];
            
            monitorPortrait.image = nil;
            monitorLandscape.image = nil;
            
            self.labelVideo.text = [NSString stringWithFormat:@"%dx%d @ %d fps", videoWidth, videoHeight, 0];
            self.labelFrame.text = [NSString stringWithFormat:@"x%zd", onlineNm];
        }
        else {
            self.labelVideo.text = [NSString stringWithFormat:@"%zdx%zd @ %zd fps", videoWidth, videoHeight, fps];
            self.labelFrame.text = [NSString stringWithFormat:@"x%zd", onlineNm];
        }
#endif
        self.labelQuality.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Quality", @""), [_camera getOverAllQualityString]];
        self.labelQuality.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
    }
}

- (void)recalcMonitorRect:(CGSize)videoframe
{
    CGFloat fRatioFrame = videoframe.width / videoframe.height;
    CGFloat fRatioMonitor;
    UIScrollView* viewMonitor;
    UIView* viewCanvas;
    if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
       self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        viewMonitor = self.videoBgScrollView2;
        viewCanvas = _monitorLandscape;
    }
    else {
        viewMonitor = self.videoBgScrollView;
        viewCanvas = _monitorPortrait;
    }
    
    fRatioMonitor = viewMonitor.frame.size.width/viewMonitor.frame.size.height;
    if( fRatioMonitor < fRatioFrame ) {
        CGFloat canvas_height = (viewMonitor.frame.size.width * viewMonitor.zoomScale) / fRatioFrame;
        
        if( canvas_height < viewMonitor.frame.size.height ) {
            viewCanvas.frame = CGRectMake(0, ((viewMonitor.frame.size.height) - canvas_height)/2.0, (viewMonitor.frame.size.width * viewMonitor.zoomScale), canvas_height);
        }
        else {
            viewCanvas.frame = CGRectMake(0, 0, (viewMonitor.frame.size.width * viewMonitor.zoomScale), canvas_height);
        }
    }
    else {
        CGFloat canvas_width = (viewMonitor.frame.size.height * viewMonitor.zoomScale) * fRatioFrame;
        
        if( canvas_width < viewMonitor.frame.size.width ) {
            viewCanvas.frame = CGRectMake(((viewMonitor.frame.size.width) - canvas_width)/2.0, 0, canvas_width, (viewMonitor.frame.size.height * viewMonitor.zoomScale));
        }
        else {
            viewCanvas.frame = CGRectMake(0, 0, canvas_width, (viewMonitor.frame.size.height * viewMonitor.zoomScale));
        }
    }
    
    
    if( self.glView ) {
        self.glView.frame = viewCanvas.frame;

        //self.glView.frame = self.monitorPortrait.frame;
    }
    
    // begin add by kongyulu at 2013-10-29
    CGRect rect = self.glView.frame;
    
    /*
    if ([HComFun isRunningOniPhone5]) //iphone5,iphone5s,iphone5c
    {
        if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
           self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            //横屏
            //self.glView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        }
        else {
            //竖屏
            
            self.glView.frame = CGRectMake(rect.origin.x, rect.origin.y - 50, rect.size.width, rect.size.height + 100);
        }
        
    }
    else if ([HComFun isRunningOniPhone])//iphone4, iphone4s,
    {
        if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
           self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            //横屏
            //self.glView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        }
        else {
            //竖屏
            self.glView.frame = CGRectMake(rect.origin.x, rect.origin.y - 25, rect.size.width, rect.size.height + 60);
        }
        
    }
    else // ipad
    {
        if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
           self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            //横屏
            //self.glView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        }
        else {
            //竖屏
            self.glView.frame = CGRectMake(rect.origin.x, rect.origin.y - 10, rect.size.width, rect.size.height + 20);
        }
    }
     */
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad)
    {
        if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
           self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            //横屏
            //self.glView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        }
        else {
            //竖屏
            self.glView.frame = CGRectMake(rect.origin.x, rect.origin.y - 10, rect.size.width, rect.size.height + 20);
        }
    }
}

// If you want to set the final frame size, just implement this delegation to given the wish frame size
//
- (void)glFrameSize:(NSArray*)param
{
    CGSize* pglFrameSize_Original = (CGSize*)[(NSValue*)[param objectAtIndex:0] pointerValue];
    CGSize* pglFrameSize_Scaling = (CGSize*)[(NSValue*)[param objectAtIndex:1] pointerValue];
    [self recalcMonitorRect:*pglFrameSize_Original];
    self.glView.maxZoom = CGSizeMake( (pglFrameSize_Original->width*2.0 > 1280)?1280:pglFrameSize_Original->width*2.0, (pglFrameSize_Original->height*2.0 > 720)?720:pglFrameSize_Original->height*2.0 );
    *pglFrameSize_Scaling = self.glView.frame.size;
    if (self.glView.frame.size.width > 640) {
        CGSize size = CGSizeMake(640,320);
        *pglFrameSize_Scaling = size;
    }
}

#pragma mark - 旋转
- (void)changeOrientation:(UIInterfaceOrientation)orientation {
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        [_monitorPortrait deattachCamera];
        [_monitorLandscape attachCamera:_camera];
        [self.glView removeFromSuperview];
        self.view = self.viewLandscape;
        NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorLandscape.frame.origin.x, (int)self.monitorLandscape.frame.origin.y, (int)self.monitorLandscape.frame.size.width, (int)self.monitorLandscape.frame.size.height);
        if( self.glView) {
            [self.glView destroyFramebuffer];
            self.glView.frame = self.monitorLandscape.frame;
        }
        [self.videoBgScrollView2 addSubview:self.glView];
        self.videoBgScrollView2.zoomScale = 1.0;
        
        if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
            [self.videoBgScrollView2 bringSubviewToFront:_monitorLandscape/*self.glView*/];
        }
        else {
            [self.videoBgScrollView2 bringSubviewToFront:/*monitorLandscape*/self.glView];
        }
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    else {
        [_monitorLandscape deattachCamera];
        [_monitorPortrait attachCamera:_camera];
        [self.glView removeFromSuperview];
        self.view = self.viewPortrait;
        NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorPortrait.frame.origin.x, (int)self.monitorPortrait.frame.origin.y, (int)self.monitorPortrait.frame.size.width, (int)self.monitorPortrait.frame.size.height);
        if( self.glView) {
            [self.glView destroyFramebuffer];
            self.glView.frame = self.monitorPortrait.frame;
        }
        [self.videoBgScrollView addSubview:self.glView];
        self.videoBgScrollView.zoomScale = 1.0;
        if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
            [self.videoBgScrollView bringSubviewToFront:_monitorPortrait/*self.glView*/];
        }
        else {
            [self.videoBgScrollView bringSubviewToFront:/*monitorPortrait*/self.glView];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    [self changeOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}



@end
