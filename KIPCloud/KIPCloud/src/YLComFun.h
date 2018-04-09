//
//  YLComFun.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/5.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLComFun : NSObject

+(BOOL)pingServer;
+(BOOL)isExistenceNetwork;
+ (NSString *) pathForDocumentsResource:(NSString *) relativePath;
+ (CGRect)getScreenSize:(BOOL)isNavigation isHorizontal:(BOOL)isHorizontal;
+ (NSInteger) getTickTime;
+ (UIImage *) getUIImage:(char *)buff Width:(NSInteger)width Height:(NSInteger)height;
+ (BOOL)saveImageToFile:(UIImage *)image fileName:(NSString *)fileName ;
@end
