//
//  YLEnvironmentModeController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/20.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLEnvironmentModeControllerDelegate<NSObject>

- (void)YLEnvironmentModeControllerDelegate_didSetEnvironmentMode:(NSInteger)value;

@end

@interface YLEnvironmentModeController : YLBaseTableViewController
@property (nonatomic, strong) MyCamera *camera;
@property (nonatomic, weak) id<YLEnvironmentModeControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger origValue;
@property (nonatomic, assign) NSInteger newValue;
@end
