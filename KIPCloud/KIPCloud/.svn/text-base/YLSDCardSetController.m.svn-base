//
//  YLSDCardSetController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLSDCardSetController.h"

@interface YLSDCardSetController ()<MyCameraDelegate>

@end

@implementation YLSDCardSetController

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
    
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Format SDCard", @"")];
    self.navigationItem.title = title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    
    cell.textLabel.text = NSLocalizedString(@"Format SDCard", @"");
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return NSLocalizedString(@"Format command will ERASE all data of your SDCard", @"");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row == 0) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLocalizedString(@"Format SDCard", @"")
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                      destructiveButtonTitle:NSLocalizedString(@"Continue", @"")
                                      otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
}

#pragma  mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        if (_camera != nil) {
            SMsgAVIoctrlFormatExtStorageReq *s = malloc(sizeof(SMsgAVIoctrlFormatExtStorageReq));
            memset(s, 0, sizeof(SMsgAVIoctrlFormatExtStorageReq));
            s->storage = 0;
            [_camera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_REQ
                                   Data:(char *)s
                               DataSize:sizeof(SMsgAVIoctrlFormatExtStorageReq)];
            free(s);
        }
    }
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    if (camera_ == _camera && type == IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_RESP) {
        SMsgAVIoctrlFormatExtStorageResp *s = (SMsgAVIoctrlFormatExtStorageResp *)data;
        dispatch_async( dispatch_get_main_queue(), ^{
            if (s->result == 0)
            {
                [self showTips2:NSLocalizedString(@"Format completed.", @"")];
            }
            else
            {
                [self showTips2:NSLocalizedString(@"Format failed.", @"")];
            }
        });

    }
}


@end
