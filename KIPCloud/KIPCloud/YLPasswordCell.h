//
//  YLPasswordCell.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/19.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLPasswordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPwd;
@property (weak, nonatomic) IBOutlet UIButton *btnShowPwd;

-(void) showPwd:(BOOL) bShow;


@end
