//
//  YLPictureShowController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/27.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLPictureShowController : YLBaseController
@property (nonatomic,strong) NSString *albumPath;
@property (nonatomic,strong) NSString *photoFileName;
@property (nonatomic, strong) Camera *camera;
@end
