//
//  YLQRScanView.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/7.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLQRScanViewDelegate <NSObject>

@optional

-(void) YLQRScanView_scanSucceed:(NSString *) str;

@end

@interface YLQRScanView : UIView

@property (weak, nonatomic) id<YLQRScanViewDelegate> delegate;

@end
