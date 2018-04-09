//
//  YLSnapPicGroupInfo.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLSnapPicGroupInfo.h"
#import "YLSnapPicInfo.h"

@implementation YLSnapPicGroupInfo


-(void) setBChecked:(BOOL)bChecked
{
    _bChecked = bChecked;
    for (YLSnapPicInfo *item in _listItem) {
        item.bChecked = bChecked;
    }
}

@end
