//
//  YLMoreInfoController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLMoreInfoController.h"

@interface YLMoreInfoController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation YLMoreInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initUI
{
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"App Info", @"")];
    self.navigationItem.title = title;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    unsigned long ulIOTCVer;
    int nAVAPIVer;
    char cIOTCVer[4];
    char cAVAPIVer[4];
    
    // IOTC_Get_Version(&ulIOTCVer);
    cIOTCVer[3] = (char)ulIOTCVer;
    cIOTCVer[2] = (char)(ulIOTCVer >> 8);
    cIOTCVer[1] = (char)(ulIOTCVer >> 16);
    cIOTCVer[0] = (char)(ulIOTCVer >> 24);
    
    // nAVAPIVer = avGetAVApiVer();
    cAVAPIVer[3] = (char)nAVAPIVer;
    cAVAPIVer[2] = (char)(nAVAPIVer >> 8);
    cAVAPIVer[1] = (char)(nAVAPIVer >> 16);
    cAVAPIVer[0] = (char)(nAVAPIVer >> 24);
    
    NSString *prodName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    UIImageView *appIconView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appLog"]];
    [appIconView setFrame:CGRectMake(0, 10, [[UIScreen mainScreen] bounds].size.width, 120.0)];
    [appIconView setContentMode:UIViewContentModeScaleAspectFit];
    [appIconView setBackgroundColor:[UIColor clearColor]];
    
    UILabel *appName = [[UILabel alloc]initWithFrame:CGRectMake(0, 140, [[UIScreen mainScreen] bounds].size.width, 30)];
    [appName setBackgroundColor:[UIColor clearColor]];
    [appName setShadowColor:[UIColor whiteColor]];
    [appName setShadowOffset:CGSizeMake(0, 1)];
    [appName setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
    [appName setText:prodName];
    [appName setTextAlignment:UITextAlignmentCenter];
    
    UILabel *appVer = [[UILabel alloc]initWithFrame:CGRectMake(0, 165, [[UIScreen mainScreen] bounds].size.width, 30)];
    [appVer setBackgroundColor:[UIColor clearColor]];
    [appVer setShadowColor:[UIColor whiteColor]];
    [appVer setShadowOffset:CGSizeMake(0, 1)];
    [appVer setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Version", @""), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [appVer setTextAlignment:UITextAlignmentCenter];
    
    UILabel *IOTCVer = [[UILabel alloc]initWithFrame:CGRectMake(0, 195, [[UIScreen mainScreen] bounds].size.width, 30)];
    [IOTCVer setBackgroundColor:[UIColor clearColor]];
    [IOTCVer setShadowColor:[UIColor whiteColor]];
    [IOTCVer setShadowOffset:CGSizeMake(0, 1)];
    // [IOTCVer setText:[NSString stringWithFormat:@"IOTCAPIs %d.%d.%d.%d", cIOTCVer[0], cIOTCVer[1], cIOTCVer[2], cIOTCVer[3]]];
    [IOTCVer setText:[NSString stringWithFormat:@"IOTCAPIs %@", [Camera getIOTCAPIsVerion]]];
    [IOTCVer setFont:[UIFont fontWithName:@"Arial" size:14]];
    [IOTCVer setTextAlignment:UITextAlignmentCenter];
    
    UILabel *AVAPIVer = [[UILabel alloc]initWithFrame:CGRectMake(0, 215, [[UIScreen mainScreen] bounds].size.width, 30)];
    [AVAPIVer setBackgroundColor:[UIColor clearColor]];
    [AVAPIVer setShadowColor:[UIColor whiteColor]];
    [AVAPIVer setShadowOffset:CGSizeMake(0, 1)];
    //[AVAPIVer setText:[NSString stringWithFormat:@"AVAPIs %d.%d.%d.%d", cAVAPIVer[0], cAVAPIVer[1], cAVAPIVer[2], cAVAPIVer[3]]];
    [AVAPIVer setText:[NSString stringWithFormat:@"AVAPIs %@", [Camera getAVAPIsVersion]]];
    [AVAPIVer setFont:[UIFont fontWithName:@"Arial" size:14]];
    [AVAPIVer setTextAlignment:UITextAlignmentCenter];
    
    UILabel *copyright = [[UILabel alloc] initWithFrame:CGRectMake(0, 235, [[UIScreen mainScreen] bounds].size.width, 30)];
    [copyright setBackgroundColor:[UIColor clearColor]];
    [copyright setShadowColor:[UIColor whiteColor]];
    [copyright setShadowOffset:CGSizeMake(0, 1)];
    [copyright setFont:[UIFont fontWithName:@"Arial" size:14]];
    //[copyright setText:NSLocalizedString(@"Copyright © 2013. All rights reserved.", @"")];
    //begin add by kongyulu at 2013-10-22
    [copyright setText:NSLocalizedString(@"Copyright", @"")];
    //end add by kongyulu at 2013-10-22
    
    [copyright setTextAlignment:UITextAlignmentCenter];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [view addSubview:appIconView];
    [view addSubview:appName];
    [view addSubview:appVer];
    //[view addSubview:fmwkVer];
    [view addSubview:IOTCVer];
    [view addSubview:AVAPIVer];
    [view addSubview:copyright];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 270;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 7, cell.bounds.size.width, 20)];
    [titleLabel setText:@"Contact Us"];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    
    
    UILabel *detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 23, cell.bounds.size.width, 20)];
    [detailTextLabel setText:@"Have question?"];
    [detailTextLabel setTextAlignment:UITextAlignmentCenter];
    [detailTextLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
    [detailTextLabel setTextColor:[UIColor lightGrayColor]];
    [detailTextLabel setBackgroundColor:[UIColor clearColor]];
    
    [cell addSubview:titleLabel];
    [cell addSubview:detailTextLabel];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
