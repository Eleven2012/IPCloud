//
//  YLEnvironmentModeController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/20.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLEnvironmentModeController.h"

@interface YLEnvironmentModeController ()<MyCameraDelegate>
@property (nonatomic, strong) NSArray *listData;

@end

@implementation YLEnvironmentModeController

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
    self.newValue = -1;
    self.camera.delegate2 = self;

}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Environment Mode", @"")];
    self.navigationItem.title = title;
    
}

-(void) btnBarLeftButtonClicked:(id)sender
{
    if (_newValue != -1 && _origValue != _newValue) {
        
        SMsgAVIoctrlSetEnvironmentReq *s = malloc(sizeof(SMsgAVIoctrlSetEnvironmentReq));
        memset(s, 0, sizeof(SMsgAVIoctrlSetEnvironmentReq));
        
        s->channel = 0;
        s->mode = _newValue;
        
        [_camera sendIOCtrlToChannel:0
                               Type:IOTYPE_USER_IPCAM_SET_ENVIRONMENT_REQ
                               Data:(char *)s
                           DataSize:sizeof(SMsgAVIoctrlSetEnvironmentReq)];
        
        free(s);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(YLEnvironmentModeControllerDelegate_didSetEnvironmentMode:)])
        {
            [_delegate YLEnvironmentModeControllerDelegate_didSetEnvironmentMode:_newValue];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSArray *) listData
{
    if(_listData == nil)
    {
        _listData = @[NSLocalizedString(@"Indoor Mode(50Hz)", @""),
                      NSLocalizedString(@"Indoor Mode(60Hz)", @""),
                      NSLocalizedString(@"Outdoor Mode", @""),
                      NSLocalizedString(@"Night Mode", @"")
                      ];
    }
    return _listData;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CheckMarkCellIdentifier = @"CheckMarkCellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CheckMarkCellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckMarkCellIdentifier];
    }
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [self.listData objectAtIndex:row];
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
    
    if (camera_ == _camera && type == IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP) {
        
        SMsgAVIoctrlGetEnvironmentResp *s = (SMsgAVIoctrlGetEnvironmentResp*)data;
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
