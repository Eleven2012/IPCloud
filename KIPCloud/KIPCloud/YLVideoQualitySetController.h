//
//  YLVideoQualitySetController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YLVideoQualitySetControllerDelegate <NSObject>

@optional
-(void) YLVideoQualitySetControllerDelegate_didSetFinished:(NSInteger) value;

@end

@interface YLVideoQualitySetController : YLBaseTableViewController
@property (nonatomic, strong) MyCamera *camera;
@property (nonatomic, weak) id<YLVideoQualitySetControllerDelegate> delegate;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@end
