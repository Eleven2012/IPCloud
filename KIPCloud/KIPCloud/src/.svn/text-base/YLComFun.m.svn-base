//
//  YLComFun.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/5.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLComFun.h"
#import <sys/time.h>
#import "Reachability.h"

@implementation YLComFun
+(BOOL)pingServer
{
    NSURL *url = [NSURL URLWithString:@"http://push.iotcplatform.com"];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response error:NULL];
    return (response != nil);
}

+(BOOL)isExistenceNetwork
{
    BOOL isExistenceNetwork = FALSE;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    if (r == nil) {
        return FALSE;
    }
    
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=FALSE;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=TRUE;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=TRUE;
            break;
    }
    
    return isExistenceNetwork;
}

+ (NSString *) pathForDocumentsResource:(NSString *) relativePath
{
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [dirs objectAtIndex:0];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

+(CGRect)getScreenSize:(BOOL)isNavigation isHorizontal:(BOOL)isHorizontal{
    CGRect rect = [UIScreen mainScreen].bounds;
    
    if(isHorizontal){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);
    }
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0){
        rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-20);
    }
    return rect;
}


+ (NSInteger) getTickTime
{
    struct timeval tv;
    if (gettimeofday(&tv, NULL) != 0)
        return 0;
    return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

+ (UIImage *) getUIImage:(char *)buff Width:(NSInteger)width Height:(NSInteger)height
{
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buff, width * height * 3, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(width, height, 8, 24, width * 3, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, true,  kCGRenderingIntentDefault);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    if (imgRef != nil) {
        CGImageRelease(imgRef);
        imgRef = nil;
    }
    if (colorSpace != nil) {
        CGColorSpaceRelease(colorSpace);
        colorSpace = nil;
    }
    if (provider != nil) {
        CGDataProviderRelease(provider);
        provider = nil;
    }
    return [img copy];
}


+ (BOOL)saveImageToFile:(UIImage *)image fileName:(NSString *)fileName {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *imgFullName = [self pathForDocumentsResource:fileName];
    return [imgData writeToFile:imgFullName atomically:YES];
}



@end
