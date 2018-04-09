//
//  CustomPeriodEventSearchController.h
//  MultiViewStoryboard
//
//  Created by Gavin Chang on 13/4/17.
//  Copyright (c) 2013年 張嘉文. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, UICustomPeriodEventSearchUsageMode) {
    UIUsageMode_OneWay,
    UIUsageMode_TwoWay
};

typedef NS_ENUM(NSInteger, UICustomPeriodEventSearchModeStatus) {
    UIModeStatus_AllPickerHidden,
    UIModeStatus_DatePicker,
    UIModeStatus_TimePicker,
	UIModeStatus_DateTimePicker
};

@protocol UICustomPeriodEventSearchControllerDelegate

@required
-(void)customPeriodChanged:(NSDate*)from dateTo:(NSDate*)to;

@end

@interface CustomPeriodEventSearchController : UIViewController<UINavigationBarDelegate,UITableViewDataSource, UITableViewDelegate> {
		
	id<UICustomPeriodEventSearchControllerDelegate> delegate;
	
	UINavigationBar* nvBarMain;
	UINavigationBar* nvBarPicker;
	NSDateFormatter* dateFormatter;
	NSDate* dateFrom;
	NSDate* dateTo;
	
	UICustomPeriodEventSearchModeStatus nUiMode;
	int nPickerSaveToIdx;

	UIDatePicker *datePickerView;
	
	UICustomPeriodEventSearchUsageMode usageMode;
}

@property (nonatomic, assign) id<UICustomPeriodEventSearchControllerDelegate> delegate;

@property (nonatomic, retain) UINavigationBar* nvBarMain;
@property (nonatomic, retain) UINavigationBar* nvBarPicker;
@property (nonatomic, retain) NSDateFormatter* dateFormatter;
@property (nonatomic, retain) NSDate* dateFrom;
@property (nonatomic, retain) NSDate* dateTo;
@property (nonatomic, assign) UICustomPeriodEventSearchModeStatus nUiMode;
@property (nonatomic, assign) int nPickerSaveToIdx;
@property (nonatomic, retain) UIDatePicker *datePickerView;
@property (nonatomic, assign) IBOutlet NSLayoutConstraint *mtv1HeightConstraint;
@property (nonatomic, assign) IBOutlet UITableView *tv1;

@property (nonatomic, assign) UICustomPeriodEventSearchUsageMode usageMode;

- (IBAction)nvBtnSearch:(id)sender;
- (IBAction)nvBtnDone:(id)sender;
- (void)createDatePicker;
- (void)showPicker:(NSString*)title setAsDate:(NSDate*)date;
- (void)updateCellDetailLabrl:(NSDate*)newVal;
- (void)reLayout;

@end
