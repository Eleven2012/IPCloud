//
//  YLDeviceInfoController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLDeviceInfoController.h"
#import "YLCommonActivityCell.h"

@interface YLDeviceInfoController ()<MyCameraDelegate>
@property (nonatomic, strong) NSArray *labelItems;
@property (nonatomic, copy) NSString *model;
@property (nonatomic,assign) NSInteger version;
@property (nonatomic, copy) NSString *vender;
@property (nonatomic,assign) NSInteger totalSize;
@property (nonatomic,assign) NSInteger freeSize;
@end

@implementation YLDeviceInfoController
-(void) dealloc
{
    _camera.delegate2 = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _camera.delegate2 = self;
    [self getDeviceInfo];
    
}

-(void) initData
{
    [super initData];
    self.model = nil;
    self.version = -1;
    self.vender = nil;
    self.totalSize = -1;
    self.freeSize = -1;
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Device Information", @"")];
    self.navigationItem.title = title;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *) labelItems
{
    if(_labelItems == nil)
    {
        _labelItems = @[NSLocalizedString(@"Model", @""),
                        NSLocalizedString(@"Version", @""),
                        NSLocalizedString(@"Vender", @""),
                        NSLocalizedString(@"Total Size", @""),
                        NSLocalizedString(@"Free Size", @"")
                        ];
    }
    return _labelItems;
}

-(void) getDeviceInfo
{
    SMsgAVIoctrlDeviceInfoReq *s = malloc(sizeof(SMsgAVIoctrlDeviceInfoReq));
    memset(s, 0, sizeof(SMsgAVIoctrlDeviceInfoReq));
    
    [_camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_DEVINFO_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlDeviceInfoReq)];
    free(s);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.labelItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier1 = @"YLCommonActivityCell";
    
    UITableViewCell *cell = nil;
    NSInteger row = indexPath.row;
    //NSInteger section = indexPath.section;
    cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YLCommonActivityCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *strTitle = [self.labelItems objectAtIndex:row];
    YLCommonActivityCell *cell0 = (YLCommonActivityCell *)cell;
    cell0.labelTitle.text = strTitle;
    NSString *strDetail = nil;
    BOOL bAnimation = NO;
    if(row == 0)
    {
        strDetail = _model;
        bAnimation = (_model == nil || [_model length] == 0) ? YES : NO;
    }
    else if(row == 1)
    {

        bAnimation = (_version <= 0) ? YES : NO;
        unsigned char v[4] = {0};
        
        v[3] = (char)_version;
        v[2] = (char)(_version >> 8);
        v[1] = (char)(_version >> 16);
        v[0] = (char)(_version >> 24);
        strDetail = [NSString stringWithFormat:@"%d.%d.%d.%d", v[0], v[1], v[2], v[3]];
    }
    else if(row == 2)
    {
        strDetail = _vender;
        bAnimation = (_vender == nil || [_vender length] == 0) ? YES : NO;
    }
    else if(row == 3)
    {
        strDetail = (_totalSize >= 0) ? [NSString stringWithFormat:@"%zd MB", _totalSize] : nil;
        bAnimation = (_totalSize >= 0) ? NO : YES;
    }
    else if(row == 4)
    {
        strDetail = (_freeSize >= 0) ? [NSString stringWithFormat:@"%zd MB", _freeSize] : nil;
        bAnimation = (_freeSize >= 0) ? NO : YES;
    }
    cell0.labelDetail.text = strDetail;
    if(bAnimation)
    {
        [cell0.activity startAnimating];
        cell0.activity.hidden = NO;
    }
    else
    {
        [cell0.activity stopAnimating];
        cell0.activity.hidden = YES;
    }
    
    return cell;
}


#pragma mark - CameraDelegate Methods

- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == _camera && type == IOTYPE_USER_IPCAM_DEVINFO_RESP) {
        
        SMsgAVIoctrlDeviceInfoResp *structDevInfo = (SMsgAVIoctrlDeviceInfoResp*)data;
        self.model = [NSString stringWithUTF8String:(char *)structDevInfo->model];
        self.vender = [NSString stringWithUTF8String:(char *)structDevInfo->vendor];
        self.version = structDevInfo->version;
        self.totalSize = structDevInfo->total;
        self.freeSize = structDevInfo->free;
        
        
        
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
