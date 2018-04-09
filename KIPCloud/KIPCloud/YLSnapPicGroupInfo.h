//
//  YLSnapPicGroupInfo.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLSnapPicGroupInfo : NSObject
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) BOOL bChecked;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSMutableArray *listItem;
@end
