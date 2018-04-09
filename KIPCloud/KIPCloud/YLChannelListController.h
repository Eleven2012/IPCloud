//
//  YLChannelListController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLChannelListControllerDelegate <NSObject>

@optional
-(void) YLChannelListControllerDelegate_didChannelChanged:(NSInteger) nIndex;

@end

@interface YLChannelListController : YLBaseTableViewController

@property(weak, nonatomic) id<YLChannelListControllerDelegate> delegate;
@property (nonatomic, strong) MyCamera *camera;
@property (nonatomic, assign) NSInteger selectedChannel;

@end
