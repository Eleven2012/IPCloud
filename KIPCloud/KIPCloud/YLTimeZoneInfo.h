//
//  YLTimeZoneInfo.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/20.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLTimeZoneInfo : NSObject

@property (strong, nonatomic) NSString *sDescribe;
@property (strong, nonatomic) NSString *sDiffGMT;
@property (assign, nonatomic) NSInteger nGMTMins;

@end
