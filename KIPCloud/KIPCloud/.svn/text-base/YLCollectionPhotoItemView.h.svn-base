//
//  YLCollectionPhotoItemView.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLSnapPicInfo.h"

@protocol YLCollectionPhotoItemViewDelegate <NSObject>

@optional
-(void)YLCollectionPhotoItemViewDelegate_didBtnClicked:(id) sender userInfo:(id) userInfo buttonType:(int) type;

@end

@interface YLCollectionPhotoItemView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIButton *btnIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnContent;

@property (assign, nonatomic) NSInteger section;
@property (assign, nonatomic) NSInteger row;
@property (strong, nonatomic) YLSnapPicInfo *data;

@property (weak, nonatomic) id<YLCollectionPhotoItemViewDelegate> delegate;
@end
