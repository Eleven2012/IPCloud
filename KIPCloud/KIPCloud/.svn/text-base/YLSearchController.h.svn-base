//
//  YLSearchController.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YLSearchControllerDelegate<NSObject>

@optional
- (void) lanSearchController:(id)controller
             didSearchResult:(NSString *)uid
                          ip:(NSString *)ip
                        port:(NSInteger)port;

@end

@interface YLSearchController : YLBaseTableViewController

@property (nonatomic, weak) id<YLSearchControllerDelegate> delegate;

@end
