//
//  YLCommonActivityCell.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/20.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLCommonActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDetail;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
