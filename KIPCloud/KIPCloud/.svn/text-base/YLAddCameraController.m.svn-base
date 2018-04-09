//
//  YLAddCameraController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLAddCameraController.h"
#import "YLTextFieldCell.h"
#import "YLSmallButtonCell.h"
#import "YLScanQRController.h"
#import "YLSearchController.h"
#import "YLBigButtonCell.h"
#import "YLAdvanceSetController.h"

@interface YLAddCameraController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,YLScanQRControllerDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *textFieldName;
@property (strong, nonatomic) UITextField *textFieldDID;
@property (strong, nonatomic) UITextField *textFieldPassword;


@end

@implementation YLAddCameraController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
    
}

-(void) initUI
{
    //[super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Add Camera", @"")];
    self.navigationItem.title = title;
    [self addGesture];
    if(!_bAddCameraPage)
    {
        UIBarButtonItem *leftNavBar =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@KYL_NAV_BAR_BG_IMAGE] style:UIBarButtonItemStylePlain target:self action:@selector(btnBarLeftButtonClicked:)];
        self.navigationItem.leftBarButtonItem = leftNavBar;
    }
    
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnBarLeftButtonClicked:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) btnQRScanClicked:(id) sender
{
    YLScanQRController *vc = [[YLScanQRController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) btnSaveClicked:(id) sender
{
    [self hideTheKeyboard];
    [self getUIInput];
    _name = [_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _did = [_did stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _password = [_password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([_name length] < 1)
    {
        [self showTips2:NSLocalizedString(@"Please input valid name", @"")];
        return;
    }
    if([_did length] < 2)
    {
        [self showTips2:NSLocalizedString(@"Please input valid uid", @"")];
        return;
    }
    
    if (_did == nil || [_did length] != 20) {
        [self showTips2:NSLocalizedString(@"Camera UID length must be 20 characters", @"")];
        return;
    }
    else if (_name == nil || [_name length] == 0) {
        [self showTips2:NSLocalizedString(@"Camera Name can not be empty", @"")];
        return;
    }
    else if (_password == nil || [_password length] == 0) {
        [self showTips2:NSLocalizedString(@"Camera Password can not be empty", @"")];
        return;
    }
    else if ([_name length] > 0 && [_did length] == 20 && [_password length] > 0) {
        
        if(_bAddCameraPage)
        {
            if([[YLGlobal shareInstance] isExistDevice:_did])
            {
                [self showTips2:NSLocalizedString(@"This device is already exists", @"")];
                return;
            }
            //添加设备到数据库
            if ([self addNewDeviceInfoToDB:_did name:_name password:_password]) {
                [self showTips2:NSLocalizedString(@"Add camera successfully", @"")];
                //跳转到设备列表页面
                [self.tabBarController setSelectedIndex:0];
            }
            else
            {
                [self showTips2:NSLocalizedString(@"Add camera failed", @"")];
                return;
            }
        }
        else
        {
            //编辑设备页面
            //MyCamera *camera = [[YLGlobal shareInstance] getCamera:_did];
            if(self.camera)
            {
                YLDeviceInfo *deviceInfo = [[YLDeviceInfo alloc] initWithDevice:_camera.device];
                deviceInfo.dev_nickname = _name;
                deviceInfo.dev_pwd = _password;
                deviceInfo.view_pwd = _password;
                deviceInfo.dev_name = _name;
                BOOL bOk = [[YLGlobal shareInstance] updateCamera:deviceInfo];
                if(bOk)
                {
                    [self showTips2:NSLocalizedString(@"Update camera successfully", @"")];
                    //跳转到设备列表页面
                    //[self.tabBarController setSelectedIndex:0];
                    [self.navigationController popViewControllerAnimated:YES];

                }
                else{
                    [self showTips2:NSLocalizedString(@"Update camera failed", @"")];
                }
            }
        }
    }
    else {
        [self showTips2:NSLocalizedString(@"The name, uid and password field can not be empty", @"")];
        return;
    }
    
}

-(void) getUIInput
{
    UITableViewCell *cell1 =  (UITableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self getBaseInfoSectionCameraNameRow] inSection:[self getBaseInfoSection]]];
    
    UITableViewCell *cell2 =  (UITableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self getBaseInfoSectionPasswordRow] inSection:[self getBaseInfoSection]]];
    
    YLTextFieldCell * cellName = (YLTextFieldCell*)cell1;
    YLTextFieldCell * cellPwd = (YLTextFieldCell*)cell2;
    self.name = cellName.textField.text;
    self.password = cellPwd.textField.text;
}

-(void) btnLanSearchClicked:(id) sender
{
    [self gotoTheSearchPage];
}

-(void) btnAdvanceSetClicked:(id) sender
{
    DebugLog(@"%s",__FUNCTION__);
    [self gotoTheAdvanceSetPage];
}

-(void) gotoTheAdvanceSetPage
{
    YLAdvanceSetController *vc = [[YLAdvanceSetController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.camera = _camera;
    [self.navigationController pushViewController:vc animated:YES];
}



-(void) gotoTheSearchPage
{
    YLSearchController *vc = [[YLSearchController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:vc animated:YES];
}

-(BOOL) addNewDeviceInfoToDB:(NSString *) did name:(NSString *)name password:(NSString*) password
{
    YLDeviceInfo *device = [[YLDeviceInfo alloc] init];
    device.uid = did;
    device.dev_name = name;
    device.dev_nickname = name;
    device.dev_pwd = password;
    device.view_pwd = password;
    device.view_acc = @"admin";
    return [[YLGlobal shareInstance] addCamera:device];
}

-(BOOL) updateDeviceInfoToDB:(NSString *) did name:(NSString *)name password:(NSString*) password
{
    YLDeviceInfo *device = [[YLDeviceInfo alloc] init];
    device.uid = did;
    device.dev_name = name;
    device.dev_nickname = name;
    device.dev_pwd = password;
    device.view_pwd = password;
    device.view_acc = @"admin";
    return [[YLGlobal shareInstance] updateCamera:device];
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

#pragma mark tableview delegate

//用户基本信息
- (BOOL) isSupportBaseInfoSection
{
    return ([self isSupportBaseInfoSectionCameraNameRow]
            || [self isSupportBaseInfoSectionDIDRow]
            || [self isSupportBaseInfoSectionPasswordRow]
            || [self isSupportBaseInfoSectionSaveButtonRow]
            );
}


- (BOOL) isSupportBaseInfoSectionCameraNameRow//设备名
{
    return YES;
}

- (BOOL) isSupportBaseInfoSectionDIDRow//did
{
    return YES;
}

- (BOOL) isSupportBaseInfoSectionPasswordRow//密码
{
    return YES;
}

- (BOOL) isSupportBaseInfoSectionSaveButtonRow//button save
{
    return YES;
}



- (BOOL) isSupportLANSearchSection
{
    return ([self isSupportLANSearchSectionLANSearchRow]);
}

- (BOOL) isSupportLANSearchSectionLANSearchRow //局域网搜索
{
    return _bAddCameraPage;
}

- (BOOL) isSupportAdvanceSetSection
{
    return ([self isSupportAdvanceSetSectionSettingRow]);
}

- (BOOL) isSupportAdvanceSetSectionSettingRow //高级设置
{
    return !_bAddCameraPage;
}



- (int)getBaseInfoSection //基本信息Section
{
    int idx = 0;
    
    return [self isSupportBaseInfoSection] ? idx : -1;
}

- (int)getLANSearchSection //
{
    int idx = 1;
    if (![self isSupportBaseInfoSection])
        idx--;
    return [self isSupportLANSearchSection] ? idx : -1;
}

- (int)getAdvanceSetSection //
{
    int idx = 2;
    if (![self isSupportBaseInfoSection])
        idx--;
    if (![self isSupportLANSearchSection])
        idx--;
    return [self isSupportAdvanceSetSection] ? idx : -1;
}



- (int)getBaseInfoSectionCameraNameRow
{
    int idx = 0;
    return [self isSupportBaseInfoSectionCameraNameRow] ? idx : -1;
}

- (int)getBaseInfoSectionDIDRow//did
{
    int idx = 1;
    
    if (![self isSupportBaseInfoSectionCameraNameRow])
        idx--;
    
    return [self isSupportBaseInfoSectionDIDRow] ? idx : -1;
}

- (int)getBaseInfoSectionPasswordRow//密码
{
    int idx = 2;
    
    if (![self isSupportBaseInfoSectionCameraNameRow])
        idx--;
    
    if (![self isSupportBaseInfoSectionDIDRow])
        idx--;
    
    return [self isSupportBaseInfoSectionPasswordRow] ? idx : -1;
}

- (int)getBaseInfoSectionSaveButtonRow//保存按钮
{
    int idx = 3;
    
    if (![self isSupportBaseInfoSectionCameraNameRow])
        idx--;
    
    if (![self isSupportBaseInfoSectionDIDRow])
        idx--;
    if (![self isSupportBaseInfoSectionPasswordRow])
        idx--;
    
    return [self isSupportBaseInfoSectionSaveButtonRow] ? idx : -1;
}



- (int)getLANSearchSectionLANSearchRow //局域网搜索
{
    int idx = 0;
    return [self isSupportLANSearchSectionLANSearchRow] ? idx : -1;
    
}


- (int)getAdvanceSetSectionSettingRow //高级设置
{
    int idx = 0;
    return [self isSupportAdvanceSetSectionSettingRow] ? idx : -1;
}



//end add by kongyulu at 20140319

#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    int row = 0;
    
    if ([self  isSupportBaseInfoSection])
        row++;
    if ([self  isSupportLANSearchSection])
        row++;
    if ([self  isSupportAdvanceSetSection])
        row++;
    
    return row;
    
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [self getBaseInfoSection]) {
        NSInteger row = 0;
        if ([self isSupportBaseInfoSectionCameraNameRow]) row++;
        if ([self isSupportBaseInfoSectionDIDRow]) row++;
        if ([self isSupportBaseInfoSectionPasswordRow]) row++;//
        if ([self isSupportBaseInfoSectionSaveButtonRow]) row++;
        return row;
    }
    else if (section == [self getLANSearchSection]) {
        NSInteger row = 0;
        if ([self isSupportLANSearchSectionLANSearchRow]) row++;
        return row;
    }
    else if (section == [self getAdvanceSetSection]) {
        NSInteger row = 0;
        if ([self isSupportAdvanceSetSectionSettingRow]) row++;
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
        
        if (row == [self getBaseInfoSectionCameraNameRow]) {//用户名
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
        }
        else if (row == [self getBaseInfoSectionDIDRow]) {//did
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
        }
        else if (row == [self getBaseInfoSectionPasswordRow]) {//
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
        }
        else if (row == [self getBaseInfoSectionSaveButtonRow]) {//
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
        }
        else
        {
            
        }
    }
    else if (section == [self getLANSearchSection]) {
        if (row == [self getLANSearchSectionLANSearchRow]) {//删除用户
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
        }
    }
    else if (section == [self getAdvanceSetSection]) {
        if (row == [self getAdvanceSetSectionSettingRow]) {//删除用户
            fHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 64:44);
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
    else if (section == [self getLANSearchSection]) {
        
    }
    else if (section == [self getAdvanceSetSection]) {
       
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
    else if (section == [self getLANSearchSection]) {
        
    }
    else if (section == [self getAdvanceSetSection]) {
        
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
    else if (section == [self getLANSearchSection]) {
        
    }
    else if (section == [self getAdvanceSetSection]) {
        
    }
    else {
        
    }
    
    return gHeight;
}


- (UIView *)tableView:(UITableView *) ntableView viewForHeaderInSection:(NSInteger)section
{
    if (section == [self getBaseInfoSection]) {
        
    }
    else if (section == [self getLANSearchSection]) {
        
    }
    else if (section == [self getAdvanceSetSection]) {
        
    }
    else {
        
    }
    return nil;
}




- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    
    static NSString *cellIdentifier1 = @"DefaultCell";
    static NSString *cellIdentifier2 = @"YLTextFieldCell";
    static NSString *cellIdentifier3 = @"YLBigButtonCell";

    
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
        
        
        cell2.textField.text = _did;
        cell2.textField.tag = row;
        cell2.btnIcon.hidden = YES;
        

        if (row == [self getBaseInfoSectionCameraNameRow]) {//用户名
            cell2.textField.text = _name;
            cell2.textField.placeholder = NSLocalizedString(@"Camera Name",  nil);
            cell2.labelTitle.text = NSLocalizedString(@"Camera Name",  nil);
            
        }
        else if (row == [self getBaseInfoSectionDIDRow]) {//did
            cell2.textField.enabled = NO;
            cell2.labelTitle.text = NSLocalizedString(@"Camera UID",  nil);
            cell2.textField.placeholder = NSLocalizedString(@"Camera UID",  nil);
            [cell2.btnIcon addTarget:self action:@selector(btnQRScanClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (_bAddCameraPage) {
                cell2.textField.enabled = YES;
                cell2.btnIcon.hidden = NO;
            }
            else
            {
                cell2.textField.enabled = NO;
                cell2.btnIcon.hidden = YES;
            }
            cell2.textField.text = _did;
        }
        else if (row == [self getBaseInfoSectionPasswordRow]) {//
            cell2.textField.text = _password;
            cell2.textField.placeholder = NSLocalizedString(@"Camera Password",  nil);
            cell2.textField.secureTextEntry = YES;
            cell2.labelTitle.text = NSLocalizedString(@"Camera Password",  nil);
        }
        else if (row == [self getBaseInfoSectionSaveButtonRow]) {//
            cell =  [aTableView dequeueReusableCellWithIdentifier:cellIdentifier3];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YLSmallButtonCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            YLSmallButtonCell *buttonCell = (YLSmallButtonCell *)cell;
            [buttonCell.button addTarget:self action:@selector(btnSaveClicked:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCell.button setTitle:NSLocalizedString(@"Save",  nil) forState:UIControlStateNormal];
            buttonCell.button.tag = row;
        }
        else
        {
            
        }
    }
    else if (section == [self getLANSearchSection]) {
        if (row == [self getLANSearchSectionLANSearchRow]) {//局域网搜索
            cell =  [aTableView dequeueReusableCellWithIdentifier:cellIdentifier3];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YLBigButtonCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            YLBigButtonCell *buttonCell = (YLBigButtonCell *)cell;
            [buttonCell.button addTarget:self action:@selector(btnLanSearchClicked:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCell.button setTitle:NSLocalizedString(@"LAN Search",  nil) forState:UIControlStateNormal];
            buttonCell.button.tag = row;
        }
    }
    else if (section == [self getAdvanceSetSection]) {

        if (row == [self getAdvanceSetSectionSettingRow]) {//高级设置
            
            cell =  [aTableView dequeueReusableCellWithIdentifier:cellIdentifier3];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YLBigButtonCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            
            YLBigButtonCell *buttonCell = (YLBigButtonCell *)cell;
            [buttonCell.button addTarget:self action:@selector(btnAdvanceSetClicked:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCell.button setTitle:NSLocalizedString(@"Advance Setting",  nil) forState:UIControlStateNormal];
            buttonCell.button.tag = row;
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
        
        if (row == [self getBaseInfoSectionCameraNameRow]) {//
            
        }
        else if (row == [self getBaseInfoSectionDIDRow]) {//did
            
        }
        else if (row == [self getBaseInfoSectionPasswordRow]) {//
            
        }
        else
        {
            
        }
    }
    else if (section == [self getLANSearchSection]) {
        if (row == [self getLANSearchSectionLANSearchRow]) {//
        }
    }
    else if (section == [self getAdvanceSetSection]) {
        if (row == [self getAdvanceSetSectionSettingRow]) {//
            
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
    if (tag == [self getBaseInfoSectionCameraNameRow]) {
        self.name = textField.text;
    }
    else if (tag == [self getBaseInfoSectionDIDRow]) {
        self.did = textField.text;
    }
    else if (tag == [self getBaseInfoSectionPasswordRow]) {
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
    if (tag == [self getBaseInfoSectionCameraNameRow]) {
        
    }
    else if (tag == [self getBaseInfoSectionDIDRow]) {
        
    }
    else if (tag == [self getBaseInfoSectionPasswordRow]) {
        if (range.location >= 30) {
            return NO;
        }
    }
    
    return YES;
}

-(void) updateTableView
{
    [self.tableView reloadData];
}

#pragma mark YLQRScanControllerDelegate
-(void) YLScanQRController_scanSucceed:(NSString *)str
{
    self.did = str;
    [self hideTheKeyboard];
    [self updateTableView];
}

@end
