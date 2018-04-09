//
//  UIColor+hexColor.h
//  ZJOL
//
//  Created by kong yulu on 5/28/15.
//  Copyright (c) 2015 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define RGB(r,g,b) [UIColor colorWithRed:r/255. green:g/255. blue:b/255. alpha:1.]

@interface UIColor (hexColor)

+ (UIColor *)hexFloatColor:(NSString *)hexStr;

@end
