//
//  YLSDCardVideoController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/21.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLSDCardVideoController.h"
#import "YLOpenGLView.h"

@interface YLSDCardVideoController ()<MyCameraDelegate, MonitorTouchDelegate,UIScrollViewDelegate>
{
    NSInteger playbackChannelIndex;
    bool isPaused;
    bool isOpened;
    BOOL bStopShowCompletedLock;
    unsigned short mCodecId;
}
@property (weak, nonatomic) IBOutlet UIToolbar *toolBarControl;
@property (weak, nonatomic) IBOutlet UILabel *labelStauts;
@property (weak, nonatomic) IBOutlet UILabel *labelVideo;
@property (weak, nonatomic) IBOutlet UILabel *labelFrame;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewBg;
@property (weak, nonatomic) IBOutlet Monitor *monitorPortrait;
@property (weak, nonatomic) IBOutlet Monitor *monitorLandscape;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewBgL;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityL;
@property (weak, nonatomic) IBOutlet UIButton *btnStartL;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewConnectMode;
@property (nonatomic, strong) YLOpenGLView *glView;
@property (strong, nonatomic) NSTimer *tmrRecvPlayback;
@property (strong, nonatomic) IBOutlet UIView *viewPortrait;
@property (strong, nonatomic) IBOutlet UIView *viewLandscape;

@end

@implementation YLSDCardVideoController

-(void) dealloc
{
    [self registerNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (_camera != nil)
        _camera.delegate2 = self;
    
    [self play:nil];
    NSString *evtName;
    NSString *evtTime;
    evtName = [Event getEventTypeName:self.event.eventType];
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.event.eventTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    evtTime = [dateFormatter stringFromDate:date];
    self.labelStauts.text = [NSString stringWithFormat:@"%@ (%@) ", evtName, evtTime];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.tmrRecvPlayback invalidate];
    [super viewWillDisappear:animated];
}


-(void) initData
{
    [super initData];
    [self registerNotifications];
    
}

-(void) initBarButton
{
    [super initBarButton];
    playbackChannelIndex = -1;
    
#ifndef MacGulp
    self.navigationItem.title = NSLocalizedString(@"Playback", nil);
    self.navigationItem.prompt = _camera.name;
#else
    NSString *evtTime;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.event.eventTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    evtTime = [dateFormatter stringFromDate:date];
    self.navigationItem.title = [NSString stringWithFormat:@"%@", evtTime];
#endif
    
    self.labelVideo.text = nil;
    self.labelFrame.text = nil;
    self.labelStauts.text = nil;
    
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
    
    self.scrollViewBg.minimumZoomScale = ZOOM_MIN_SCALE;
    self.scrollViewBg.maximumZoomScale = ZOOM_MAX_SCALE;
    self.scrollViewBg.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollViewBg.contentSize = self.scrollViewBg.frame.size;
    self.scrollViewBg.delegate = self;
    
    self.scrollViewBgL.minimumZoomScale = ZOOM_MIN_SCALE;
    self.scrollViewBgL.maximumZoomScale = ZOOM_MAX_SCALE;
    self.scrollViewBgL.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollViewBgL.contentSize = self.scrollViewBgL.frame.size;
    self.scrollViewBgL.delegate = self;
    
    
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
}

-(void) registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cameraStopShowCompleted:) name: @"CameraStopShowCompleted" object: nil];
    
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
    [self removeObserver:self forKeyPath:@"CameraStopShowCompleted"];
    [self removeObserver:self forKeyPath:UIApplicationWillResignActiveNotification];
    [self removeObserver:self forKeyPath:UIApplicationDidBecomeActiveNotification];
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


- (IBAction)btnStartClicked:(id)sender {
}
#pragma mark - actions
- (void)showPlaybackNotFoundMsg {
    
    if (playbackChannelIndex < 0) {
        
        isOpened = false;
        //[self showPlayButton];
        [self showTips2:NSLocalizedString(@"Can not play remote record", @"")];
    }
    self.tmrRecvPlayback = nil;
}

-(void) closeVideo
{
    [_monitorLandscape deattachCamera];
    [_monitorPortrait deattachCamera];
    
    if (playbackChannelIndex > 0) {
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_STOP;
        req->stTimeDay = [Event getTimeDay:_event.eventTime];
        req->Param = 0;
        [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        free(req);
        [_camera stopSoundToPhone:playbackChannelIndex];
        [_camera stopShow:playbackChannelIndex];
        [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
        [_camera stop:playbackChannelIndex];
        
    }
    
    [_camera clearRemoteNotifications];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)play:(id)sender {
    
    if (playbackChannelIndex < 0) {
        isOpened = true;
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_START;
        req->stTimeDay = [Event getTimeDay:_event.eventTime];
        req->Param = 0;
        [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        free(req);
        //[self showPauseButton];
        if (_tmrRecvPlayback != nil) {
            [self.tmrRecvPlayback invalidate];
            self.tmrRecvPlayback = nil;
        }
        self.tmrRecvPlayback = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showPlaybackNotFoundMsg) userInfo:nil repeats:nil];
    }
    else {
        [self pause:nil];
    }
}

- (void)pause:(id)sender {
    
    if (playbackChannelIndex >= 0) {
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_PAUSE;
        req->stTimeDay = [Event getTimeDay:_event.eventTime];
        req->Param = 0;
        [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        free(req);
    }
    isPaused = !isPaused;
//    if (isPaused)
//        [self showPlayButton];
//    else
//        [self showPauseButton];
}


- (void)verifyConnectionStatus
{
    if (_camera.sessionState == CONNECTION_STATE_CONNECTING) {
        self.labelStauts.text = NSLocalizedString(@"Connecting...", @"");
        NSLog(@"%@ connecting", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
        self.labelStauts.text = NSLocalizedString(@"Off line", @"");
        NSLog(@"%@ off line", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {
        self.labelStauts.text = NSLocalizedString(@"Unknown Device", @"");
        NSLog(@"%@ unknown device", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_TIMEOUT) {
        self.labelStauts.text = NSLocalizedString(@"Timeout", @"");
        NSLog(@"%@ timeout", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {
        self.labelStauts.text = NSLocalizedString(@"Unsupported", @"");
        NSLog(@"%@ unsupported", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
        self.labelStauts.text = NSLocalizedString(@"Connect Failed", @"");
        NSLog(@"%@ connected failed", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
        
#ifndef SHOW_SESSION_MODE
        self.labelStauts.text = NSLocalizedString(@"Online", @"");
#else
        if (_camera.sessionMode == CONNECTION_MODE_P2P) {
            self.imgViewConnectMode.image = [UIImage imageNamed:@"ConnectMode_P2P"];
            self.labelStauts.text = [NSString stringWithFormat:@"%@ / P2P", NSLocalizedString(@"Online", @"")];
        }
        else if (_camera.sessionMode == CONNECTION_MODE_RELAY) {
            self.imgViewConnectMode.image = [UIImage imageNamed:@"ConnectMode_RLY"];
            self.labelStauts.text = [NSString stringWithFormat:@"%@ / Relay", NSLocalizedString(@"Online", @"")];
        }
        else if (_camera.sessionMode == CONNECTION_MODE_LAN) {
            self.imgViewConnectMode.image = [UIImage imageNamed:@"ConnectMode_LAN"];
            self.labelStauts.text = [NSString stringWithFormat:@"%@ / %@", NSLocalizedString(@"Online", @""), NSLocalizedString(@"LAN", @"")];
        }
        else {
            self.labelStauts.text = NSLocalizedString(@"Online", @"");
        }
#endif
        
        NSLog(@"%@ online", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
        self.labelStauts.text = NSLocalizedString(@"Connecting...", @"");
        NSLog(@"%@ connecting", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED) {
        self.labelStauts.text = NSLocalizedString(@"Off line", @"");
        NSLog(@"%@ off line", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
        self.labelStauts.text = NSLocalizedString(@"Unknown Device", @"");
        NSLog(@"%@ unknown device", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
        self.labelStauts.text = NSLocalizedString(@"Wrong Password", @"");
        NSLog(@"%@ wrong password", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
        self.labelStauts.text = NSLocalizedString(@"Timeout", @"");
        NSLog(@"%@ timeout", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
        self.labelStauts.text = NSLocalizedString(@"Unsupported", @"");
        NSLog(@"%@ unsupported", _camera.uid);
    }
    else if (_camera.sessionState == CONNECTION_STATE_CONNECTED && [_camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
        self.labelStauts.text = NSLocalizedString(@"Connecting...", @"");
        NSLog(@"%@ wait for connecting", _camera.uid);
    }
 }

- (void)waitStopShowCompleted:(unsigned int)uTimeOutInMs
{
    unsigned int uStart = (unsigned int)[YLComFun getTickTime];
    while(bStopShowCompletedLock == FALSE ) {
        usleep(1000);
        unsigned int now = (unsigned int)[YLComFun getTickTime];
        if( now - uStart >= uTimeOutInMs ) {
            NSLog( @"CameraPlaybackController - waitStopShowCompleted !!!TIMEOUT!!!" );
            break;
        }
    }
}

- (void)cameraStopShowCompleted:(NSNotification *)notification
{
    bStopShowCompletedLock = TRUE;
}

- (void)glFrameSize:(NSArray*)param
{
    CGSize* pglFrameSize_Original = (CGSize*)[(NSValue*)[param objectAtIndex:0] pointerValue];
    CGSize* pglFrameSize_Scaling = (CGSize*)[(NSValue*)[param objectAtIndex:1] pointerValue];
    [self recalcMonitorRect:*pglFrameSize_Original];
    self.glView.maxZoom = CGSizeMake( (pglFrameSize_Original->width*2.0 > 1280)?1280:pglFrameSize_Original->width*2.0, (pglFrameSize_Original->height*2.0 > 720)?720:pglFrameSize_Original->height*2.0 );
    *pglFrameSize_Scaling = self.glView.frame.size;
}

- (void)reportCodecId:(NSValue*)pointer
{
    unsigned short *pnCodecId = (unsigned short *)[pointer pointerValue];
    mCodecId = *pnCodecId;
    if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            [self.scrollViewBgL bringSubviewToFront:_monitorLandscape/*self.glView*/];
        }
        else {
            [self.scrollViewBgL bringSubviewToFront:_monitorLandscape/*self.glView*/];
        }
    }
    else {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            [self.scrollViewBg bringSubviewToFront:/*monitorLandscape*/self.glView];
        }
        else {
            [self.scrollViewBg bringSubviewToFront:/*monitorLandscape*/self.glView];
        }		
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
        viewMonitor = self.scrollViewBgL;
        viewCanvas = self.monitorLandscape;
    }
    else {
        viewMonitor = self.scrollViewBg;
        viewCanvas = self.monitorPortrait;
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
    }
}

#pragma mark - UIApplication Delegate
- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (playbackChannelIndex >= 0) {
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_PAUSE;
        req->stTimeDay = [Event getTimeDay:_event.eventTime];
        req->Param = 0;
        [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        free(req);
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (playbackChannelIndex >= 0) {
        SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
        memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
        req->channel = 0;
        req->command = AVIOCTRL_RECORD_PLAY_PAUSE;
        req->stTimeDay = [Event getTimeDay:_event.eventTime];
        req->Param = 0;
        [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
        free(req);
    }
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        return self.monitorPortrait;
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
             self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return self.monitorLandscape;
    }
    else return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(CGFloat)scale {
    if( self.glView ) {
        self.glView.frame = CGRectMake( 0, 0, scrollView.frame.size.width*scale, scrollView.frame.size.height*scale );
        NSLog( @"{0,0,%d,%d}", (int)(scrollView.frame.size.width*scale), (int)(scrollView.frame.size.height*scale) );
    }
}

#pragma mark - MonitorTouchDelegate Methods
- (void)monitor:(Monitor *)monitor gestureSwiped:(Direction)direction {
    NSLog( @"Ignore PTZ in Playback mode." );
}

- (void)gestureSwiped:(Direction)direction {
    
}

- (void)gesturePinched:(CGFloat)scale {
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
        NSLog( @"CameraPlaybackController - Pinched [Landscape] scale:%f/%f", scale, self.scrollViewBgL.maximumZoomScale );
        if( scale <= self.scrollViewBgL.maximumZoomScale )
            [self.scrollViewBgL setZoomScale:scale animated:YES];
    }
    else {
        NSLog( @"CameraPlaybackController - Pinched scale:%f/%f", scale, self.scrollViewBg.maximumZoomScale );
        if( scale <= self.scrollViewBg.maximumZoomScale )
            [self.scrollViewBg setZoomScale:scale animated:YES];
    }
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size
{
    if (camera_ == _camera && type == IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL_RESP) {
        
        SMsgAVIoctrlPlayRecordResp *resp = (SMsgAVIoctrlPlayRecordResp *) data;
        switch (resp->command) {
            case AVIOCTRL_RECORD_PLAY_START:
            {
                if (isOpened) {
                    if (resp->result > 0 && resp->result <= 32) {
                        playbackChannelIndex = resp->result;
                        [_camera start4EventPlayback:playbackChannelIndex];
                        [_camera startShow:playbackChannelIndex ];
                        [_camera startSoundToPhone:playbackChannelIndex];
                        
                        isPaused = false;
                    }
                }
                
                break;
            }
            case AVIOCTRL_RECORD_PLAY_PAUSE:
            {
                
                break;
            }
            case AVIOCTRL_RECORD_PLAY_STOP:
            {
                [_camera stopSoundToPhone:playbackChannelIndex];
                [_camera stopShow:playbackChannelIndex];
                [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                [_camera stop:playbackChannelIndex];
                isPaused = false;
                
                //[self showPlayButton];
                playbackChannelIndex = -1;
                break;
            }
                
            case AVIOCTRL_RECORD_PLAY_END:
            {
                [_camera stopSoundToPhone:playbackChannelIndex];
                [_camera stopShow:playbackChannelIndex];
                [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
                [_camera stop:playbackChannelIndex];
                
                SMsgAVIoctrlPlayRecord *req = (SMsgAVIoctrlPlayRecord *) malloc(sizeof(SMsgAVIoctrlPlayRecord));
                memset(req, 0, sizeof(SMsgAVIoctrlPlayRecord));
                req->channel = 0;
                req->command = AVIOCTRL_RECORD_PLAY_STOP;
                req->stTimeDay = [Event getTimeDay:_event.eventTime];
                req->Param = 0;
                [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_RECORD_PLAYCONTROL Data:(char *)req DataSize:sizeof(SMsgAVIoctrlPlayRecord)];
                free(req);
                isPaused = false;
                isOpened = false;
                playbackChannelIndex = -1;
                
                //[self showPlayButton];
                [self showTips2:NSLocalizedString(@"The video has finished playing", @"")];
                if (_tmrRecvPlayback != nil) {
                    [self.tmrRecvPlayback invalidate];
                    self.tmrRecvPlayback = nil;
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)camera:(MyCamera *)camera_ _didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned long)frameCount IncompleteFrameCount:(unsigned long)incompleteFrameCount {
    
    if (camera_ == _camera) {
        if( videoWidth > 1280 || videoHeight > 720 ) {
            NSLog( @"!!!!!!!! ERROR !!!!!!!!" );
            return;
        }
        CGSize maxZoom = CGSizeMake((videoWidth*2.0 > 1280)?1280:videoWidth*2.0, (videoHeight*2.0 > 720)?720:videoHeight*2.0);
        if( self.glView && videoWidth > 0 && videoHeight > 0 ) {
            [self recalcMonitorRect:CGSizeMake(videoWidth, videoHeight)];
            self.glView.maxZoom = maxZoom;
        }
        if( maxZoom.width / self.scrollViewBg.frame.size.width > 1.0 ) {
            self.scrollViewBg.maximumZoomScale = maxZoom.width / self.scrollViewBg.frame.size.width;
        }
        else {
            self.scrollViewBg.maximumZoomScale = 1;
        }
        if( maxZoom.width / self.scrollViewBgL.frame.size.width > 1.0 ) {
            self.scrollViewBgL.maximumZoomScale = maxZoom.width / self.scrollViewBgL.frame.size.width;
        }
        else {
            self.scrollViewBgL.maximumZoomScale = 1;
        }
        
        if( g_bDiagnostic ) {
            self.labelVideo.text = [NSString stringWithFormat:@"%zdx%zd / FPS: %zd / BPS: %zd Kbps", videoWidth, videoHeight, fps, (videoBps + audioBps) / 1024];
            self.labelFrame.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %zd / Frame ratio: %zd / %zd", @"Used for display channel information"), onlineNm, incompleteFrameCount, frameCount];
        }
        else {
            self.labelVideo.text = [NSString stringWithFormat:@"%zdx%zd", videoWidth, videoHeight ];
            self.labelFrame.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %zd", @""), onlineNm];
        }
    }
}

#pragma mark - 屏幕旋转
- (void)changeOrientation:(UIInterfaceOrientation)orientation {
    
    NSLog(@"change orientation");
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
        [self.scrollViewBgL addSubview:self.glView];
        self.scrollViewBgL.zoomScale = 1.0;
        
        if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
            [self.scrollViewBgL bringSubviewToFront:_monitorLandscape/*self.glView*/];
        }
        else {
            [self.scrollViewBgL bringSubviewToFront:/*monitorLandscape*/self.glView];
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
        [self.scrollViewBg addSubview:self.glView];
        self.scrollViewBg.zoomScale = 1.0;
        if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
            [self.scrollViewBg bringSubviewToFront:_monitorPortrait/*self.glView*/];
        }
        else {
            [self.scrollViewBg bringSubviewToFront:/*monitorPortrait*/self.glView];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self changeOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}


@end
