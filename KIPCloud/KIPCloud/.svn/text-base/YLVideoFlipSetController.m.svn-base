//
//  YLVideoFlipSetController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLVideoFlipSetController.h"

@interface YLVideoFlipSetController ()<MyCameraDelegate>

@property (nonatomic, strong) NSArray *labelItems;
@end

@implementation YLVideoFlipSetController

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
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Video Flip", @"")];
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
        [self showTips2:NSLocalizedString(@"Set video flip successfully!", @"")];
        if(_delegate && [_delegate respondsToSelector:@selector(YLVideoFlipSetControllerDelegate_didSetFinished:)])
        {
            [_delegate YLVideoFlipSetControllerDelegate_didSetFinished:_newValue];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self showTips2:NSLocalizedString(@"Set video flip failed!", @"")];
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
        _labelItems = @[NSLocalizedString(@"Normal", @""),
                        NSLocalizedString(@"Vertical Flip", @""),
                        NSLocalizedString(@"Horizontal Flip (Mirror)", @""),
                        NSLocalizedString(@"Vertical and Horizontal Flip", @"")];
    }
    return _labelItems;
}

-(BOOL) saveData
{
    if (_newValue != -1 && _origValue != _newValue) {
        SMsgAVIoctrlSetMotionDetectReq *structSetMotionDetection = malloc(sizeof(SMsgAVIoctrlSetMotionDetectReq));
        memset(structSetMotionDetection, 0, sizeof(SMsgAVIoctrlSetMotionDetectReq));
        structSetMotionDetection->channel = 0;
        structSetMotionDetection->sensitivity = (int)_newValue;
        [_camera sendIOCtrlToChannel:0
                                Type:IOTYPE_USER_IPCAM_SETMOTIONDETECT_REQ
                                Data:(char *)structSetMotionDetection
                            DataSize:sizeof(SMsgAVIoctrlSetMotionDetectReq)];
        free(structSetMotionDetection);
        return YES;
    }
    return NO;
}

#pragma mark - Table view data source

#pragma mark - Table DataSource Methods
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
    cell.accessoryType = (row == self.origValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.newValue = [indexPath row];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MyCameraDelegate Delegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == _camera && type == IOTYPE_USER_IPCAM_GET_VIDEOMODE_RESP) {
        
        SMsgAVIoctrlGetVideoModeResp *s = (SMsgAVIoctrlGetVideoModeResp*)data;
        self.origValue = s->mode;
        
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
