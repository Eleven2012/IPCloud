//
//  CustomPeriodEventSearchController.m
//  MultiViewStoryboard
//
//  Created by Gavin Chang on 13/4/17.
//  Copyright (c) 2013年 張嘉文. All rights reserved.
//

#import "CustomPeriodEventSearchController.h"


static NSString *kCellIdentifier = @"DateTimeTableCell";
#define kPickerAnimationDuration 0.40

@interface CustomPeriodEventSearchController ()

@end

@implementation CustomPeriodEventSearchController

@synthesize delegate;
@synthesize dateFormatter, dateFrom, dateTo, nvBarMain, nvBarPicker, usageMode, nPickerSaveToIdx, nUiMode, datePickerView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	NSTimeInterval secondsPerDay = 24 * 60 * 60;
	dateFrom = [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
	dateTo = [[NSDate alloc] init];
	
    self.dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.dateFormatter setDateFormat:@"YYYY/MM/dd hh:mma"];
		
	self.nPickerSaveToIdx = -1;
	self.nUiMode = UIModeStatus_AllPickerHidden;
	
	// UINavigationBar for ModalDialog
	//
	nvBarMain = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
	nvBarMain.delegate = self;
	
    UINavigationItem *backItem = [[UINavigationItem alloc]
                                   initWithTitle:NSLocalizedString(@"Cancel", @"")];
	//UINavigationController* navCtl = (UINavigationController*)self.parentViewController;
	//[navCtl.navigationBar pushNavigationItem:backItem animated:NO];
	[nvBarMain pushNavigationItem:backItem animated:NO];
	[backItem release];
	
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Search Period", @"")];
	[nvBarMain pushNavigationItem:topItem animated:NO];
	topItem.leftBarButtonItem = nil;
	
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Search", @"")
                                   style:UIBarButtonItemStyleDone
                                   target:self action:@selector(nvBtnSearch:)];
	topItem.rightBarButtonItem = searchButton;
	[topItem release];
	
	[self.view addSubview:nvBarMain];
	
	[self createDatePicker];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self reLayout];
	
	[self.view needsUpdateConstraints];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
	[self reLayout];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reLayout {
	
	CGSize srnSize = [UIScreen mainScreen].bounds.size;
	NSLog( @"screen:{%d,%d}", (int)(srnSize.width), (int)(srnSize.height) );
	
	int nSrnWidth = (int)srnSize.width;
	int nSrnHeight = (int)srnSize.height;
	
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((UIInterfaceOrientationLandscapeLeft == orientation) ||
        (UIInterfaceOrientationLandscapeRight == orientation)) {
		
		nSrnWidth = (int)srnSize.height;
		nSrnHeight = (int)srnSize.width;
    }

	self.nvBarMain.frame = CGRectMake(0, 0, nSrnWidth, 44);
	if( self.nvBarPicker )
		self.nvBarPicker.frame = CGRectMake(0, 0, nSrnWidth, 44);
	if( self.datePickerView && self.datePickerView.frame.size.width > nSrnWidth ) {
		self.datePickerView.frame = CGRectMake(0, 0, nSrnWidth, self.datePickerView.frame.size.height);
	}
	self.mtv1HeightConstraint.constant = nSrnHeight - 44;
}

- (IBAction)nvBtnSearch:(id)sender {
    NSLog( @"nvBtnSearch!!!" );
	
	[self.delegate customPeriodChanged:self.dateFrom dateTo:self.dateTo];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateCellDetailLabrl:(NSDate*)newVal {
	
	UITableViewCell *cellSel = [self.tv1 cellForRowAtIndexPath:[self.tv1 indexPathForSelectedRow]];
	switch( self.nPickerSaveToIdx ) {
		case 0: {
			
			self.dateFrom = newVal;
			
			cellSel.detailTextLabel.text = [self.dateFormatter stringFromDate:dateFrom];
			
			if( self.nUiMode==UIModeStatus_DateTimePicker ) {
				NSLog( @"From DateTime changed %@", cellSel.detailTextLabel.text );
			}
			else {
				NSLog( @"From %@ changed %@", (self.nUiMode==UIModeStatus_DatePicker)?@"\"Data\"":@"\"Time\"", cellSel.detailTextLabel.text );
			}
		}	break;
		case 1: {

			self.dateTo = newVal;
			
			cellSel.detailTextLabel.text = [self.dateFormatter stringFromDate:dateTo];
			
			if( self.nUiMode==UIModeStatus_DateTimePicker ) {
				NSLog( @"To DateTime changed %@", cellSel.detailTextLabel.text );
			}
			else {
				NSLog( @"To %@ changed %@", (self.nUiMode==UIModeStatus_DatePicker)?@"\"Data\"":@"\"Time\"", cellSel.detailTextLabel.text );
			}
		}	break;
	}
	
}

- (IBAction)nvBtnDone:(id)sender {
    
    CGRect pickerFrame = self.datePickerView.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
	
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kPickerAnimationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
    self.datePickerView.frame = pickerFrame;
    [UIView commitAnimations];
	
	nvBarPicker.hidden = YES;
	
	switch( self.nUiMode ) {
		case UIModeStatus_AllPickerHidden: {
		}	break;
		case UIModeStatus_DatePicker: {
			
			[self updateCellDetailLabrl:self.datePickerView.date];

			self.nUiMode = UIModeStatus_TimePicker;
			switch( self.nPickerSaveToIdx ) {
				case 0: {
					NSLog( @"Continue to choose From Time - %@", [self.dateFormatter stringFromDate:self.dateFrom] );
					[self showPicker:NSLocalizedString(@"Begin Time", @"") setAsDate:self.dateFrom];
				}	break;
				case 1: {
					NSLog( @"Continue to choose From Time - %@", [self.dateFormatter stringFromDate:self.dateTo] );
					[self showPicker:NSLocalizedString(@"End Time", @"") setAsDate:self.dateTo];
				}	break;
			}
			
		}	break;
		case UIModeStatus_DateTimePicker:
		case UIModeStatus_TimePicker: {

			[self updateCellDetailLabrl:self.datePickerView.date];
			
			self.nUiMode = UIModeStatus_AllPickerHidden;
			// deselect the current table row
			NSIndexPath *indexPath = [self.tv1 indexPathForSelectedRow];
			[self.tv1 deselectRowAtIndexPath:indexPath animated:YES];
			self.nPickerSaveToIdx = -1;
		}	break;
	}
	
}

- (void)showPicker:(NSString*)title setAsDate:(NSDate*)date {
	
	[self reLayout];
	CGRect startFrame = self.datePickerView.frame;
	CGRect endFrame = self.datePickerView.frame;
	
	int nOriginY = self.view.frame.size.height;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((UIInterfaceOrientationLandscapeLeft == orientation) ||
        (UIInterfaceOrientationLandscapeRight == orientation)) {
		
		nOriginY = self.view.frame.size.width;
    }
	// the start position is below the bottom of the visible frame
	startFrame.origin.y = nOriginY;
	
	// the end position is slid up by the height of the view
	endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
	
	self.datePickerView.frame = startFrame;
    if (self.datePickerView.superview == nil)
    {
        [self.view addSubview:self.datePickerView];
	}
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kPickerAnimationDuration];
	self.datePickerView.frame = endFrame;
	[UIView commitAnimations];
	
	if( !nvBarPicker ) {
		// UINavigationBar for DateTimerPicker
		//
		nvBarPicker = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
		nvBarPicker.delegate = self;
		
		UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:title];
		[nvBarPicker pushNavigationItem:topItem animated:NO];
		topItem.leftBarButtonItem = nil;
		
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
									   initWithTitle:NSLocalizedString(@"Done", @"")
									   style:UIBarButtonItemStyleDone
									   target:self action:@selector(nvBtnDone:)];
		topItem.rightBarButtonItem = doneButton;
		[topItem release];
		
		[self.view addSubview:nvBarPicker];		
		[self reLayout];
	}
	else {
		nvBarPicker.topItem.title = title;
		nvBarPicker.hidden = NO;
	}
	
	switch(nUiMode) {
		case UIModeStatus_DatePicker: {			
			datePickerView.datePickerMode = UIDatePickerModeDate;
		}	break;
		case UIModeStatus_TimePicker: {
			datePickerView.datePickerMode = UIDatePickerModeTime;
		}	break;
		case UIModeStatus_DateTimePicker: {
			datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
		}	break;
		default: {
			
		}	break;
	}
	datePickerView.date = date;
	datePickerView.hidden = NO;
	
	//[self.tv1 deselectRowAtIndexPath:[self.tv1 indexPathForSelectedRow] animated:YES];
}

- (void)createDatePicker {

	datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	datePickerView.datePickerMode = UIDatePickerModeDate;

}

#pragma mark - UINavigationBarDelegate
//- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
//	
//	return YES;
//}
//- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
//	NSLog( @"UINavigationBarDelegate::didPushItem" );
//}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
	
	switch( self.nUiMode ) {
		case UIModeStatus_AllPickerHidden: {
			[self dismissViewControllerAnimated:YES completion:nil];
		}	break;
		case UIModeStatus_DatePicker: {
			
		}	break;
		case UIModeStatus_TimePicker: {
			
		}	break;
		case UIModeStatus_DateTimePicker: {
			
		}	break;
	}
	return NO;
}
//- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
//	NSLog( @"UINavigationBarDelegate::didPopItem" );
//}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if(!cell) {
        cell = [[[UITableViewCell alloc]
				initWithStyle:UITableViewCellStyleValue1
				reuseIdentifier:kCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	switch( indexPath.row ) {
		case 0: {
		
			cell.textLabel.text = NSLocalizedString(@"Begin Time", @"");
			cell.detailTextLabel.text = [self.dateFormatter stringFromDate:dateFrom];
			
		}	break;
		case 1: {
			
			cell.textLabel.text = NSLocalizedString(@"End Time", @"");
			cell.detailTextLabel.text = [self.dateFormatter stringFromDate:dateTo];
			
		}	break;
	}
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	return nil;
//}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(6_0) {
	return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if( self.nPickerSaveToIdx != -1 )
		return nil;
	
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if( self.nPickerSaveToIdx != indexPath.row ) {
		self.nPickerSaveToIdx = indexPath.row;
		
		switch( self.nUiMode ) {
			case UIModeStatus_AllPickerHidden: {
				
				if( self.usageMode == UIUsageMode_OneWay ) {
					self.nUiMode = UIModeStatus_DateTimePicker;
					switch( self.nPickerSaveToIdx ) {
						case 0: {
							NSLog( @"Begin to choose From DateTime - %@", [self.dateFormatter stringFromDate:self.dateFrom] );
							[self showPicker:NSLocalizedString(@"Begin Time", @"") setAsDate:self.dateFrom];
						}	break;
						case 1: {
							NSLog( @"Begin to choose To DateTime - %@", [self.dateFormatter stringFromDate:self.dateTo] );
							[self showPicker:NSLocalizedString(@"End Time", @"") setAsDate:self.dateTo];
						}	break;
					}
				}
				else {					
					self.nUiMode = UIModeStatus_DatePicker;
					switch( self.nPickerSaveToIdx ) {
						case 0: {
							NSLog( @"Begin to choose From Date - %@", [self.dateFormatter stringFromDate:self.dateFrom] );
							[self showPicker:NSLocalizedString(@"Begin Data", @"") setAsDate:self.dateFrom];
						}	break;
						case 1: {
							NSLog( @"Begin to choose To Date - %@", [self.dateFormatter stringFromDate:self.dateTo] );
							[self showPicker:NSLocalizedString(@"End Date", @"") setAsDate:self.dateTo];
						}	break;
					}
				}
			}	break;
			case UIModeStatus_DatePicker: {
				
			}	break;
			case UIModeStatus_TimePicker: {
				
			}	break;
			case UIModeStatus_DateTimePicker: {
				
			}	break;
		}
	}
}

@end
