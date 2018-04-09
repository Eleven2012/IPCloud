//
//  UIColor+hexColor.m
//  ZJOL
//
//  Created by Peter Jin (https://github.com/JxbSir) on  15/1/6.
//
//  Created by kong yulu on 5/28/15.
//  Copyright (c) 2015 itcast. All rights reserved.
//

#import "UIColor+hexColor.h"

@implementation UIColor (hexColor)

+ (UIColor *)hexFloatColor:(NSString *)hexStr {
    if (hexStr.length < 6)
        return nil;
    
    unsigned int red_, green_, blue_;
    NSRange exceptionRange;
    exceptionRange.length = 2;
    
    //red
    exceptionRange.location = 0;
    [[NSScanner scannerWithString:[hexStr substringWithRange:exceptionRange]]scanHexInt:&red_];
    
    //green
    exceptionRange.location = 2;
    [[NSScanner scannerWithString:[hexStr substringWithRange:exceptionRange]]scanHexInt:&green_];
    
    //blue
    exceptionRange.location = 4;
    [[NSScanner scannerWithString:[hexStr substringWithRange:exceptionRange]]scanHexInt:&blue_];
    
    UIColor *resultColor = RGB(red_, green_, blue_);
    return resultColor;
}


@end
