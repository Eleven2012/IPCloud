//
//  MyCamera.h
//  IOTCamViewer
//
//  Created by Cloud Hsiao on 12/7/2.
//  Copyright (c) 2012年 TUTK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLSDK.h"
#import "YLDeviceInfo.h"
//#define DEF_VideoQualityValue 2 /*影像品質: 最高(1) 高(2) 適中(3) 低(4) 最低(5)*/
// begin add by kongyulu at 2013-10-22
#define DEF_VideoQualityValue 4 /*影像品質: 最高(1) 高(2) 適中(3) 低(4) 最低(5)*/
// end add by kongyulu at 2013-10-22

@protocol MyCameraDelegate;

@interface MyCamera : Camera <CameraDelegate>
{
    id<MyCameraDelegate> delegate2;
    NSInteger lastChannel;
    NSInteger remoteNotifications;
    NSMutableArray *arrayStreamChannel;
    NSString *viewAcc;
    NSString *viewPwd;
	NSInteger mVideoQuality;
	
	BOOL bIsSupportTimeZone;
	int nGMTDiff;
	NSString* strTimeZone;
}

@property (nonatomic, retain) YLDeviceInfo *device;

@property (nonatomic, assign) id<MyCameraDelegate> delegate2;
@property NSInteger lastChannel;
@property (readonly) NSInteger remoteNotifications;
@property (nonatomic, copy) NSString *viewAcc;
@property (nonatomic, copy) NSString *viewPwd;
@property (nonatomic, assign) BOOL bIsSupportTimeZone;
@property (nonatomic, assign) int nGMTDiff;
@property (nonatomic, copy) NSString* strTimeZone;
@property (nonatomic, assign) NSInteger mVideoQuality;
@property (nonatomic, copy) NSString *mDeviceUID;


- (id)initWithDevice:(YLDeviceInfo *) device;
- (BOOL)updateDevice:(YLDeviceInfo *) device;
- (id)initWithName:(NSString *)name viewAccount:(NSString *)viewAcc viewPassword:(NSString *)viewPwd;
- (void)start:(NSInteger)channel;
- (void)start4EventPlayback:(NSInteger)channel;
- (void)setRemoteNotification:(NSInteger)type EventTime:(long)time;
- (void)clearRemoteNotifications;
- (NSArray *)getSupportedStreams;
- (BOOL)getAudioInSupportOfChannel:(NSInteger)channel;
- (BOOL)getAudioOutSupportOfChannel:(NSInteger)channel;
- (BOOL)getPanTiltSupportOfChannel:(NSInteger)channel;
- (BOOL)getEventListSupportOfChannel:(NSInteger)channel;
- (BOOL)getPlaybackSupportOfChannel:(NSInteger)channel;
- (BOOL)getWiFiSettingSupportOfChannel:(NSInteger)channel;
- (BOOL)getMotionDetectionSettingSupportOfChannel:(NSInteger)channel;
- (BOOL)getRecordSettingSupportOfChannel:(NSInteger)channel;
- (BOOL)getFormatSDCardSupportOfChannel:(NSInteger)channel;
- (BOOL)getVideoFlipSupportOfChannel:(NSInteger)channel;
- (BOOL)getEnvironmentModeSupportOfChannel:(NSInteger)channel;
- (BOOL)getMultiStreamSupportOfChannel:(NSInteger)channel;
- (NSInteger)getAudioOutFormatOfChannel:(NSInteger)channel;
- (BOOL)getVideoQualitySettingSupportOfChannel:(NSInteger)channel;
- (BOOL)getDeviceInfoSupportOfChannel:(NSInteger)channel;
- (NSString*)getOverAllQualityString;

+ (NSString*)getConnModeString:(NSInteger)connMode;


//{{--kongyulu at 20170724
- (BOOL)stopPT;
- (BOOL)startPT:(NSInteger) direction channel:(NSInteger) nChn;
//{{--kongyulu at 20170724

@end

@protocol MyCameraDelegate <NSObject>
@optional
- (void)camera:(MyCamera *)camera _didReceiveRemoteNotification:(NSInteger)eventType EventTime:(long)eventTime;
- (void)camera:(MyCamera *)camera _didReceiveRawDataFrame:(const char *)imgData VideoWidth:(NSInteger)width VideoHeight:(NSInteger)height;
- (void)camera:(MyCamera *)camera _didReceiveJPEGDataFrame:(const char *)imgData DataSize:(NSInteger)size;
- (void)camera:(MyCamera *)camera _didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned long)frameCount IncompleteFrameCount:(unsigned long)incompleteFrameCount;
- (void)camera:(MyCamera *)camera _didChangeSessionStatus:(NSInteger)status;
- (void)camera:(MyCamera *)camera _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status;
- (void)camera:(MyCamera *)camera _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char*)data DataSize:(NSInteger)size;
@end

extern BOOL g_bDiagnostic;
