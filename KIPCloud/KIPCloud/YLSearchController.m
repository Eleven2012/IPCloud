//
//  YLSearchController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLSearchController.h"
#import "YLDeviceInfo.h"

@interface YLSearchController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *deviceArr;
@property (nonatomic, weak) NSTimer *searchTimer;

@end

@implementation YLSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    [self btnRefresh];
}

-(void) initBarButton
{
    [super initBarButton];
    self.navigationItem.title =  NSLocalizedString(@"LAN Search",  nil);
}

- (void)handleTimer:(NSTimer *)timer
{
    NSLog(@"handleTimer");
    //time is up, invalidate the timer
    [_searchTimer invalidate];
    [self stopSearch];
    [self hideLoadingIndicator];
}

- (void) startSearch
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{//启动线程
        // Do a taks in the background

        self.deviceArr = [YLDeviceInfo getLANDevices];
        dispatch_async(dispatch_get_main_queue(), ^{ //回到主线程
            
        });
    });

    
    //create the start timer
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
}

- (void) stopSearch
{
}


- (void) btnRefresh
{
    [self showLoadingIndicator];
    [self startSearch];
}

- (void)showLoadingIndicator
{
    UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0, 0, 24, 24);
    [indicator startAnimating];
    UIBarButtonItem *progress =
    [[UIBarButtonItem alloc] initWithCustomView:indicator];
    self.navigationItem.rightBarButtonItem = progress;

}

- (void)hideLoadingIndicator
{
    UIBarButtonItem *refreshButton =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
     target:self
     action:@selector(btnRefresh)];
    self.navigationItem.rightBarButtonItem = refreshButton;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    //return 1;
    return [_deviceArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CameraListCell = @"CameraListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CameraListCell];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CameraListCell];
    }
    
    // Configure the cell
    NSUInteger row = [indexPath row];
    YLDeviceInfo *dev = [_deviceArr objectAtIndex:row];
    cell.textLabel.text = dev.uid;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = dev.ip;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.imageView.image = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_articalList.png"]];
    
    return cell;
}

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    YLDeviceInfo *dev = [_deviceArr objectAtIndex:row];
    if(_delegate && [_delegate respondsToSelector:@selector(lanSearchController:didSearchResult:ip:port:)])
    {
        [self.delegate lanSearchController:self didSearchResult:dev.uid ip:dev.ip port:dev.port];
    }
}



@end
