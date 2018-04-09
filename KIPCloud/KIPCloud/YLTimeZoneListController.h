//
//  YLTimeZoneListController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLTimeZoneListControllerDelegate <NSObject>
@optional
- (void) YLTimeZoneListControllerDelegate_didSelectItem:(id) item;

@end



@class YLTimeZoneInfo;
@interface YLTimeZoneListController : YLBaseTableViewController
{
    
}
@property (copy, nonatomic) YLTimeZoneInfo *curTimeZone;
@property (nonatomic,weak) id<YLTimeZoneListControllerDelegate> delegate;
@property (nonatomic, strong) MyCamera *camera;

@end
