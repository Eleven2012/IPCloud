//
//  YLWiFiPasswordController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLWiFiPasswordController.h"
#import "YLTextFieldCell.h"

@interface YLWiFiPasswordController ()<MyCameraDelegate,UITextFieldDelegate>

@end

@implementation YLWiFiPasswordController

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
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Enter Password", @"")];
    self.navigationItem.title = title;
    self.navigationItem.prompt = [NSString stringWithFormat:NSLocalizedString(@"Please enter password for %@", @""), _ssid];
}

-(void) initBarButton
{
    [super initBarButton];
    
    UIBarButtonItem *rightNavBar =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_finish"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBarRightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightNavBar;
    
}

- (void) hideTheKeyboard
{
    [self.view endEditing:YES];
}

-(void) btnBarRightButtonClicked:(id) sender
{
    [self hideTheKeyboard];
    if([self saveData])
    {
        [self showTips2:NSLocalizedString(@"Set Wi-Fi successfully!", @"")];
        if(_delegate && [_delegate respondsToSelector:@selector(YLWiFiPasswordControllerDelegate_didSetFinished:ssid:)])
        {
            [_delegate YLWiFiPasswordControllerDelegate_didSetFinished:self ssid:_ssid];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self showTips2:NSLocalizedString(@"Set Wi-Fi failed!", @"")];
    }
}

-(BOOL) saveData
{
    BOOL bDoWaiting = FALSE;
    if (_password != nil && [_password length] > 0) {
        if( [_password length] <= 30 ) {
            SMsgAVIoctrlSetWifiReq *s = malloc(sizeof(SMsgAVIoctrlSetWifiReq));
            memcpy(s->ssid, [_ssid UTF8String], 32);
            memcpy(s->password, [_password UTF8String], 32);
            s->enctype = _enctype;
            s->mode = _mode;
            [_camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SETWIFI_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlSetWifiReq)];
            
            free(s);
            bDoWaiting = TRUE;
        }
        else {
             [self showTips2:NSLocalizedString(@"The password is more than 30 characters", @"")];
            return NO;
        }
    }
    else {
        [self showTips2:[NSString stringWithFormat:NSLocalizedString(@"Please enter password for %@", @""), _ssid]];
        return NO;
    }
    if( bDoWaiting ) {
        [self showHUD:NSLocalizedString(@"Setting Wi-Fi", @"")];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//用户基本信息
- (BOOL) isSupportBaseInfoSection
{
    return ([self isSupportBaseInfoSectionPasswordRow]
            );
}


- (BOOL) isSupportBaseInfoSectionPasswordRow//password
{
    return YES;
}

- (int)getBaseInfoSection //基本信息Section
{
    int idx = 0;
    
    return [self isSupportBaseInfoSection] ? idx : -1;
}

- (int)getBaseInfoSectionPasswordRow
{
    int idx = 0;
    return [self isSupportBaseInfoSectionPasswordRow] ? idx : -1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    int row = 0;
    if ([self  isSupportBaseInfoSection])
        row++;
    return row;
    
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [self getBaseInfoSection]) {
        NSInteger row = 0;
        if ([self isSupportBaseInfoSectionPasswordRow]) row++;//
        return row;
    }
    else {
        return 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    CGFloat fHeight = 44.0;
    //CGFloat fSupperViewHeight = [[UIScreen mainScreen] bounds].size.height -  100;
    if (section == [self getBaseInfoSection]) {
        if (row == [self getBaseInfoSectionPasswordRow]) {//
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
        }
        else
        {
        }
    }
    else {
        
    }
    
    
    return fHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat gHeight = 5;
    if (section == [self getBaseInfoSection]) {
        
    }
    else {
        
    }
    return gHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString *sTitle = nil;
    if (section == [self getBaseInfoSection]) {
        
    }
    else {
    }
    return sTitle;
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat gHeight = 5;
    if (section == [self getBaseInfoSection]) {
        
    }
    return gHeight;
}


- (UIView *)tableView:(UITableView *) ntableView viewForHeaderInSection:(NSInteger)section
{
    if (section == [self getBaseInfoSection]) {
    }
    else {
    }
    return nil;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier2 = @"YLTextFieldCell";
    UITableViewCell *cell = nil;
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (section == [self getBaseInfoSection]) {
        cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YLTextFieldCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        //disable selected cell
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        YLTextFieldCell * cell2 = (YLTextFieldCell*)cell;
        cell2.tag = row;
        cell2.textField.delegate = self;
        
        cell2.textField.tag = row;
        cell2.btnIcon.hidden = YES;
        if (row == [self getBaseInfoSectionPasswordRow]) {//
            cell2.textField.text = _password;
            cell2.textField.placeholder = NSLocalizedString(@"Input password",  nil);
            cell2.textField.secureTextEntry = YES;
            cell2.labelTitle.text = NSLocalizedString(@"Password",  nil);
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark textFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    if (tag == [self getBaseInfoSectionPasswordRow]) {
        self.password = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger tag = textField.tag;
    if (tag == [self getBaseInfoSectionPasswordRow]) {
        if (range.location >= 30) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == _camera && type == IOTYPE_USER_IPCAM_SETWIFI_RESP) {
        NSLog( @"IOTYPE_USER_IPCAM_SETWIFI_RESP received." );
        dispatch_async( dispatch_get_main_queue(), ^{
            [self hideHUD];
        });
        int result = -1;
        SMsgAVIoctrlSetWifiResp *s = (SMsgAVIoctrlSetWifiResp *)data;
        result = s->result;
        
        if (result == 0) {
            dispatch_async( dispatch_get_main_queue(), ^{
                [self showTips2:NSLocalizedString(@"Set Wi-Fi password successfully!", @"")];
                if(_delegate && [_delegate respondsToSelector:@selector(YLWiFiPasswordControllerDelegate_didSetFinished:ssid:)])
                {
                    [_delegate YLWiFiPasswordControllerDelegate_didSetFinished:self ssid:_ssid];
                }
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        else {
            [self showTips2:[NSString stringWithFormat:NSLocalizedString(@"Incorrect password for %@", @""), _ssid]];
        }            
    }
}


@end
