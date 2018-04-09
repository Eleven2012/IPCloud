//
//  YLBaseController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLBaseController : UIViewController

- (void) initData;

- (void) initUI;

- (void) initBarButton;

//保存按钮点击事件
- (void) btnBarLeftButtonClicked:(id) sender;
//右侧按钮
- (void) btnBarRightButtonClicked:(id) sender;

- (void) showHUD:(NSString *) sTitle;

- (void) hideHUD;

- (void) showTips:(NSString *) sMsg;

- (void) showTips2:(NSString *) sMsg;

- (void) showWithText: (NSString*) strText superView: (UIView*) superView bLandScap:(BOOL) bLandScap;

- (void) showWithText: (NSString*) strText bLandScap:(BOOL) bLandScap;


@end
