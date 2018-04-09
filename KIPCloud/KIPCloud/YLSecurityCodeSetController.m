//
//  YLSecurityCodeSetController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLSecurityCodeSetController.h"
#import "YLPasswordCell.h"
#import "YLTextFieldCell.h"

@interface YLSecurityCodeSetController ()<UITextFieldDelegate,MyCameraDelegate>
{
    
}



@property (strong, nonatomic) NSArray *listData;

@end



@implementation YLSecurityCodeSetController
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
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Security Code", @"")];
    self.navigationItem.title = title;
    [self addGesture];
    
}

-(void) initBarButton
{
    [super initBarButton];
    
    UIBarButtonItem *rightNavBar =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_finish"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBarRightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightNavBar;
    
}

-(void) btnBarRightButtonClicked:(id) sender
{
    if([self savePwdInfo])
    {
        [self showTips2:NSLocalizedString(@"Set password successfully!", @"")];
        if(_delegate && [_delegate respondsToSelector:@selector(YLSecurityCodeSetController_savePasswordSucceed:)])
        {
            [_delegate YLSecurityCodeSetController_savePasswordSucceed:_sNewPwd];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self showTips2:NSLocalizedString(@"Set password failed!", @"")];
    }
}

-(BOOL) savePwdInfo
{
    [self hideTheKeyboard];
    if ([_sOldPwd length] == 0 && [_sNewPwd length] == 0 && [_sConfirmPwd length] == 0) {
        [self showTips2:NSLocalizedString(@"Please input the password", @"")];
        return NO;
    }
    if( NSOrderedSame != [_sOldPwd compare:self.camera.viewPwd] ) {
        [self showTips2:NSLocalizedString(@"The old password is invalid", @"")];
        return NO;
    }
    if (![_sNewPwd isEqualToString:_sConfirmPwd]) {
        [self showTips2:NSLocalizedString(@"The new password and confirm password do not match", @"")];
        return NO;
    }
    if ([_sNewPwd length] > 15 || [_sConfirmPwd length] > 15) {
        [self showTips2:NSLocalizedString(@"The new password is more than 15 characters", @"")];
        return NO;
    }
    // send ioctrl to change password of device.
    SMsgAVIoctrlSetPasswdReq *structSetPassword = malloc(sizeof(SMsgAVIoctrlSetPasswdReq));
    memset(structSetPassword, 0, sizeof(SMsgAVIoctrlSetPasswdReq));
    memcpy(structSetPassword->oldpasswd, [_sOldPwd UTF8String], [_sOldPwd length]);
    memcpy(structSetPassword->newpasswd, [_sNewPwd UTF8String], [_sNewPwd length]);
    
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SETPASSWORD_REQ Data:(char *)structSetPassword DataSize:sizeof(SMsgAVIoctrlSetPasswdReq)];
    free(structSetPassword);
    
    NSLog(@"change security code(%@) in SecurityCodeController", _sNewPwd);
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark 添加手势
- (void) addGesture
{
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:singleTapRecognizer];
    //free memory
}

// 单击
- (void)handleSingleTapFrom:(UITapGestureRecognizer*)recognizer {
    [self hideTheKeyboard];
}

- (void) hideTheKeyboard
{
    [self.view endEditing:YES];
}


#pragma mark - Table view data source

//用户基本信息
- (BOOL) isSupportBaseInfoSection
{
    return ([self isSupportBaseInfoSectionOldPwdRow]
            || [self isSupportBaseInfoSectionNewPwdRow]
            || [self isSupportBaseInfoSectionConfirmPwdRow]
            );
}


- (BOOL) isSupportBaseInfoSectionOldPwdRow//
{
    return YES;
}

- (BOOL) isSupportBaseInfoSectionNewPwdRow//
{
    return YES;
}

- (BOOL) isSupportBaseInfoSectionConfirmPwdRow//
{
    return YES;
}

- (int)getBaseInfoSection //基本信息Section
{
    int idx = 0;
    
    return [self isSupportBaseInfoSection] ? idx : -1;
}


- (int)gettBaseInfoSectionOldPwdRow
{
    int idx = 0;
    return [self isSupportBaseInfoSectionOldPwdRow] ? idx : -1;
}

- (int)getBaseInfoSectionNewPwdRow//
{
    int idx = 1;
    
    if (![self isSupportBaseInfoSectionOldPwdRow])
        idx--;
    
    return [self isSupportBaseInfoSectionNewPwdRow] ? idx : -1;
}

- (int)getBaseInfoSectionConfirmPwdRow//
{
    int idx = 2;
    
    if (![self isSupportBaseInfoSectionOldPwdRow])
        idx--;
    
    if (![self isSupportBaseInfoSectionNewPwdRow])
        idx--;
    
    return [self isSupportBaseInfoSectionConfirmPwdRow] ? idx : -1;
}

//end add by kongyulu at 20140319

#pragma mark -
#pragma mark TableViewDelegate

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
        if ([self isSupportBaseInfoSectionOldPwdRow]) row++;
        if ([self isSupportBaseInfoSectionNewPwdRow]) row++;
        if ([self isSupportBaseInfoSectionConfirmPwdRow]) row++;//
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
        
        if (row == [self gettBaseInfoSectionOldPwdRow]) {//
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
        }
        else if (row == [self getBaseInfoSectionNewPwdRow]) {//d
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
        }
        else if (row == [self getBaseInfoSectionConfirmPwdRow]) {//
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
    else {
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    
    static NSString *cellIdentifier2 = @"YLTextFieldCell";
    UITableViewCell *cell = nil;
    NSInteger row = anIndexPath.row;
    NSInteger section = anIndexPath.section;
    
    if (section == [self getBaseInfoSection]) {
        cell =  [aTableView dequeueReusableCellWithIdentifier:cellIdentifier2];
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
        cell2.textField.secureTextEntry = YES;
        
        if (row == [self gettBaseInfoSectionOldPwdRow]) {//
            cell2.textField.text = _sOldPwd;
            cell2.textField.placeholder = NSLocalizedString(@"Old Password",  nil);
            cell2.labelTitle.text = NSLocalizedString(@"Old Password",  nil);
            
        }
        else if (row == [self getBaseInfoSectionNewPwdRow]) {//
            cell2.labelTitle.text = NSLocalizedString(@"New Password",  nil);
            cell2.textField.placeholder = NSLocalizedString(@"New Password",  nil);
            cell2.textField.text = _sNewPwd;
        }
        else if (row == [self getBaseInfoSectionConfirmPwdRow]) {//
            cell2.textField.text = _sConfirmPwd;
            cell2.textField.placeholder = NSLocalizedString(@"Confirm Password",  nil);
            cell2.textField.secureTextEntry = YES;
            cell2.labelTitle.text = NSLocalizedString(@"Confirm Password",  nil);
        }
        else
        {
        }
    }
    else {
        
    }
    
    
    return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row;
    
    //UITableViewCell *cell =  (UITableViewCell*)[anTableView cellForRowAtIndexPath:anIndexPath];
    //CGRect rectCell =[self.view convertRect:cell.bounds fromView:cell];
    
    if (section == [self getBaseInfoSection]) {
        
        if (row == [self gettBaseInfoSectionOldPwdRow]) {//
            
        }
        else if (row == [self getBaseInfoSectionNewPwdRow]) {//did
            
        }
        else if (row == [self getBaseInfoSectionConfirmPwdRow]) {//
            
        }
        else
        {
            
        }
    }
    else {
        
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    if (tag == 0) {
        self.sOldPwd = textField.text;
    }
    else if (tag == 1) {
        self.sNewPwd = textField.text;
    }
    else if (tag == 2) {
        self.sConfirmPwd = textField.text;
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
    if (tag == 0) {
        if (range.location >= 30) {
            return NO;
        }
    }
    else if (tag == 1) {
        if (range.location >= 30) {
            return NO;
        }
    }
    else if (tag == 2) {
        if (range.location >= 30) {
            return NO;
        }
    }
    
    return YES;
}


@end
