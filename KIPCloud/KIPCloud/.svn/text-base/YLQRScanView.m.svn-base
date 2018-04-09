//
//  YLQRScanView.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/7.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLQRScanView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+SDExtension.h"

static const CGFloat kBorderW = 100;
static const CGFloat kMargin = 30;

@interface YLQRScanView( )<AVCaptureMetadataOutputObjectsDelegate>
{
    
}
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak)   UIView *maskView;
@property (nonatomic, strong) UIView *scanWindow;
@property (nonatomic, strong) UIImageView *scanNetImageView;
@property (nonatomic, strong) UIView *bottomBar;

@property (nonatomic, strong) UIButton *topLeft;
@property (nonatomic, strong) UIButton *topRight;
@property (nonatomic, strong) UIButton *bottomLeft;
@property (nonatomic, strong) UIButton *bottomRight;
@property (nonatomic, strong) UIButton *albumBtn;
@property (nonatomic, strong) UIButton *flashBtn;
@end

@implementation YLQRScanView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        //这个属性必须打开否则返回的时候会出现黑边
        self.clipsToBounds=YES;
        //1.遮罩
        [self setupMaskView];
        //2.下边栏
        [self setupBottomBar];

        //5.扫描区域
        [self setupScanWindowView];
        //6.开始动画
        [self beginScanning];
        
        [self setupNavView];
        
    }
    
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    _maskView.bounds = CGRectMake(0, 0, self.sd_width + kBorderW + kMargin , self.sd_width + kBorderW + kMargin);
    _maskView.center = CGPointMake(self.sd_width * 0.5, self.sd_height * 0.5);
    _maskView.sd_y = 0;
    CGFloat scanWindowH = self.sd_width - kMargin * 2;
    CGFloat scanWindowW = self.sd_width - kMargin * 2;
    _scanWindow.frame = CGRectMake(kMargin, kBorderW, scanWindowW, scanWindowH);
    
    CGFloat buttonWH = 18;
    _topLeft.frame = CGRectMake(0, 0, buttonWH, buttonWH);
     _topRight.frame = CGRectMake(scanWindowW - buttonWH, 0, buttonWH, buttonWH);
     _bottomLeft.frame = CGRectMake(0, scanWindowH - buttonWH, buttonWH, buttonWH);
     _bottomRight.frame = CGRectMake(_topRight.sd_x, _bottomLeft.sd_y, buttonWH, buttonWH);
    
}

-(void)setupNavView{
    

    //2.相册
    self.albumBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _albumBtn.frame = CGRectMake(0, 0, 35, 35);
    _albumBtn.center=CGPointMake(self.sd_width/2, 20+49/2.0);
    [_albumBtn setBackgroundImage:[UIImage imageNamed:@"qr_from_pic"] forState:UIControlStateNormal];
    _albumBtn.contentMode=UIViewContentModeScaleAspectFit;
    [_albumBtn addTarget:self action:@selector(myAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_albumBtn];
    
    //3.闪光灯
    self.flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _flashBtn.frame = CGRectMake(self.sd_width-55,25, 35, 35);
    [_flashBtn setBackgroundImage:[UIImage imageNamed:@"flashlight"] forState:UIControlStateNormal];
    _flashBtn.contentMode=UIViewContentModeScaleAspectFit;
    [_flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flashBtn];
    
    
}


- (void)setupMaskView
{
    UIView *mask = [[UIView alloc] init];
    _maskView = mask;
    mask.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
    mask.layer.borderWidth = kBorderW;
    mask.bounds = CGRectMake(0, 0, self.sd_width + kBorderW + kMargin , self.sd_width + kBorderW + kMargin);
    mask.center = CGPointMake(self.sd_width * 0.5, self.sd_height * 0.5);
    mask.sd_y = 0;
    [self addSubview:mask];
}

- (void)setupBottomBar
{
    //1.下边栏
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.sd_height * 0.9, self.sd_width, self.sd_height * 0.1)];
    _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self addSubview:_bottomBar];
}
- (void)setupScanWindowView
{
    CGFloat scanWindowH = self.sd_width - kMargin * 2;
    CGFloat scanWindowW = self.sd_width - kMargin * 2;
    _scanWindow = [[UIView alloc] initWithFrame:CGRectMake(kMargin, kBorderW, scanWindowW, scanWindowH)];
    _scanWindow.clipsToBounds = YES;
    [self addSubview:_scanWindow];
    
    _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
    CGFloat buttonWH = 18;
    
    self.topLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWH, buttonWH)];
    [_topLeft setImage:[UIImage imageNamed:@"scan_1"] forState:UIControlStateNormal];
    [_scanWindow addSubview:_topLeft];
    
    self.topRight = [[UIButton alloc] initWithFrame:CGRectMake(scanWindowW - buttonWH, 0, buttonWH, buttonWH)];
    [_topRight setImage:[UIImage imageNamed:@"scan_2"] forState:UIControlStateNormal];
    [_scanWindow addSubview:_topRight];
    
    self.bottomLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, scanWindowH - buttonWH, buttonWH, buttonWH)];
    [_bottomLeft setImage:[UIImage imageNamed:@"scan_3"] forState:UIControlStateNormal];
    [_scanWindow addSubview:_bottomLeft];
    
    self.bottomRight = [[UIButton alloc] initWithFrame:CGRectMake(_topRight.sd_x, _bottomLeft.sd_y, buttonWH, buttonWH)];
    [_bottomRight setImage:[UIImage imageNamed:@"scan_4"] forState:UIControlStateNormal];
    [_scanWindow addSubview:_bottomRight];
}

- (void)beginScanning
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域
    CGRect scanCrop=[self getScanCrop:_scanWindow.bounds readerViewBounds:self.frame];
    output.rectOfInterest = scanCrop;
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.layer.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [_session startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        NSString *strResult = metadataObject.stringValue;
        DebugLog(@"扫描到字符串:%@",strResult);
        if(_delegate && [_delegate respondsToSelector:@selector(YLQRScanView_scanSucceed:)])
        {
            [_delegate YLQRScanView_scanSucceed:strResult];
        }
    }
}

#pragma mark-> 闪光灯
-(void)openFlash:(UIButton*)button{
    
    NSLog(@"闪光灯");
    button.selected = !button.selected;
    if (button.selected) {
        [self turnTorchOn:YES];
        [button setBackgroundImage:[UIImage imageNamed:@"flashlight_closed"] forState:UIControlStateNormal];
    }
    else{
        [self turnTorchOn:NO];
        [button setBackgroundImage:[UIImage imageNamed:@"flashlight"] forState:UIControlStateNormal];
    }
    
}


#pragma mark-> 开关闪光灯
- (void)turnTorchOn:(BOOL)on
{
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark-> 我的相册
-(void)myAlbum{
    
    NSLog(@"我的相册");
}

#pragma mark 恢复动画
- (void)resumeAnimation
{
    CAAnimation *anim = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    if(anim){
        // 1. 将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = _scanNetImageView.layer.timeOffset;
        // 2. 根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        
        // 3. 要把偏移时间清零
        [_scanNetImageView.layer setTimeOffset:0.0];
        // 4. 设置图层的开始动画时间
        [_scanNetImageView.layer setBeginTime:beginTime];
        
        [_scanNetImageView.layer setSpeed:1.0];
        
    }else{
        
        CGFloat scanNetImageViewH = 241;
        CGFloat scanWindowH = self.sd_width - kMargin * 2;
        CGFloat scanNetImageViewW = _scanWindow.sd_width;
        
        _scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(scanWindowH);
        scanNetAnimation.duration = 1.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [_scanWindow addSubview:_scanNetImageView];
    }
    
    
    
}
#pragma mark-> 获取扫描区域的比例关系
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
