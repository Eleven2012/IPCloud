//
//  YLGlobal.m
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/6.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import "YLGlobal.h"
#import "MyCamera.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "YLSnapPicGroupInfo.h"
#import "YLSnapPicInfo.h"

static YLGlobal *_instanced = NULL ;

@implementation YLGlobal

+(YLGlobal *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instanced == nil)
            _instanced = [[YLGlobal alloc] init];
    });
    return _instanced;
}


-(void) disConnectAllCamera
{
    for (Camera *camera in self.cameraArr) {
        [camera stop:0];
        [camera disconnect];
    }
}

-(void) closeDB
{
    [self closeDatabase];
}

-(BOOL) isExistDevice:(NSString *) uid;
{
    for (YLDeviceInfo *deviceItem in self.cameraArr) {
        if([uid isEqualToString:deviceItem.uid])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL) addCamera:(YLDeviceInfo *) device
{
    if(nil == device
       || [device.uid length] < 2
       || [device.dev_name length] < 1) return NO;
    

    
    NSString *UID = device.uid;
    
    BOOL bRet = NO;
    if (self.database != NULL) {
        bRet = [self.database executeUpdate:@"INSERT INTO device(dev_uid, dev_nickname, dev_name, dev_pwd, view_acc, view_pwd, channel,dev_videoQuality) VALUES(?,?,?,?,?,?,?,?)",
         UID, device.dev_nickname, device.dev_name, device.dev_pwd, device.view_acc, device.view_pwd, [NSNumber numberWithInteger:device.channel],[NSNumber numberWithInteger:device.resolution]];
        if(bRet)
        {
            //添加到数据库成功，窗口camera对象，并保持到缓存
            MyCamera *camera = [[MyCamera alloc] initWithDevice:device];
            [self.cameraArr addObject:camera];
        }
    }
    
    // register to apns server
    dispatch_queue_t queue = dispatch_queue_create("apns-reg_client", NULL);
    dispatch_async(queue, ^{
        if (self.deviceTokenString != nil) {
            NSError *error = nil;
            NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
#ifndef DEF_APNSTest
            NSString *hostString = @"http://push.iotcplatform.com/apns/apns.php";
#else
            NSString *hostString = @"http://54.225.191.150/test_gcm/apns.php"; //測試Host
#endif

#ifdef DEF_APNSTest
            NSString *argsString = @"%@?cmd=reg_mapping&token=%@&uid=%@&appid=%@";
            NSString *getURLString = [NSString stringWithFormat:argsString, hostString, self.deviceTokenString, UID, appidString];
            NSLog( @"==============================================");
            NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
            NSLog( @"==============================================");

            NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
            NSLog( @"==============================================");
            NSLog( @">>> %@", registerResult);
            NSLog( @"==============================================");
#endif
        }
    });
    
    return bRet;

}

-(MyCamera *) getCamera:(NSString *) uid
{
    for (MyCamera *item in self.cameraArr) {
        if([item.uid isEqualToString:uid])
        {
            return item;
        }
    }
    return nil;
}

- (BOOL) updateCamera:(YLDeviceInfo *) device
{
    if(nil == device
       || [device.uid length] < 2
       || [device.dev_nickname length] < 1) return NO;
    
    BOOL bRet = NO;
    if (self.database != NULL) {
        bRet = [self.database  executeUpdate:@"UPDATE device SET dev_nickname=?, dev_name=?, dev_pwd=?, view_acc=?, view_pwd=?, channel=?, dev_videoQuality=?  WHERE dev_uid=?", device.dev_nickname, device.dev_name,device.dev_pwd,device.view_acc,device.view_pwd,[NSString stringWithFormat:@"%zd", device.channel],[NSString stringWithFormat:@"%zd", device.resolution], device.uid];
        if(bRet)
        {
            //添加到数据库成功，窗口camera对象，并保持到缓存
            MyCamera *camera = [self getCamera:device.uid];
            if(camera)
            {
                [camera updateDevice:device];
            }

        }
    }
    return bRet;
}


//更新分辨率
-(BOOL) updateCameraReso:(int) nReso uid:(NSString*) uid
{
    if(uid == nil) return NO;
    BOOL bRet = NO;
    if (self.database != NULL) {
        if (![_database executeUpdate:@"UPDATE device SET dev_videoQuality=? WHERE dev_uid=?", [NSString stringWithFormat:@"%d", nReso], uid]) {
            NSLog(@"Fail to update device to database.");
        }
        else {
            NSLog(@"==================================");
            NSLog(@" videoQuality set to DB as %dL", nReso );
            NSLog(@"==================================");
            bRet = YES;
        }
    }
    return bRet;
    
}


- (void)deleteCamera:(NSString *)uid {
    
    /* delete camera lastframe snapshot file */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imgName = [NSString stringWithFormat:@"%@.jpg", uid];
    [fileManager removeItemAtPath:[YLComFun pathForDocumentsResource: imgName] error:NULL];
    
    if (_database != NULL) {
        
        if (![_database executeUpdate:@"DELETE FROM device where dev_uid=?", uid]) {
            NSLog(@"Fail to remove device from database.");
        }
    }
}

- (BOOL)deleteSnapshotRecords:(NSString *)uid {
    
    BOOL bResult = NO;
    if (_database != NULL) {
        
        FMResultSet *rs = [_database executeQuery:@"SELECT * FROM snapshot WHERE dev_id=?", uid];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        while([rs next]) {
            
            NSString *filePath = [rs stringForColumn:@"file_path"];
            [fileManager removeItemAtPath:[YLComFun pathForDocumentsResource: filePath] error:NULL];
            NSLog(@"camera(%@) snapshot removed", filePath);
            bResult = YES;
        }
        
        [rs close];
        
        [_database executeUpdate:@"DELETE FROM snapshot WHERE dev_uid=?", uid];
    }
    return bResult;
}

- (BOOL)deleteSnapshotRecordWithFileName:(NSString *)fileName {
    
    BOOL bResult = NO;
    if (_database != NULL) {
        FMResultSet *rs = [_database executeQuery:@"SELECT * FROM snapshot WHERE file_path=?", fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        while([rs next]) {
            NSString *filePath = [rs stringForColumn:@"file_path"];
            [fileManager removeItemAtPath:[YLComFun pathForDocumentsResource: filePath] error:NULL];
            NSLog(@"camera(%@) snapshot removed", filePath);
        }
        [rs close];
        [_database executeUpdate:@"DELETE FROM snapshot WHERE file_path=?", fileName];
    }
    return bResult;
}


#pragma mark property

-(NSMutableArray *) cameraArr
{
    if(_cameraArr == nil)
    {
        _cameraArr = [[NSMutableArray alloc] initWithCapacity:10];
        [self openDatabase];
        [self createTable];
        [self loadDeviceFromDatabase];
    }
    return _cameraArr;
}

-(FMDatabase *) database
{
    if(_database == nil)
    {
        NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *databaseFilePath = [[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"database.sqlite"];
        
        _database = [[FMDatabase alloc] initWithPath:databaseFilePath];
    }
    return _database;
}


#pragma mark - SQLite Methods

- (void)openDatabase
{
    if ([self.database open])
        NSLog(@"open sqlite db ok.");
}

- (void)closeDatabase
{
    [self.database close];
    NSLog(@"close sqlite db ok.");
}

- (void)createTable
{
    if (![self.database executeUpdate:SQLCMD_CREATE_TABLE_DEVICE]) NSLog(@"Can not create table device");
    if (![self.database executeUpdate:SQLCMD_CREATE_TABLE_SNAPSHOT]) NSLog(@"Can not create table snapshot");
}

- (void)loadDeviceFromDatabase {
    
    if (self.database != NULL) {
        
        //end add by kongyulu at 2013-11-13
        FMResultSet *rs = [self.database executeQuery:@"SELECT * FROM device"];
        int cnt = 0;
        
        while([rs next] && cnt++ < MAX_CAMERA_LIMIT) {
            
            NSString *uid = [rs stringForColumn:@"dev_uid"];
            NSString *name = [rs stringForColumn:@"dev_nickname"];
            NSString *view_acc = [rs stringForColumn:@"view_acc"];
            NSString *view_pwd = [rs stringForColumn:@"view_pwd"];
            NSInteger channel = [rs intForColumn:@"channel"];
            NSInteger videoQuality = [rs intForColumn:@"dev_videoQuality"];
            
            NSLog(@"Load Camera(%@, %@, %@, %@, videoQuality:%zd)", name, uid, view_acc, view_pwd, videoQuality);
            YLDeviceInfo *device = [[YLDeviceInfo alloc] init];
            device.uid = uid;
            device.dev_nickname = name;
            device.view_acc = view_acc;
            device.view_pwd = view_pwd;
            device.channel = channel;
            device.resolution = videoQuality;
            MyCamera *camera = [[MyCamera alloc] initWithDevice:device];
            //MyCamera *camera = [[MyCamera alloc] initWithName:name viewAccount:view_acc viewPassword:view_pwd];
            camera.mVideoQuality = videoQuality;
            camera.mDeviceUID = uid;
            [camera setLastChannel:channel];
            [camera connect:uid];
            [camera start:0];
            
            SMsgAVIoctrlSetStreamCtrlReq *s0 = (SMsgAVIoctrlSetStreamCtrlReq *)malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
            memset(s0, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
            
            s0->channel = 0;
            s0->quality = camera.mVideoQuality;
            
            [camera sendIOCtrlToChannel:0
                                   Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ
                                   Data:(char *)s0
                               DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
            free(s0);
            
            SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
            s->channel = 0;
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
            free(s);
            
            SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
            free(s2);
            
            SMsgAVIoctrlTimeZone s3={0};
            s3.cbSize = sizeof(s3);
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
            
            // register to apns server
            
            dispatch_queue_t queue = dispatch_queue_create("apns-reg_mapping", NULL);
            dispatch_async(queue, ^{
                if (self.deviceTokenString != nil) {
                    NSError *error = nil;
                    NSString *appidString = [[NSBundle mainBundle] bundleIdentifier];
#ifndef DEF_APNSTest
                    NSString *hostString = @"http://push.iotcplatform.com/apns/apns.php";
#else
                    NSString *hostString = @"http://54.225.191.150/test_gcm/apns.php"; //測試Host
#endif
                    NSString *argsString = @"%@?cmd=reg_mapping&token=%@&uid=%@&appid=%@";
                    NSString *getURLString = [NSString stringWithFormat:argsString, hostString, self.deviceTokenString, uid, appidString];
#ifdef DEF_APNSTest
                    NSLog( @"==============================================");
                    NSLog( @"stringWithContentsOfURL ==> %@", getURLString );
                    NSLog( @"==============================================");
#endif
                    NSString *registerResult = [NSString stringWithContentsOfURL:[NSURL URLWithString:getURLString] encoding:NSUTF8StringEncoding error:&error];
#ifdef DEF_APNSTest
                    NSLog( @"==============================================");
                    NSLog( @">>> %@", registerResult );
                    NSLog( @"==============================================");
#endif
                }
            });
            //dispatch_release(queue);
            [self.cameraArr addObject:camera];
        }
        [rs close];
    }
}


-(NSMutableArray *) getAllPhotos:(NSString *)uid
{
    DebugLog(@"获取所有图片 uid=%@",uid);
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    FMResultSet *rs = [_database executeQuery:@"SELECT * FROM snapshot WHERE dev_uid=?", uid];
    while([rs next]) {
        NSString *filePath = [rs stringForColumn:@"file_path"];
        DebugLog(@"获取到保存的图片%@", filePath);
        YLSnapPicInfo *item = [[YLSnapPicInfo alloc] init];
        item.fileName = filePath;
        item.bChecked = NO;
        [mutableArray addObject:item];
    }
    [rs close];
    return mutableArray;
}

-(BOOL) deletePhoto:(NSString *) fileName
{
    if (_database != NULL) {
        FMResultSet *rs = [_database executeQuery:@"SELECT * FROM snapshot WHERE file_path=?", fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        while([rs next]) {
            NSString *filePath = [rs stringForColumn:@"file_path"];
            [fileManager removeItemAtPath:[YLComFun pathForDocumentsResource: filePath] error:NULL];
            DebugLog(@"camera(%@) snapshot removed", filePath);
        }
        [rs close];
        [_database executeUpdate:@"DELETE FROM snapshot WHERE file_path=?", fileName];
        return YES;
    }
    return NO;
}

-(BOOL) saveOneSnapImage:(UIImage *) img  fileName:(NSString *) fileName cameraUID:(NSString *) uid
{
    if([YLComFun saveImageToFile:img fileName:fileName])
    {
        if (_database != NULL) {
            if (![_database executeUpdate:@"INSERT INTO snapshot(dev_uid, file_path, time) VALUES(?,?,?)", uid, fileName, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]]]) {
                DebugLog(@"Fail to add snapshot to database.");
                return NO;
            }
            return YES;
        }
    }
    return NO;
}

- (NSInteger) getVideoQuality:(NSString*) uid
{
    NSInteger videoQuality = 0;
    if (_database != NULL) {
        FMResultSet *rs = [_database executeQuery:@"SELECT * FROM device where dev_uid = ?",  uid];
        //[database executeUpdate:@"SELECT * FROM device  WHERE dev_uid=?",  camera.uid]
        while([rs next]) {
            
            NSString *uid = [rs stringForColumn:@"dev_uid"];
            NSString *name = [rs stringForColumn:@"dev_nickname"];
            NSString *view_acc = [rs stringForColumn:@"view_acc"];
            NSString *view_pwd = [rs stringForColumn:@"view_pwd"];
            //NSInteger channel = [rs intForColumn:@"channel"];
            videoQuality = [rs intForColumn:@"dev_videoQuality"];
            DebugLog(@"------ReGet Camera(%@, %@, %@, %@, videoQuality:%zd)", name, uid, view_acc, view_pwd, videoQuality);
        }
        [rs close];
    }
    return videoQuality;
}



@end
