//
//  YLEventListController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLEventListController.h"
#import "DDBadgeViewCell.h"
#import "YLEventDetailListController.h"

@interface YLEventListController ()<UITableViewDelegate,UITableViewDataSource,CameraDelegate, MyCameraDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation YLEventListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *) dataList
{
    if(_dataList == nil)
    {
        self.dataList = [YLGlobal shareInstance].cameraArr;
    }
    return _dataList;
}


- (void) initUI
{
    self.tableView.opaque = YES;
    self.tableView.backgroundView = nil;
    self.navigationItem.title = NSLocalizedString(@"Events", nil);
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for(MyCamera *camera in self.dataList)
        camera.delegate2 = self;
    
    NSLog(@"CameraListForEventController - set camera delegate");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? [self.dataList count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat gHeight = 5;
    return gHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sTitle = nil;
    return sTitle;
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat gHeight = 1;
    return gHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CameraListCellIdentifier = @"DDBadgeViewCell";
    DDBadgeViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CameraListCellIdentifier];
    
    if (cell == nil) {
        
        cell = [[DDBadgeViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle
                 reuseIdentifier:CameraListCellIdentifier];
    }
    
    // Configure the cell
    NSUInteger row = [indexPath row];
    
    MyCamera *camera = [self.dataList objectAtIndex:row];
    
    cell.textLabel.text = camera.name;
    cell.detailTextLabel.text = camera.uid;
    
    NSInteger cnt = camera.remoteNotifications;
    
    if (cnt > 0) {
        cell.badgeText = [NSString stringWithFormat:@"%zd", cnt];
        cell.badgeColor = [UIColor redColor];
        cell.badgeHighlightedColor = [UIColor lightGrayColor];
    }
    else {
        cell.badgeText = nil;
        cell.badgeColor = [UIColor clearColor];
        cell.badgeHighlightedColor = [UIColor clearColor];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //end modified by kongyulu at 2014-1-15
    return cell;
}

#pragma mark - TableView Delegate Methods

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    MyCamera *camera = [[YLGlobal shareInstance].cameraArr objectAtIndex:row];
    
    if (camera != NULL) {
        
        YLEventDetailListController *controller = [[YLEventDetailListController alloc] initWithStyle:UITableViewStylePlain];
        controller.camera = [self.dataList objectAtIndex:[indexPath row]];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera _didReceiveRemoteNotification:(NSInteger)eventType EventTime:(long)eventTime
{
    self.tabBarItem.badgeValue = @"!";
}

- (void)camera:(MyCamera *)camera _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    if (!self.tableView.editing)
        [self.tableView reloadData];
}


@end
