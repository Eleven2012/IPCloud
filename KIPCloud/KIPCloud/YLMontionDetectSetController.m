//
//  YLMontionDetectSetController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLMontionDetectSetController.h"

@interface YLMontionDetectSetController ()<MyCameraDelegate>
@property (nonatomic, strong) NSArray *labelItems;

@end

@implementation YLMontionDetectSetController

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
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Motion Detection", @"")];
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
        [self showTips2:NSLocalizedString(@"Set montion detect successfully!", @"")];
        if(_delegate && [_delegate respondsToSelector:@selector(YLMontionDetectSetControllerDelegate_didSetMontionDetectFinished:)])
        {
            [_delegate YLMontionDetectSetControllerDelegate_didSetMontionDetectFinished:_newValue];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self showTips2:NSLocalizedString(@"Set montion detect failed!", @"")];
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
        _labelItems = @[NSLocalizedString(@"Off", @""),
                        NSLocalizedString(@"Low", @""),
                        NSLocalizedString(@"Medium", @""),
                        NSLocalizedString(@"High", @""),
                        NSLocalizedString(@"Max", @"")];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 5 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    
    static NSString *MotionDetectionTableIdentifier = @"MotionDetectionTableIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MotionDetectionTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MotionDetectionTableIdentifier]
                ;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSInteger val = -1;
    if (_newValue > 0)
        val = _newValue;
    else
        val = _origValue;
    if (val == 0 && row == 0)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 0 && val <= 25 && row == 1)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 25 && val <= 50 && row == 2)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 50 && val <= 75 && row == 3)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val == 100 && row == 4)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.text = [self.labelItems objectAtIndex:row];
    
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSInteger row = [indexPath row];
    
    if (row == 0)
        _newValue = 0;
    else if (row == 1)
        _newValue = 25;
    else if (row == 2)
        _newValue = 50;
    else if (row == 3)
        _newValue = 75;
    else if (row == 4)
        _newValue = 100;
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == _camera && type == IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP) {
        SMsgAVIoctrlGetMotionDetectResp *s = (SMsgAVIoctrlGetMotionDetectResp*)data;
        self.origValue = s->sensitivity;
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
