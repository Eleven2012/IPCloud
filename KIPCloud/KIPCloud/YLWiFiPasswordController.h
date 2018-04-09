//
//  YLWiFiPasswordController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLWiFiPasswordControllerDelegate <NSObject>

@optional
-(void) YLWiFiPasswordControllerDelegate_didSetFinished:(id) userInfo ssid:(NSString *) ssid;

@end

@interface YLWiFiPasswordController : YLBaseTableViewController
@property (nonatomic, strong) MyCamera *camera;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *password;
@property (nonatomic,assign) NSInteger ssid_length;
@property (nonatomic,assign) NSInteger mode;
@property (nonatomic,assign) NSInteger enctype;
@property (nonatomic, weak) id<YLWiFiPasswordControllerDelegate> delegate;
@end
