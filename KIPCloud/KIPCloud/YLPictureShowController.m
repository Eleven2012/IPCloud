//
//  YLPictureShowController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/27.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLPictureShowController.h"
#import <MessageUI/MessageUI.h>
#import "YLSnapPicInfo.h"
#define HIDE_NAVIGATION_BAR_TIME_OUT	5
#define NAVIGATION_BAR_HEIGHT_PORTRAIT	44
#define NAVIGATION_BAR_HEIGHT_LANDSCAPE	32
#define SHARE_ACTION_SHEET_TAG  1
#define DELETE_ACTION_SHEET_TAG 2

@interface YLPictureShowController ()<UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {

}


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (assign, nonatomic) NSInteger currentPage;
@property (strong, nonatomic) NSTimer *hideNavigationBarTimer;
@property (strong, nonatomic) UIImageView *mainImageView;

@end

@implementation YLPictureShowController

-(void) dealloc
{
    self.camera = nil;
    [self.hideNavigationBarTimer invalidate];
    self.hideNavigationBarTimer = nil;
}

-(NSMutableArray *) photoArray
{
    if(_photoArray == nil)
    {
        _photoArray = [[NSMutableArray alloc] initWithArray:[[YLGlobal shareInstance] getAllPhotos:_camera.uid]];
    }
    return _photoArray;
}

-(NSTimer *) hideNavigationBarTimer
{
    if(_hideNavigationBarTimer == nil)
    {
        _hideNavigationBarTimer =[NSTimer scheduledTimerWithTimeInterval:HIDE_NAVIGATION_BAR_TIME_OUT target:self selector:@selector(hideNavigationBarAndToolBar) userInfo:nil repeats:NO];
    }
    return _hideNavigationBarTimer;
}

-(void) initData
{
    [super initData];
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Picture", @"")];
    self.navigationItem.title = title;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    [self.scrollView addGestureRecognizer:singleFingerTap];

#if 0
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showDeleteAlert)] autorelease];
#else
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
#endif
    [self viewPhotoWithFileName:self.photoFileName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (void)hideNavigationBarAndToolBar {

    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
    {
        
    }
    else
    {
        if (NO == self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            //[self adjustTabBarWithOrientation:[UIApplication sharedApplication].statusBarOrientation hide:YES];
        }
        
    }
    //end add by kongyulu at 20140321
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    if (aScrollView.tag == 1) {
        return self.mainImageView;
    }
    return nil;
}

-(NSInteger) getIndexOfPic:(NSString*) fileName
{
    NSInteger nIndex = 0;
    for (NSInteger i=0; i< [self.photoArray count]; i++) {
        YLSnapPicInfo *picInfo = [self.photoArray objectAtIndex:i];
        if([fileName isEqualToString:picInfo.fileName])
        {
            return i;
        }
    }
    return nIndex;
}

- (void)viewPhotoWithFileName:(NSString *)filename {
    self.photoFileName = filename;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGRect imageRect;
    
    NSInteger mainIndex = [self getIndexOfPic:self.photoFileName];
    NSNumber *index = nil;
    
    CGRect rect = self.view.frame;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        imageRect = CGRectMake(0, 0, rect.size.height, rect.size.width-20);
        
    }else {
        imageRect = CGRectMake(0, 0, rect.size.width, rect.size.height-20);
    }

    if (mainIndex<0) {
        return;
    }
    if (self.photoArray.count<=0) {
        self.scrollView.contentSize = CGSizeMake(imageRect.origin.x+imageRect.size.width, imageRect.size.height-44-49/*49 is the height of tab bar*/);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imageRect.origin.x, imageRect.origin.y, imageRect.size.width, imageRect.size.height)];
        imgView.image = [UIImage imageNamed:@"NoPhotoAvailable.png"];
        [self.scrollView addSubview:imgView];
        return;
    }
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<3; i++) {
        if (1==i) {
            index = [NSNumber numberWithInteger:mainIndex];
        }else if (self.photoArray.count>1)
        {
            index = [NSNumber numberWithInteger:(mainIndex + self.photoArray.count + i-1)% self.photoArray.count];
        }else {
            index = [NSNumber numberWithInt:-1];
        }
        
        [indexArray addObject:index];
    }
    
    for (UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
    
    int page=0;
    for (index in indexArray) {
        if ([index intValue]<0) {
            continue;
        }
        
        UIScrollView *subScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(imageRect.size.width*page, imageRect.origin.y, imageRect.size.width, imageRect.size.height)];
        if ([index intValue]==mainIndex) {
            subScrollView.backgroundColor = [UIColor blackColor];
        }else {
            subScrollView.backgroundColor = [UIColor blackColor];
        }
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imageRect.origin.x+10, imageRect.origin.y, imageRect.size.width-10*2, imageRect.size.height)] ;
        NSString *strPath = self.albumPath;
        YLSnapPicInfo *item = [self.photoArray objectAtIndex:[index intValue]];
        if(item == nil)
        {
            continue;
        }
        strPath = [strPath stringByAppendingPathComponent:item.fileName];
        
        imgView.image = [UIImage imageWithContentsOfFile:strPath];
        //imgView.layer.borderColor = [UIColor blackColor].CGColor;
        //imgView.layer.borderWidth = 1.0;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        if ([index intValue]==mainIndex) {
            self.mainImageView = imgView;
            subScrollView.tag = 1;
            subScrollView.contentSize = imageRect.size;
            subScrollView.maximumZoomScale = 4.0;
            subScrollView.minimumZoomScale = 1.0;
            subScrollView.clipsToBounds = YES;
            subScrollView.scrollEnabled = YES;
            subScrollView.showsVerticalScrollIndicator = NO;
            subScrollView.showsHorizontalScrollIndicator = NO;
            //subScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
            subScrollView.delegate = self;
        }

        [subScrollView addSubview:imgView];
        [self.scrollView addSubview:subScrollView];
        page++;
    }
    self.scrollView.contentSize = CGSizeMake(imageRect.size.width*page, imageRect.size.height-44-49);
    
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.scrollView scrollRectToVisible:CGRectMake(imageRect.size.width, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:NO];
    self.currentPage = _scrollView.contentOffset.x / _scrollView.frame.size.width;
    
}



- (void)viewNextPhoto {
    [self.hideNavigationBarTimer invalidate];
    self.hideNavigationBarTimer = nil;
    
    if (self.photoArray.count>1) {
        NSInteger index = [self getIndexOfPic:self.photoFileName];//[self.photoArray indexOfObject:self.photoFileName];
        //NSString *nextFileName = [self.photoArray objectAtIndex:(index+1)%self.photoArray.count];
        YLSnapPicInfo *picInfo = [self.photoArray objectAtIndex:(index+1)%self.photoArray.count];
        if(picInfo == nil)
        {
            return;
        }
        NSString *nextFileName = picInfo.fileName;
        if ([nextFileName isEqualToString:self.photoFileName]) {
            nextFileName = nil;
        }
        [self viewPhotoWithFileName:nextFileName];
    }
}

- (void)viewPreviousPhoto {
    //NSLog(@"viewPreviousPhoto");
    [self.hideNavigationBarTimer invalidate];
    self.hideNavigationBarTimer = nil;
    
    if (self.photoArray.count>1) {
        NSInteger index = [self getIndexOfPic:self.photoFileName];//[self.photoArray indexOfObject:self.photoFileName];
        
        YLSnapPicInfo *picInfo = [self.photoArray objectAtIndex:(index+self.photoArray.count-1)%self.photoArray.count];
        if(picInfo == nil)
        {
            return;
        }
        NSString *nextFileName = picInfo.fileName;
        if ([nextFileName isEqualToString:self.photoFileName]) {
            nextFileName = nil;
        }
        [self viewPhotoWithFileName:nextFileName];
    }
}
// MFMailComposeViewControllerDelegate Begin
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the Drafts folder");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
            break;
        default:
            NSLog(@"Mail not sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}
// MFMailComposeViewControllerDelegate End

- (void)emailPhoto {
    if ([MFMailComposeViewController canSendMail]) {
        NSString *extension = [[[self.photoFileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSData *attachmentData = nil;
        [mailer setSubject:[NSString stringWithFormat:@"Photo - %@",self.photoFileName]];
        if ([extension isEqualToString:@"png"]) {
            attachmentData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:[self.albumPath stringByAppendingPathComponent:self.photoFileName]]);
        }else {
            attachmentData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:[self.albumPath stringByAppendingPathComponent:self.photoFileName]], 1.0);
        }
        
        [mailer addAttachmentData:attachmentData mimeType:[NSString stringWithFormat:@"image/%@",extension] fileName:self.photoFileName];
        [mailer setMessageBody:[NSString stringWithString:[NSString stringWithFormat:@"Photo - %@",self.photoFileName]] isHTML:NO];
        [self presentModalViewController:mailer animated:YES];

    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your email account is disabled or removed, please check your email account.",nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        alert.tag = 1;
        alert.delegate = self;
        [alert show];
    }
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{

}



- (BOOL)deleteSnapshotRecords:(NSString *)fileName {
    BOOL bOK= [[YLGlobal shareInstance] deleteSnapshotRecordWithFileName:fileName];
    if(bOK)
    {
        
    }
    return bOK;
}

- (void)savePhotoToCameraRoll {
    NSString * filePath = [self.albumPath stringByAppendingPathComponent:self.photoFileName];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    UIImageWriteToSavedPhotosAlbum(image, self,
                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)deletePhoto {
    
    NSInteger index = [self getIndexOfPic:self.photoFileName];//[self.photoArray indexOfObject:self.photoFileName];
    YLSnapPicInfo *picInfo = [self.photoArray objectAtIndex:(index+1)%self.photoArray.count];
    if(picInfo == nil)
    {
        return;
    }
    NSString *nextFileName = picInfo.fileName;
    if ([nextFileName isEqualToString:self.photoFileName]) {
        nextFileName = nil;
    }
    [self deleteSnapshotRecords:self.photoFileName];
    [self.photoArray removeObjectAtIndex:index];
    
    if ([self.photoArray count] > 0)
        [self viewPhotoWithFileName:nextFileName];
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (alertView.tag == 0) {
                // delete this photo
                [self deletePhoto];
            }
            break;
        default:
            break;
    }
}
- (void) showDeleteAlert {
    UIAlertView *alert = nil;
    if (self.photoArray.count<=0) {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Photo Available",nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil),nil];
        alert.tag = 1;
    }else {
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete?",nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil),NSLocalizedString(@"Cancel",nil),nil];
        alert.tag = 0;
    }
    alert.delegate = self;
    [alert show];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (SHARE_ACTION_SHEET_TAG == actionSheet.tag) {
        switch (buttonIndex) {
            case 0:
                [self showDeleteAlert];
                break;
            case 1:
                [self emailPhoto];
                break;
            case 2:
                [self savePhotoToCameraRoll];
                break;
            default:
                break;
        }
        
    }else if (DELETE_ACTION_SHEET_TAG == actionSheet.tag) {
        switch (buttonIndex) {
            case 0:
                [self showDeleteAlert];
                break;
                
            default:
                break;
        }
    }
}
- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                    otherButtonTitles: NSLocalizedString(@"Delete Photo",nil),
                                  NSLocalizedString(@"Email Photo",nil),
                                  NSLocalizedString(@"Save Photo", nil),
                                  NSLocalizedString(@"Cancel",nil), nil];
    actionSheet.tag = SHARE_ACTION_SHEET_TAG;
    actionSheet.delegate = self;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.destructiveButtonIndex = 0;	// make the 1st button red (destructive)
    [actionSheet showFromTabBar:self.tabBarController.tabBar];

}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    if (aScrollView.tag == 1) {
        return;
    }
    [self hideNavigationBarAndToolBar];
    NSInteger pageMargin = aScrollView.contentOffset.x / aScrollView.frame.size.width - self.currentPage;
    //NSLog(@"TEST pageMargin = %d",pageMargin);
    if (pageMargin>0) {
        NSInteger index = [self getIndexOfPic:self.photoFileName];
        index = (index + self.photoArray.count+1)%self.photoArray.count;
        YLSnapPicInfo *picInfo = [self.photoArray objectAtIndex:index];
        if(picInfo == nil)
        {
            return;
        }
        [self viewPhotoWithFileName:picInfo.fileName];
        //[self viewPhotoWithFileName:[self.photoArray objectAtIndex:([self.photoArray indexOfObject:self.photoFileName]+self.photoArray.count+1)%self.photoArray.count]];
    }else if (pageMargin<0) {
        NSInteger index = [self getIndexOfPic:self.photoFileName];
        index = (index + self.photoArray.count-1)%self.photoArray.count;
        YLSnapPicInfo *picInfo = [self.photoArray objectAtIndex:index];
        if(picInfo == nil)
        {
            return;
        }
        [self viewPhotoWithFileName:picInfo.fileName];
        //[self viewPhotoWithFileName:[self.photoArray objectAtIndex:([self.photoArray indexOfObject:self.photoFileName]+self.photoArray.count-1)%self.photoArray.count]];
    }
}


- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    //NSLog(@"Single tap");
    if (NO == self.navigationController.navigationBarHidden) {
        [self.hideNavigationBarTimer invalidate];
        self.hideNavigationBarTimer = nil;
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self adjustTabBarWithOrientation:[UIApplication sharedApplication].statusBarOrientation hide:YES];
    }else {
        [self.hideNavigationBarTimer invalidate];
        self.hideNavigationBarTimer = nil;
        
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self adjustTabBarWithOrientation:[UIApplication sharedApplication].statusBarOrientation hide:NO];
    }
}

- (void)adjustTabBarWithOrientation:(UIInterfaceOrientation)orientation hide:(BOOL)yesOrNo {
//    UIView *transView = [self.tabBarController.view.subviews objectAtIndex:0];
//    UIView *tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
    
}


- (void) backToPreviousView {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    //[self viewPhotoWithFileName:self.photoFileName];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self viewPhotoWithFileName:self.photoFileName];
}



@end
