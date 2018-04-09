//
//  YLPasswordCell.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/19.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLPasswordCell.h"
@interface YLPasswordCell()
@property (assign, nonatomic) BOOL bShowPwd;
@end

@implementation YLPasswordCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)btnShowPwdClicked:(id)sender {
    [self showPwd:!_btnShowPwd];
}

-(void) showPwd:(BOOL)bShow
{
    if(bShow)
    {
        [_btnShowPwd setImage:[UIImage imageNamed:@"password_on"] forState:UIControlStateNormal];
        _textFieldPwd.secureTextEntry = NO;
    }
    else{
        [_btnShowPwd setImage:[UIImage imageNamed:@"password_off"] forState:UIControlStateNormal];
        _textFieldPwd.secureTextEntry = YES;
    }
    self.bShowPwd = bShow;
}

@end
