//
//  YLPhotoListController.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/24.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLPhotoListController.h"
#import <QuartzCore/QuartzCore.h>
#import "YLCollectionPhotoItemView.h"
#import "YLCollectionPhotoGroupView.h"
#import "YLSnapPicInfo.h"
#import "YLSnapPicGroupInfo.h"

@interface YLPhotoListController ()<UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,YLCollectionPhotoItemViewDelegate,YLCollectionPhotoGroupViewDelegate>
{
    BOOL editMode;
    int nColNum;
}


@property (nonatomic, retain) UICollectionView *collectionView;
//内容数组
@property (nonatomic, retain) NSMutableArray *dataArray;


@end

@implementation YLPhotoListController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void) initData
{
    [super initData];
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataArray = nil;
}

-(void) initUI
{
    [super initUI];
    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Snapshot", @"")];
    self.navigationItem.title = title;
    
    [self initCollectionView];

}

-(void) initCollectionView
{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    //指定布局方式为垂直
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumLineSpacing = 3;//最小行间距(当垂直布局时是行间距，当水平布局时可以理解为列间距)
    flow.minimumInteritemSpacing = 2;//两个单元格之间的最小间距
    
    //创建CollectionView并指定布局对象
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 180)collectionViewLayout:flow];
    _collectionView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:239/255.0f alpha:1.0];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self.view addSubview:_collectionView];
    
    //注册用xib定制的cell，各参数的含义同UITableViewCell的注册
    [_collectionView registerNib:[UINib nibWithNibName:@"YLCollectionPhotoItemView" bundle:nil] forCellWithReuseIdentifier:@"YLCollectionPhotoItemView"];
    
    //注册用xib定制的分组脚
    //参数二：用来区分是分组头还是分组脚
    [_collectionView registerNib:[UINib nibWithNibName:@"YLCollectionPhotoGroupView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YLCollectionPhotoGroupView"];
}

-(void) initBarButton
{
    [super initBarButton];
    
    UIBarButtonItem *rightNavBar =[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar_finish"] style:UIBarButtonItemStylePlain target:self action:@selector(btnBarRightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightNavBar;
    
}


-(void) btnBarRightButtonClicked:(id) sender
{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:3];
        YLSnapPicGroupInfo *item = [[YLSnapPicGroupInfo alloc] init];
        item.groupName = NSLocalizedString(@"Image",  nil);
        item.bChecked = NO;
        item.uid = self.camera.uid;
        item.listItem = [[YLGlobal shareInstance] getAllPhotos:item.uid];
        _dataArray = [NSMutableArray arrayWithObjects:
                         item,
                         nil];
    }
    return _dataArray;
}



#pragma mark Collection data call back

//协议的方法,用于返回section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _dataArray.count;
}

//协议中的方法，用于返回分区中的单元格个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    YLSnapPicGroupInfo *groupInfo = [_dataArray objectAtIndex:section];
    if (groupInfo && groupInfo.bChecked) {
        //如果是打开状态
        count = [groupInfo.listItem count];
    }
    
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //UICollectionViewCell里的属性非常少，实际做项目的时候几乎必须以其为基类定制自己的Cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YLCollectionPhotoGroupView" forIndexPath:indexPath];
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    YLCollectionPhotoItemView *cell0 = (YLCollectionPhotoItemView *)cell;
    YLSnapPicGroupInfo *groupInfo = [_dataArray objectAtIndex:section];
    YLSnapPicInfo *itemInfo  = [groupInfo.listItem objectAtIndex:row];
    cell0.section = section;
    cell0.row = row;
    cell0.data = itemInfo;

    return cell;
}






//协议中的方法，用于返回单元格的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat fWidth = self.view.frame.size.width /nColNum;
    return CGSizeMake(fWidth-2, fWidth-2);
}

//协议中的方法，用于返回整个CollectionView上、左、下、右距四边的间距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //上、左、下、右的边距
    return UIEdgeInsetsMake(0, 1, 0, 1);
}

//协议中的方法，用来返回分组头的大小。如果不实现这个方法，- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath将不会被调用
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    //宽度随便定，系统会自动取collectionView的宽度
    //高度为分组头的高度
    CGFloat rowHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 54:44);
    return CGSizeMake(0, rowHeight);
}


//协议中的方法，用来返回CollectionView的分组头或者分组脚
//参数二：用来区分是分组头还是分组脚
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //重用分组头，因为前边注册过，所以重用一定会成功
    //参数一：用来区分是分组头还是分组脚
    //参数二：注册分组头时指定的ID
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"YLCollectionPhotoGroupView" forIndexPath:indexPath];
    YLCollectionPhotoGroupView *cellHeader = (YLCollectionPhotoGroupView *)header;
    
    YLSnapPicGroupInfo *groupInfo = [self.dataArray objectAtIndex:section];
    cellHeader.section = section;
    cellHeader.row = row;
    cellHeader.delegate = self;
    cellHeader.data = groupInfo;
    return header;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    NSArray *arr = [_dataArray objectAtIndex:section];
    //GroupCollectionCell *cell = ( GroupCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark GroupCollectionCellDelegate

-(void) YLCollectionPhotoItemViewDelegate_didBtnClicked:(id)sender userInfo:(id)userInfo buttonType:(int)type
{
    YLCollectionPhotoItemView *view = (YLCollectionPhotoItemView *)userInfo;
    NSInteger section = view.section;
    YLSnapPicInfo *picInfo = view.data;
    if(type == 0)
    {
        //点击选中按钮
    }
    else if(type == 1){
        //点击内容图片按钮
        [self gotoThePictureShowPage:picInfo];
    }
}

-(void) YLCollectionPhotoGroupViewDelegate_didButtonClicked:(id)sender userInfo:(id)userInfo buttonType:(int)type
{
    YLCollectionPhotoGroupView *view = (YLCollectionPhotoGroupView *)userInfo;
    NSInteger section = view.section;
    if(type == YLCollectionPhotoGroupViewButtonType_Arrow)
    {
        
    }
    else if(type == YLCollectionPhotoGroupViewButtonType_Title){
        
    }
    else if(type == YLCollectionPhotoGroupViewButtonType_SelectAll){
        [self selectAllSectionItem:section];
    }
    else if(type == YLCollectionPhotoGroupViewButtonType_UnSelectAll){
        [self unSelectAllSectionItem:section];
    }
    else if(type == YLCollectionPhotoGroupViewButtonType_Icon){
        
    }
}

- (void) updateTheSectionArrowStatus:(NSInteger) section
{
    YLSnapPicGroupInfo *groupInfo = [_dataArray objectAtIndex:section];
    if(groupInfo.bChecked)
    {
        groupInfo.bChecked = NO;
    }
    else{
        groupInfo.bChecked = YES;
    }
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
}

- (void) selectAllSectionItem:(NSInteger) section
{
    YLSnapPicGroupInfo *groupInfo = [_dataArray objectAtIndex:section];
    groupInfo.bChecked = YES;
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
}

- (void) unSelectAllSectionItem:(NSInteger) section
{
    YLSnapPicGroupInfo *groupInfo = [_dataArray objectAtIndex:section];
    groupInfo.bChecked = NO;
    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
}


-(void) gotoThePictureShowPage:(id) userInfo
{
    
}

@end
