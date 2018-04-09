//
//  YLScanQRController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/7.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLScanQRControllerDelegate <NSObject>

@optional

-(void) YLScanQRController_scanSucceed:(NSString *) str;

@end

@interface YLScanQRController : YLBaseController

@property (weak, nonatomic) id<YLScanQRControllerDelegate> delegate;

@end
