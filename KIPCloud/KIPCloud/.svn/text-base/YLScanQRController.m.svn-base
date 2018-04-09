//
//  YLScanQRController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/7.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLScanQRController.h"
#import "YLQRScanView.h"

@interface YLScanQRController ()<YLQRScanViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *scanImgView;

@end

@implementation YLScanQRController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
}

-(void) initData
{
    [super initData];
}

-(void) initUI
{
    [super initUI];
    CGRect rect = _scanImgView.frame;
    YLQRScanView *qrView = [[YLQRScanView alloc] initWithFrame:rect];
    qrView.delegate = self;
    [self.view addSubview:qrView];
}

//保存按钮点击事件
- (void) btnBarLeftButtonClicked:(id) sender
{
    [super btnBarLeftButtonClicked:sender];
}

//右侧按钮
- (void) btnBarRightButtonClicked:(id) sender
{
    [super btnBarRightButtonClicked:sender];
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma YLQRScanViewDelegate
-(void) YLQRScanView_scanSucceed:(NSString *)str
{
    if(_delegate && [_delegate respondsToSelector:@selector(YLScanQRController_scanSucceed:)])
    {
        [_delegate YLScanQRController_scanSucceed:str];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
