//
//  YLEventDetailListController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/9/16.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLEventDetailListController.h"
#import "CustomPeriodEventSearchController.h"
#import "Event.h"
#import "DDBadgeViewCell.h"
#import "YLSDCardVideoController.h"
#import "iToast.h"

@interface YLEventDetailListController ()<MyCameraDelegate, UIActionSheetDelegate, UICustomPeriodEventSearchControllerDelegate> {
    
    UIBarButtonItem *searchButton;
    UIActivityIndicatorView *indicator;
    NSMutableArray *event_list;
    BOOL isSearchingEvent;
}




@end

@implementation YLEventDetailListController

- (void)searchEventFrom:(STimeDay)start To:(STimeDay)stop {
    
    if (isSearchingEvent) return;
    
    isSearchingEvent = true;
    
    [event_list removeAllObjects];
    [self.tableView reloadData];
    [self showLoading];
    
    SMsgAVIoctrlListEventReq *req = (SMsgAVIoctrlListEventReq *) malloc(sizeof(SMsgAVIoctrlListEventReq));
    memset(req, 0, sizeof(SMsgAVIoctrlListEventReq));
    
    req->channel = 0;
    req->event = 0;
    req->stStartTime = start;
    req->stEndTime = stop;
    
    [searchButton setEnabled:NO];
    [self.camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_LISTEVENT_REQ Data:(char *)req DataSize:sizeof(SMsgAVIoctrlListEventReq)];
    
    free(req);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 180 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        if (isSearchingEvent) {
            
            isSearchingEvent = false;
            [searchButton setEnabled:YES];
            [self stopLoading];
        }
    });
}

- (double)getTimeInMillis:(STimeDay)time {
    
    double result;
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setYear:time.year];
    [comps setMonth:time.month];
    [comps setWeekday:time.wday];
    [comps setDay:time.day];
    [comps setHour:time.hour];
    [comps setMinute:time.minute];
    [comps setSecond:time.second];
    
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [cal setLocale:[NSLocale currentLocale]];
    
    NSDate *date = [cal dateFromComponents:comps];
    
    result = [date timeIntervalSince1970];
    
    [cal release];
    [comps release];
    
    return result;
}

- (IBAction)search:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc]
                             initWithTitle:nil
                             delegate:self
                             cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
                             destructiveButtonTitle:nil
                             otherButtonTitles:NSLocalizedString(@"Within an hour", @""),
                             NSLocalizedString(@"Within half a day", @""),
                             NSLocalizedString(@"Within a day", @""),
                             NSLocalizedString(@"Within a week", @""),
                             NSLocalizedString(@"Custom period", @""), nil];
    
    [action showInView:self.view];
    [action release];
}

- (IBAction)back:(id)sender
{
    [self.camera clearRemoteNotifications];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)refresh
{
    STimeDay start, stop;
    NSDate *now = [NSDate date];
    NSDate *past = [NSDate dateWithTimeIntervalSinceNow:-43200];
    
    start = [Event getTimeDay:[past timeIntervalSince1970]];
    stop = [Event getTimeDay:[now timeIntervalSince1970]];
    
    [self searchEventFrom:start To:stop];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifndef MacGulp
    self.navigationItem.title = NSLocalizedString(@"Event List", @"") ;
#else
    self.title = camera.name;
#endif
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Back", @"")
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(back:)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    [backButton release];
    
    searchButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search", nil) style:UIBarButtonItemStyleDone target:self action:@selector(search:)];
    NSArray* toolbarItems = [NSArray arrayWithObjects: searchButton, nil];
    [toolbarItems makeObjectsPerformSelector:@selector(release)];
    self.toolbarItems = toolbarItems;
    
    isSearchingEvent = false;
    
    event_list = [[NSMutableArray alloc] init];
    
    if (self.camera != nil) {
        
#ifndef MacGulp
        self.navigationItem.prompt = self.camera.name;
#endif
        
        STimeDay start, stop;
        NSDate *now = [NSDate date];
        NSDate *past = [NSDate dateWithTimeIntervalSinceNow:-43200];
        
        start = [Event getTimeDay:[past timeIntervalSince1970]];
        stop = [Event getTimeDay:[now timeIntervalSince1970]];
        
        [self searchEventFrom:start To:stop];
    }
}

- (void)viewDidUnload {
    
    event_list = nil;
    self.camera = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.camera != nil)
        self.camera.delegate2 = self;
    
    self.navigationController.toolbarHidden = NO;
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [event_list release];
    [_camera release];
    [super dealloc];
}

#pragma mark - Table DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [event_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *EventListCell = @"EventListCell";
    
#ifndef MacGulp
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:EventListCell];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle
                 reuseIdentifier:EventListCell] autorelease];
    }
    // Configure the cell
    NSUInteger row = [indexPath row];
    
    if (isSearchingEvent) {
        
        //cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.textLabel.text = NSLocalizedString(@"Searching...", @"");
        
    } else {
        
        if ([event_list count] == 0) {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = NSLocalizedString(@"No result found", @"");
            
        } else {
            
            Event *evt = [event_list objectAtIndex:row];
            
            if ([self.camera getPlaybackSupportOfChannel:0] && evt.eventStatus != EVENT_NORECORD)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            
            if (evt.eventStatus == EVENT_UNREADED)
                cell.textLabel.textColor = [UIColor blackColor];
            else if (evt.eventStatus == EVENT_READED)
                cell.textLabel.textColor = [UIColor grayColor];
            else
                cell.textLabel.textColor = [UIColor lightGrayColor];
            
            cell.textLabel.text = [Event getEventTypeName:evt.eventType];
            
            
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:evt.eventTime];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
            
            [dateFormatter release];
            [date release];
        }
    }
    
    return cell;
#else
    
    DDBadgeViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:EventListCell];
    
    if (cell == nil) {
        
        cell = [[[DDBadgeViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle
                 reuseIdentifier:EventListCell] autorelease];
    }
    
    // Configure the cell
    NSUInteger row = [indexPath row];
    
    Event *evt = [event_list objectAtIndex:row];
    
    if ([camera getPlaybackSupportOfChannel:0] && evt.eventStatus != EVENT_NORECORD)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (evt.eventStatus == EVENT_UNREADED) {
        cell.badgeText = [NSString stringWithFormat:@" "];
        cell.badgeColor = [UIColor redColor];
        cell.badgeHighlightedColor = [UIColor lightGrayColor];
    }
    else {
        cell.badgeText = nil;
        cell.badgeColor = [UIColor clearColor];
        cell.badgeHighlightedColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = [Event getEventTypeName:evt.eventType];
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:evt.eventTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    [date release];
    
    return cell;
#endif
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *evt = [event_list objectAtIndex:[indexPath row]];
    
    if (![self.camera getPlaybackSupportOfChannel:0] || evt.eventStatus == EVENT_NORECORD)
        return;
    else
        evt.eventStatus = EVENT_READED;
    
#ifndef MacGulp
    YLSDCardVideoController *controller = [[YLSDCardVideoController alloc] init];
#else
//    CameraPlaybackController *controller = [[CameraPlaybackController alloc] initWithNibName:@"MacGulpCameraPlayback" bundle:nil];
     YLSDCardVideoController *controller = [[YLSDCardVideoController alloc] init];
#endif
    controller.camera = _camera;
    //need to open 20170918
    controller.event = [event_list objectAtIndex:[indexPath row]];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size
{
    if (type == IOTYPE_USER_IPCAM_LISTEVENT_RESP) {
        
        SMsgAVIoctrlListEventResp *s = (SMsgAVIoctrlListEventResp *)data ;
        
        if (s->total == 0) {
            [[iToast makeText:NSLocalizedString(@"No result found", nil)] show];
            isSearchingEvent = false;
            [searchButton setEnabled:YES];
            [self stopLoading];
            return;
        }
        
        if (s->count > 0) {
            
            for (int i = 0; i < s->count; i++) {
                
                SAvEvent saEvt = s->stEvent[i];
                
                double timeInMillis = [self getTimeInMillis:saEvt.stTime];
                
                NSLog(@"<<< Get Event(%d): %d/%d/%d %d:%2d:%2d (%f)", saEvt.status, saEvt.stTime.year, saEvt.stTime.month, saEvt.stTime.day, (int)saEvt.stTime.hour, (int)saEvt.stTime.minute, (int)saEvt.stTime.second, timeInMillis);
                
                Event *evt = [[Event alloc] initWithEventType:saEvt.event EventTime:[self getTimeInMillis:saEvt.stTime] EventStatus:saEvt.status];
                
                [event_list addObject:evt];
                [evt release];
            }
        }
        
        isSearchingEvent = false;
        [searchButton setEnabled:YES];
        [self stopLoading];
        [self.tableView reloadData];
    }
}

#pragma mark - ActionSheet Delegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    STimeDay start, stop;
    NSDate *now = [NSDate date];
    NSDate *from = [NSDate date];
    
    if (buttonIndex == 0) {
        
        from = [NSDate dateWithTimeIntervalSinceNow:- (60 * 60)];
        start = [Event getTimeDay:[from timeIntervalSince1970]];
        stop = [Event getTimeDay:[now timeIntervalSince1970]];
        
        [self searchEventFrom:start To:stop];
    }
    else if (buttonIndex == 1) {
        
        from = [NSDate dateWithTimeIntervalSinceNow:- (60 * 60 * 12)];
        start = [Event getTimeDay:[from timeIntervalSince1970]];
        stop = [Event getTimeDay:[now timeIntervalSince1970]];
        
        [self searchEventFrom:start To:stop];
    }
    else if (buttonIndex == 2) {
        
        from = [NSDate dateWithTimeIntervalSinceNow:- (60 * 60 * 24)];
        start = [Event getTimeDay:[from timeIntervalSince1970]];
        stop = [Event getTimeDay:[now timeIntervalSince1970]];
        
        [self searchEventFrom:start To:stop];
    }
    else if (buttonIndex == 3) {
        
        from = [NSDate dateWithTimeIntervalSinceNow:- (60 * 60 * 24 * 7)];
        start = [Event getTimeDay:[from timeIntervalSince1970]];
        stop = [Event getTimeDay:[now timeIntervalSince1970]];
        
        [self searchEventFrom:start To:stop];
    }
    else if (buttonIndex == 4) {
        
        CustomPeriodEventSearchController *modalView = [[CustomPeriodEventSearchController alloc] initWithNibName:@"CustomPeriodEventSearchController" bundle:nil];
        modalView.usageMode = UIUsageMode_OneWay;
        modalView.delegate = self;
        [self presentViewController:modalView animated:YES completion:nil];
        [modalView release];
        
        self.navigationController.toolbarHidden = NO;
    }
}

#pragma mark - UICustomPeriodEventSearchControllerDelegate
-(void)customPeriodChanged:(NSDate*)from dateTo:(NSDate*)to; {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mma"];
    
    NSLog( @"todo search %@ ~ %@", [dateFormatter stringFromDate:from], [dateFormatter stringFromDate:to] );
    
    [dateFormatter release];
    
    STimeDay start, stop;
    
    start = [Event getTimeDay:[from timeIntervalSince1970]];
    stop = [Event getTimeDay:[to timeIntervalSince1970]];
    
    [self searchEventFrom:start To:stop];
}

@end
