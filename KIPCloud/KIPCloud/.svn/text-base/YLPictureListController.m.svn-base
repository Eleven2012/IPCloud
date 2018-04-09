//
//  YLPictureListController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/27.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLPictureListController.h"
#import "YLPictureShowController.h"
#import "YLImageButtonHorCell.h"
#import "YLImageButtonVerCell.h"
#import "YLSnapPicInfo.h"

@interface YLPictureListController ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL editMode;
}

@property (strong, nonatomic) NSMutableArray *dataList;
@property (strong, nonatomic) NSMutableArray *checkedList;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemSelectAll;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemReserveAll;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barItemDelete;

@end

@implementation YLPictureListController
-(void) initData
{
    [super initData];
    _dataList = nil;
    _checkedList = nil;
    editMode = NO;
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Pictures", @"")];
    self.navigationItem.title = title;
    self.tableView.separatorColor=[UIColor lightGrayColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 79;
    
}

-(void) initBarButton
{
    [super initBarButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(switchEditMode)];
    self.toolBar.hidden = YES;
    self.checkedList = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataList = nil;
    self.checkedList = nil;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) btnBarLeftButtonClicked:(id)sender
{
    [super btnBarLeftButtonClicked:sender];
}

-(void) btnBarRightButtonClicked:(id)sender
{
    
}
- (IBAction)barItemSelectAllClicked:(id)sender {
    [self selectAllItems];
}
- (IBAction)barItemReserveAllClicked:(id)sender {
    [self unSelectAllItems];
}
- (IBAction)barItemDeleteClicked:(id)sender {
    [self deletePhotosAlertView];
}

#pragma mark - datasource
- (NSMutableArray *) dataList{
    if (_dataList == nil) {
        NSArray *listAll = [[YLGlobal shareInstance] getAllPhotos:_camera.uid];
        _dataList = [[NSMutableArray alloc] initWithArray:listAll];
    }
    return _dataList;
}
-(NSMutableArray *) checkedList
{
    if (_checkedList == nil) {
        _checkedList = [[NSMutableArray alloc] initWithCapacity:40];
    }
    return _checkedList;
}

- (void)switchEditMode {
    editMode = !editMode;
    if (editMode) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(switchEditMode)];
        self.toolBar.hidden = NO;

    }else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(switchEditMode)];
        self.toolBar.hidden = YES;
        [self.tableView reloadData];
        self.checkedList = nil;
    }
}

#define DELETE_PHOTO_ALERT_VIEW_TAG 1
#define NO_PHOTO_TO_DELETE_ALERT_VIEW_TAG   2
- (BOOL)deletePhotoAtIndex:(NSInteger)index {
    
    YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:index];
    NSString *thumbnailFilePath = [self.directoryPath stringByAppendingPathComponent:picInfo.fileName];
    NSString *photoFileName = [[picInfo.fileName substringToIndex:14] stringByAppendingString:@".jpg"];
    NSString *photoFilePath = [self.directoryPath stringByAppendingPathComponent:photoFileName];
    
    if (YES==[[NSFileManager defaultManager] removeItemAtPath:thumbnailFilePath error:nil]) {
        if (NO == [[NSFileManager defaultManager] removeItemAtPath:photoFilePath error:nil]) {
            NSLog(@"Delete thumbnail(%zd) failed...",index);
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return NO;
}
- (void)deletePhotos {
    for (NSNumber *index in self.checkedList) {
        NSInteger row = [index integerValue];
        YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:row];
        NSString *photoFile = picInfo.fileName;
        BOOL bOK = [[YLGlobal shareInstance] deletePhoto:photoFile];
        if(bOK)
        {
            [self deletePhotoAtIndex:row];
        }
    }
}
- (void)deletePhotosAlertView {
    if (self.checkedList.count>0) {
        UIAlertView *makeSureAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete?", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil),NSLocalizedString(@"Cancel", nil), nil];
        makeSureAlertView.tag = DELETE_PHOTO_ALERT_VIEW_TAG;
        [makeSureAlertView show];
    }else {
        UIAlertView *makeSureAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please select photos to delete.", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        makeSureAlertView.tag = NO_PHOTO_TO_DELETE_ALERT_VIEW_TAG;
        [makeSureAlertView show];
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (DELETE_PHOTO_ALERT_VIEW_TAG == alertView.tag) {
        switch (buttonIndex) {
            case 0:
                [self deletePhotos];
                self.dataList = nil;
                self.checkedList = nil;
                [self.tableView reloadData];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger buttonNumberInRow = 4;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation) {
        buttonNumberInRow = 6;
    }else {
        buttonNumberInRow = 4;
    }
    NSInteger row = self.dataList.count/buttonNumberInRow+(self.dataList.count%buttonNumberInRow==0?0:1);
    return row;
}

- (void)highlightButton:(UIButton *)b {
    [b setHighlighted:YES];
}
- (void)cancelHighlightButton:(UIButton *)b {
    [b setHighlighted:NO];
}
- (void)btnPressed:(UIButton *)sender {
    if (editMode == NO) {
        
        YLPictureShowController *vc = [[YLPictureShowController alloc] init];
        vc.title = self.title;
        vc.camera = _camera;
        vc.albumPath = self.directoryPath;
        YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:sender.tag];
        vc.photoFileName = picInfo.fileName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];

    }
    else {
        
        if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:sender.tag]] == NSNotFound) {
            [sender setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
            [self.checkedList addObject:[NSNumber numberWithInteger:sender.tag]];
        }
        else {
            [sender setImage:nil forState:UIControlStateNormal];
            NSInteger checkedPhotoArrayIndex = [self.checkedList indexOfObject:[NSNumber numberWithInteger:sender.tag]];
            if (NSNotFound != checkedPhotoArrayIndex) {
                [self.checkedList removeObjectAtIndex:checkedPhotoArrayIndex];
            }
        }
    }
}

-(void) selectAllItems {
    self.checkedList = nil;
    for(int i=0; i< [self.dataList count];i++)
    {
        [self.checkedList addObject:[NSNumber numberWithInteger:i]];
    }
    [self updateTableView];
}


-(void) updateTableView
{
    [self.tableView reloadData];
}

-(void) unSelectAllItems {
    self.checkedList = nil;
    [self updateTableView];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
    {
        static NSString *CellIdentifierLanscape = @"YLImageButtonVerCell";
        YLImageButtonVerCell *cell = (YLImageButtonVerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierLanscape];
        if (cell == nil) {
            NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"YLImageButtonVerCell" owner:nil options:nil];
            for (id currentObject in nibObjects) {
                if ([currentObject isKindOfClass:[YLImageButtonHorCell class]]) {
                    cell = (YLImageButtonVerCell *)currentObject;
                }
            }
        }
        // Configure the cell...
        NSString *albumDirectoryPath = self.directoryPath;
        if (self.dataList.count>0) {
            for (int i = 0; i<6; i++) {
                if ((6*indexPath.row+i)<self.dataList.count) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor=[UIColor clearColor];
                    switch (i) {
                        case 0:
                        {
                            cell.btn1.tag = 6*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn1.tag];
                            [cell.btn1 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn1 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn1.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn1.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn1.tag]] == NSNotFound) {
                                [cell.btn1 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn1 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }
                            break;
                        case 1:
                        {
                            cell.btn2.tag = 6*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn2.tag];
                            [cell.btn2 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn2 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn2.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn2.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn2.tag]] == NSNotFound) {
                                [cell.btn2 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn2 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            break;
                        case 2:
                        {
                            cell.btn3.tag = 6*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn3.tag];
                            [cell.btn3 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn3 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn3.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn3.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn3.tag]] == NSNotFound) {
                                [cell.btn3 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn3 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            break;
                        case 3:
                        {
                            cell.btn4.tag = 6*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn4.tag];
                            [cell.btn4 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn4 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn4.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn4.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn4.tag]] == NSNotFound) {
                                [cell.btn4 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn4 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            break;
                        case 4:
                        {
                            cell.btn5.tag = 6*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn5.tag];
                            [cell.btn5 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn5 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn5.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn5.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn5.tag]] == NSNotFound) {
                                [cell.btn5 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn5 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            break;
                        case 5:
                        {
                            cell.btn6.tag = 6*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn6.tag];
                            [cell.btn6 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn6 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn6.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn6.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn6.tag]] == NSNotFound) {
                                [cell.btn6 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn6 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            break;
                        default:
                            break;
                    }
                }
            }
        }else {
            [cell.btn1 setImage:[UIImage imageNamed:@"NoPhotoAvailable.png"] forState:UIControlStateNormal];
        }
        
        return cell;
        
    }
    else
    {
        static NSString *CellIdentifier = @"YLImageButtonHorCell";
        
        YLImageButtonHorCell *cell = (YLImageButtonHorCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"YLImageButtonHorCell" owner:nil options:nil];
            for (id currentObject in nibObjects) {
                if ([currentObject isKindOfClass:[YLImageButtonHorCell class]]) {
                    cell = (YLImageButtonHorCell *)currentObject;
                }
            }
        }
        NSString *albumDirectoryPath = self.directoryPath;
        
        if (self.dataList.count>0) {
            for (int i = 0; i<4; i++) {
                if ((4*indexPath.row+i)<self.dataList.count) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor=[UIColor clearColor];
                    switch (i) {
                        case 0:
                        {
                            cell.btn1.tag = 4*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn1.tag];
                            [cell.btn1 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn1 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn1.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn1.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn1.tag]] == NSNotFound) {
                                [cell.btn1 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn1 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            
                            break;
                        case 1:
                        {
                            cell.btn2.tag = 4*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn2.tag];
                            [cell.btn2 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn2 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn2.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn2.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn2.tag]] == NSNotFound) {
                                [cell.btn2 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn2 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            break;
                        case 2:
                        {
                            cell.btn3.tag = 4*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn3.tag];
                            [cell.btn3 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn3 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn3.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn3.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn3.tag]] == NSNotFound) {
                                [cell.btn3 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn3 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            break;
                        case 3:
                        {
                            cell.btn4.tag = 4*indexPath.row+i;
                            YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:cell.btn4.tag];
                            [cell.btn4 setBackgroundImage:[UIImage imageWithContentsOfFile:[albumDirectoryPath stringByAppendingPathComponent:picInfo.fileName]] forState:UIControlStateNormal];
                            [cell.btn4 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                            cell.btn4.layer.borderColor = [UIColor blackColor].CGColor;
                            cell.btn4.layer.borderWidth = 1.0;
                            if (self.checkedList == nil || [self.checkedList indexOfObject:[NSNumber numberWithInteger:cell.btn4.tag]] == NSNotFound) {
                                [cell.btn4 setImage:nil forState:UIControlStateNormal];
                            }else {
                                [cell.btn4 setImage:[UIImage imageNamed:@"thumbnailCheckMark.png"] forState:UIControlStateNormal];
                            }
                        }

                            break;
                        default:
                            break;
                    }
                }
            }
        }else {
            [cell.btn1 setImage:[UIImage imageNamed:@"NoPhotoAvailable.png"] forState:UIControlStateNormal];
        }
        
        return cell;
    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        NSInteger row = indexPath.row;
        YLSnapPicInfo *picInfo = [self.dataList objectAtIndex:row];
        NSString *photoFile = picInfo.fileName;
        BOOL bOK = [[YLGlobal shareInstance] deletePhoto:photoFile];
        if(bOK)
        {
            [self deletePhotoAtIndex:row];
            //self.dataSource = nil;
            [self.dataList removeObjectAtIndex:row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //[self adjustEditModeToolBarUi];
    if (editMode == YES) {
        self.toolBar.hidden = NO;
    }
    [self.tableView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (editMode == YES) {
        self.toolBar.hidden = YES;
    }
}


@end
