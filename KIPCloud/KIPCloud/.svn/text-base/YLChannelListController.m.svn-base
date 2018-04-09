//
//  YLChannelListController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLChannelListController.h"

@interface YLChannelListController ()

@end

@implementation YLChannelListController
-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Channels", @"")];
    self.navigationItem.title = title;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - TableView DataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_camera.getSupportedStreams count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:cellIdentifier];
    }
    NSInteger row = [indexPath row];
    SubStream_t ch;
    NSValue *val = [[_camera getSupportedStreams] objectAtIndex:row];
    if (strcmp([val objCType], @encode(SubStream_t)) == 0)
        [val getValue:&ch];
    cell.textLabel.text = [NSString stringWithFormat:@"CH%d", ch.channel + 1];
    cell.accessoryType = row == _selectedChannel ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SubStream_t ch;
    NSValue *val = [[_camera getSupportedStreams] objectAtIndex:[indexPath row]];
    if (strcmp([val objCType], @encode(SubStream_t)) == 0)
        [val getValue:&ch];
    
    //[self.delegate didChannelSelected:ch.channel];
    if(_delegate && [_delegate respondsToSelector:@selector(YLChannelListControllerDelegate_didChannelChanged:)])
    {
        [_delegate YLChannelListControllerDelegate_didChannelChanged:ch.channel];
    }
}

@end
