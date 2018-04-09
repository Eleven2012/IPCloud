//
//  YLEventSearchController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/9/16.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol YLEventSearchControllerDelegate <NSObject>

@optional
-(void)YLEventSearchControllerDelegate_customPeriodChanged:(NSDate*)from dateTo:(NSDate*)to;

@end



@interface YLEventSearchController : YLBaseController

@end
