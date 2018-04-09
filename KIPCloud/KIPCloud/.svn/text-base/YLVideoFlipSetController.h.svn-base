//
//  YLVideoFlipSetController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/17.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol YLVideoFlipSetControllerDelegate <NSObject>

@optional
-(void) YLVideoFlipSetControllerDelegate_didSetFinished:(NSInteger) value;
@end

@interface YLVideoFlipSetController : YLBaseTableViewController
@property (nonatomic, strong) MyCamera *camera;
@property (nonatomic, weak) id<YLVideoFlipSetControllerDelegate> delegate;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@end
