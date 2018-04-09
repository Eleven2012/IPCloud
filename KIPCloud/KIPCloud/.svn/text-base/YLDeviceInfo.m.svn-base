//
//  YLDeviceInfo.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLDeviceInfo.h"

@implementation YLDeviceInfo

-(id) initWithDevice:(YLDeviceInfo *) other
{
    self = [self init];
    if(self)
    {
        self.uid = other.uid;
        self.ip = other.ip;
        self.dev_nickname = other.dev_nickname;
        self.view_acc = other.view_acc;
        self.view_pwd = other.view_pwd;
        self.dev_name = other.dev_name;
        self.dev_pwd = other.dev_pwd;
        self.resolution = other.resolution;
        self.port = other.port;
        self.channel = other.channel;
    }
    
    return self;
}

+ (NSArray *) getLANDevices
{
    NSMutableArray *deviceArr = [[NSMutableArray alloc] initWithCapacity:10];
    int num, k;
    LanSearch_t *pLanSearchAll = [Camera LanSearch:&num timeout:2000];
    if(pLanSearchAll == nil) return nil;
    printf("num[%d]\n", num);
    
    for(k = 0; k < num; k++) {
        
        printf("UID[%s]\n", pLanSearchAll[k].UID);
        printf("IP[%s]\n", pLanSearchAll[k].IP);
        printf("PORT[%d]\n", pLanSearchAll[k].port);
        YLDeviceInfo *dev = [[YLDeviceInfo alloc] init];
        dev.uid = [NSString stringWithFormat:@"%s", pLanSearchAll[k].UID];
        dev.ip = [NSString stringWithFormat:@"%s", pLanSearchAll[k].IP];
        dev.port = pLanSearchAll[k].port;
        [deviceArr addObject:dev];
    }
    
    if(pLanSearchAll != NULL) {
        free(pLanSearchAll);
    }
    return  deviceArr;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        self.view_acc = @"admin";
        self.channel = 0;
        self.resolution = DEF_VideoQualityValue;
    }
    return self;
}

@end
