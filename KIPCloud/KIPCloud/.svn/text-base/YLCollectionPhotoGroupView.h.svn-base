//
//  YLCollectionPhotoGroupView.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLSnapPicGroupInfo.h"
@protocol YLCollectionPhotoGroupViewDelegate <NSObject>

@optional

- (void) YLCollectionPhotoGroupViewDelegate_didButtonClicked:(id) sender userInfo:(id) userInfo buttonType:(int) type;

@end


enum YLCollectionPhotoGroupViewButtonType
{
    YLCollectionPhotoGroupViewButtonType_Arrow = 0,
    YLCollectionPhotoGroupViewButtonType_Title ,
    YLCollectionPhotoGroupViewButtonType_SelectAll ,
    YLCollectionPhotoGroupViewButtonType_UnSelectAll ,
    YLCollectionPhotoGroupViewButtonType_Icon ,
};

@interface YLCollectionPhotoGroupView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIButton *btnArrow;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectAll;
@property (weak, nonatomic) IBOutlet UIButton *btnUnSelectAll;
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnIcon;
@property (assign, nonatomic) NSInteger section;
@property (assign, nonatomic) NSInteger row;
@property (strong, nonatomic) YLSnapPicGroupInfo *data;

@property (weak, nonatomic) id<YLCollectionPhotoGroupViewDelegate> delegate;

@property (assign, nonatomic) BOOL bChecked;
@end
