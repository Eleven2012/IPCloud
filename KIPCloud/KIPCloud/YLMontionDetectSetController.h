//
//  YLMontionDetectSetController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLMontionDetectSetControllerDelegate <NSObject>

@optional
-(void) YLMontionDetectSetControllerDelegate_didSetMontionDetectFinished:(NSInteger) value;

@end

@interface YLMontionDetectSetController : YLBaseTableViewController
@property (nonatomic, strong) MyCamera *camera;
@property (nonatomic, weak) id<YLMontionDetectSetControllerDelegate> delegate;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@end
