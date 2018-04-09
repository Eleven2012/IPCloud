//
//  YLRecordModeSetController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YLRecordModeSetControllerDelegate <NSObject>

@optional
-(void) YLRecordModeSetControllerDelegate_didRecordModeSetFinished:(NSInteger) value;


@end

@interface YLRecordModeSetController : YLBaseTableViewController
@property (nonatomic, strong) MyCamera *camera;
@property (nonatomic, weak) id<YLRecordModeSetControllerDelegate> delegate;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@end
