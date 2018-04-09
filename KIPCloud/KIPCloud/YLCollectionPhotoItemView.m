//
//  YLCollectionPhotoItemView.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLCollectionPhotoItemView.h"

@implementation YLCollectionPhotoItemView
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
    if (_data.bChecked) {
        [_btnIcon setImage:[UIImage imageNamed:@"thumbnailCheckMark"] forState:UIControlStateNormal];
    }
    else{
        [_btnIcon setImage:[UIImage imageNamed:@"thumbnailCheckMark_unCheck"] forState:UIControlStateNormal];
    }
    NSString *strFile  = [YLComFun pathForDocumentsResource:_data.fileName];
    UIImage *imageContent = [UIImage imageWithContentsOfFile:strFile];
    [_btnContent setImage:imageContent forState:UIControlStateNormal];
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

- (IBAction)btnContentClicked:(id)sender {

    if(_delegate && [_delegate respondsToSelector:@selector(YLCollectionPhotoItemViewDelegate_didBtnClicked:userInfo:buttonType:)])
    {
        [_delegate YLCollectionPhotoItemViewDelegate_didBtnClicked:sender userInfo:sender buttonType:1];
    }
}

- (IBAction)btnIconClicked:(id)sender {
    if(_delegate && [_delegate respondsToSelector:@selector(YLCollectionPhotoItemViewDelegate_didBtnClicked:userInfo:buttonType:)])
    {
        [_delegate YLCollectionPhotoItemViewDelegate_didBtnClicked:sender userInfo:sender buttonType:0];
    }
}

@end
