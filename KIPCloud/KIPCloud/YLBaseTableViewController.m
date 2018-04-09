//
//  YLBaseTableViewController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/14.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLBaseTableViewController.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import "XBToastManager.h"
#import "mytoast.h"

@interface YLBaseTableViewController ()
@property (nonatomic, retain) UILabel * toastLabel;
@end

@implementation YLBaseTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initUI];
}


#pragma mark - IBActions


//保存按钮点击事件
- (void) btnBarLeftButtonClicked:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//右侧按钮
- (void) btnBarRightButtonClicked:(id) sender
{
}


- (void) initUI
{
    [self initBarButton];
    [self.view setBackgroundColor:KYL_ViewBgColor];
}





- (void) initBarButton
{
    NSString *strTitle = NSLocalizedString(@"title_base_view_control",  nil);
    self.navigationItem.title = strTitle;
    
    UIBarButtonItem *leftNavBar =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@KYL_NAV_BAR_BG_IMAGE] style:UIBarButtonItemStylePlain target:self action:@selector(btnBarLeftButtonClicked:)];
    self.navigationItem.leftBarButtonItem = leftNavBar;
    
    
}

- (void) initData
{
    
}

- (void) showHUD:(NSString *) sTitle
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText =  sTitle;
    //CGRect rect = self.view.frame;
    //hud.minSize = rect.size;
    hud.backgroundColor = [UIColor clearColor];
    hud.opacity = 0.2;
    hud.opaque = NO;
    hud.minSize = CGSizeMake(135.f, 135.f);
}

- (void) hideHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (void) showTips:(NSString *) sMsg
{
    [mytoast showWithText:sMsg];
}

- (void) showTips2:(NSString *) sMsg
{
    [[XBToastManager ShardInstance] showtoast:sMsg];
}


#pragma mark show information lable

- (void)__show : (UIView*) aView {
    [UIView beginAnimations:@"show" context:(__bridge void * _Nullable)(aView)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationDidStopSelector:@selector(__animationDidStop:__finished:__context:)];
    aView.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void)__hide : (UIView*) aView {
    [self performSelectorOnMainThread:@selector(__hideThread:) withObject:aView waitUntilDone:NO];
    
}

- (void) hideCustomToast
{
    if (_toastLabel) {
        [_toastLabel removeFromSuperview];
    }
}

- (void)__hideThread : (UIView*) aView {
    [UIView beginAnimations:@"hide" context:(__bridge void * _Nullable)(aView)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.8f];
    [UIView setAnimationDidStopSelector:@selector(__animationDidStop:__finished:__context:)];
    aView.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void)__animationDidStop:(NSString *)animationID __finished:(NSNumber *)finished __context:(void *)context {
    UIView *aView = (__bridge UIView*)context;
    if ([animationID isEqualToString:@"hide"]) {
        //NSLog(@"hide....");
        [aView removeFromSuperview];
        //[aView release];
    }
    else if ([animationID isEqualToString:@"show"]) {
        // NSLog(@"show...");
        //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(__hide:) userInfo:aView repeats:NO];
        [self performSelector:@selector(__hide:) withObject:aView afterDelay:0.5];
    }
}

- (void) showWithText: (NSString*) strText superView: (UIView*) superView bLandScap:(BOOL) bLandScap
{
    float screenWidth, screenHeight;
    if (!bLandScap) {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
    }else {
        screenWidth = [UIScreen mainScreen].bounds.size.height;
        screenHeight = [UIScreen mainScreen].bounds.size.width;
    }
    
    UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    self.toastLabel = textLabel;
    
    [textLabel setNumberOfLines:0];
    UIFont *font = [UIFont systemFontOfSize:15];
    //CGSize size = CGSizeMake(170,100);
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //CGSize labelsize = [strText sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    CGSize labelsize = [strText sizeWithFont:font];
    
    float width = labelsize.width + 10;
    float height = labelsize.height;
    float x = floor((screenWidth - width) / 2.0f);
    float y = floor(screenHeight - height - 50.0f);
    
    if (!bLandScap) {
        y -= 10.0f;
    }
    
    [textLabel setFrame: CGRectMake(x, y, width, height)];
    textLabel.text = strText;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = font;
    textLabel.layer.masksToBounds = YES;
    textLabel.layer.cornerRadius = 5.0;
    textLabel.backgroundColor = [UIColor blackColor];
    textLabel.alpha = 1.0f;
    [superView addSubview:textLabel];
    
    [self __show:textLabel];
    
}

- (void) showWithText: (NSString*) strText bLandScap:(BOOL) bLandScap
{
    float screenWidth, screenHeight;
    if (!bLandScap) {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
    }else {
        screenWidth = [UIScreen mainScreen].bounds.size.height;
        screenHeight = [UIScreen mainScreen].bounds.size.width;
    }
    
    UILabel * textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    self.toastLabel = textLabel;
    
    [textLabel setNumberOfLines:0];
    UIFont *font = [UIFont systemFontOfSize:15];
    //CGSize size = CGSizeMake(170,100);
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //CGSize labelsize = [strText sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    CGSize labelsize = [strText sizeWithFont:font];
    
    float width = labelsize.width + 10;
    float height = labelsize.height;
    float x = floor((screenWidth - width) / 2.0f);
    float y = floor(screenHeight - height - 50.0f);
    
    if (!bLandScap) {
        y -= 10.0f;
    }
    
    [textLabel setFrame: CGRectMake(x, y, width, height)];
    textLabel.text = strText;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = font;
    textLabel.layer.masksToBounds = YES;
    textLabel.layer.cornerRadius = 5.0;
    textLabel.backgroundColor = [UIColor blackColor];
    textLabel.alpha = 1.0f;
    [self.view addSubview:textLabel];
    
    [self __show:textLabel];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
