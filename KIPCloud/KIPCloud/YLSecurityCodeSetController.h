//
//  YLSecurityCodeSetController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLSecurityCodeSetControllerDelegate <NSObject>

@optional
-(void) YLSecurityCodeSetController_savePasswordSucceed:(NSString *) sNewPwd;


@end

@interface YLSecurityCodeSetController : YLBaseTableViewController
@property (strong, nonatomic) NSString *sOldPwd;
@property (strong, nonatomic) NSString *sNewPwd;
@property (strong, nonatomic) NSString *sConfirmPwd;
@property (nonatomic, strong) MyCamera *camera;

@property (nonatomic, weak) id<YLSecurityCodeSetControllerDelegate> delegate;
@end
