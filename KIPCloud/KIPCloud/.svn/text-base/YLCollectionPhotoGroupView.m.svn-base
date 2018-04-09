//
//  YLCollectionPhotoGroupView.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLCollectionPhotoGroupView.h"

@implementation YLCollectionPhotoGroupView

-(void) dealloc
{
    [self removeKVO];
}

-(void) registerKVO
{
    [self addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) removeKVO
{
    [self removeObserver:self forKeyPath:@"data"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"data"]) {
        [self updataUI];
    }
}

-(void) updataUI
{
    if(_data.bChecked)
    {
        [_btnArrow setImage:[UIImage imageNamed:@"popoverArrowDown"] forState:UIControlStateNormal];
    }
    else
    {
        [_btnArrow setImage:[UIImage imageNamed:@"popoverArrowRight"] forState:UIControlStateNormal];
    }
    [_btnSelectAll setImage:[UIImage imageNamed:@"selectAll"] forState:UIControlStateNormal];
    [_btnUnSelectAll setImage:[UIImage imageNamed:@"unselectAll"] forState:UIControlStateNormal];

}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self updataUI];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self registerKVO];
}





- (IBAction)btnArrowClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(YLCollectionPhotoGroupViewDelegate_didButtonClicked:userInfo:buttonType:)])
    {
        [_delegate YLCollectionPhotoGroupViewDelegate_didButtonClicked:sender userInfo:sender buttonType:YLCollectionPhotoGroupViewButtonType_Arrow];
    }
}
- (IBAction)btnTitleClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(YLCollectionPhotoGroupViewDelegate_didButtonClicked:userInfo:buttonType:)])
    {
        [_delegate YLCollectionPhotoGroupViewDelegate_didButtonClicked:sender userInfo:sender buttonType:YLCollectionPhotoGroupViewButtonType_Title];
    }
}
- (IBAction)btnSelectAllClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(YLCollectionPhotoGroupViewDelegate_didButtonClicked:userInfo:buttonType:)])
    {
        [_delegate YLCollectionPhotoGroupViewDelegate_didButtonClicked:sender userInfo:sender buttonType:YLCollectionPhotoGroupViewButtonType_SelectAll];
    }
}
- (IBAction)btnUnselectAllClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(YLCollectionPhotoGroupViewDelegate_didButtonClicked:userInfo:buttonType:)])
    {
        [_delegate YLCollectionPhotoGroupViewDelegate_didButtonClicked:sender userInfo:sender buttonType:YLCollectionPhotoGroupViewButtonType_UnSelectAll];
    }
}
- (IBAction)btnIconClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(YLCollectionPhotoGroupViewDelegate_didButtonClicked:userInfo:buttonType:)])
    {
        [_delegate YLCollectionPhotoGroupViewDelegate_didButtonClicked:sender userInfo:sender buttonType:YLCollectionPhotoGroupViewButtonType_Icon];
    }
}

@end
