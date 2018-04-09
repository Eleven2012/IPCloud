//
//  YLGlobal.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface YLGlobal : NSObject
{
    
}

@property (strong, nonatomic)  NSMutableArray *cameraArr;
@property (strong, nonatomic)  FMDatabase *database;
@property (copy, nonatomic)  NSString *deviceTokenString;

+(YLGlobal *)shareInstance;

-(void) disConnectAllCamera;
-(void) closeDB;

- (BOOL) addCamera:(YLDeviceInfo *) device;
-(BOOL) isExistDevice:(NSString *) uid;
- (BOOL) updateCamera:(YLDeviceInfo *) device;
-(MyCamera *) getCamera:(NSString *) uid;

//更新分辨率
-(BOOL) updateCameraReso:(int) nReso uid:(NSString*) uid;


- (void)deleteCamera:(NSString *)uid ;
- (BOOL)deleteSnapshotRecords:(NSString *)uid ;
- (BOOL)deleteSnapshotRecordWithFileName:(NSString *)fileName;

//photo info
-(NSMutableArray *) getAllPhotos:(NSString *)uid;
-(BOOL) deletePhoto:(NSString *) fileName;
-(BOOL) saveOneSnapImage:(UIImage *) img  fileName:(NSString *) fileName cameraUID:(NSString *) uid;
- (NSInteger) getVideoQuality:(NSString*) uid;


@end
