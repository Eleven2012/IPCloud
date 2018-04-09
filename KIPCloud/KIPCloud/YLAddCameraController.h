//
//  YLAddCameraController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLAddCameraController : YLBaseController
@property (assign, nonatomic) BOOL bAddCameraPage;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *did;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) MyCamera *camera;

@end
