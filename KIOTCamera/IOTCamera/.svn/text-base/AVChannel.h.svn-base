//
//  SessionChannel.h
//  IOTCamViewer
//
//  Created by tutk on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#import "ip_block_fifo.h"
#import "Camera.h"

#define QUEUE_SIZE 32
#define MAX_IOCTRL_BUFFER_SIZE 1024
#define MAX_IMG_BUFFER_SIZE	2764800	//1280 * 720 * 3


typedef struct SendIOCtrlStruct {    
    int type;
    char buffer[MAX_IOCTRL_BUFFER_SIZE];
    int buffer_size;   
    
} SendIOCtrlStruct_t;

@interface AVChannel : NSObject {
}

@property (readonly) NSInteger avChannel;
@property NSInteger avIndex;
@property NSInteger chIndexForSendAudio;
@property NSInteger avIndexForSendAudio;
@property (readonly, copy) NSString *viewAcc;
@property (readonly, copy) NSString *viewPwd;

@property Boolean isRunningStartThread;
@property Boolean isRunningRecvVideoThread;
@property Boolean isRunningRecvAudioThread;
@property Boolean isRunningDecVideoThread;
@property Boolean isRunningDecAudioThread;
@property Boolean isRunningSendIOCtrlThread;
@property Boolean isRunningRecvIOCtrlThread;
@property Boolean isRunningSendAudioThread;

@property unsigned int videoWidth;
@property unsigned int videoHeight;

@property ip_block_fifo_t *videoQueue;
@property ip_block_fifo_t *audioQueue;

@property (nonatomic, retain) NSThread *startThread;
@property (nonatomic, retain) NSThread *recvVideoThread;
@property (nonatomic, retain) NSThread *recvAudioThread;
@property (nonatomic, retain) NSThread *decVideoThread;
@property (nonatomic, retain) NSThread *decAudioThread;
@property (nonatomic, retain) NSThread *recvIOCtrlThread;
@property (nonatomic, retain) NSThread *sendIOCtrlThread;
@property (nonatomic, retain) NSThread *sendAudioThread;

@property (retain) NSConditionLock *startThreadLock;
@property (retain) NSConditionLock *recvVideoThreadLock;
@property (retain) NSConditionLock *recvAudioThreadLock;
@property (retain) NSConditionLock *decVideoThreadLock;
@property (retain) NSConditionLock *decAudioThreadLock;
@property (retain) NSConditionLock *recvIOCtrlThreadLock;
@property (retain) NSConditionLock *sendIOCtrlThreadLock;
@property (retain) NSConditionLock *sendAudioThreadLock;

@property unsigned long serviceType;
@property NSInteger connectionState;
@property NSInteger videoBps;
@property NSInteger audioBps;
@property NSInteger videoFps;
@property NSInteger videoCodec;
@property NSInteger audioCodec;
@property unsigned int videoDataSize;

- (id) initWithChannel:(NSInteger)channel ViewAccount:(NSString *)viewAcc ViewPassword:(NSString *)viewPwd;
- (Boolean)isSendIOCtrlQueueEmtpy;
- (int)enqueueSendIOCtrl:(int)type :(char*)buffer :(int)buffer_size;
- (int)dequeueSendIOCtrl:(int *)type :(char*)buffer :(int *)buffer_size;
- (unsigned int)getVideoBuffer:(char **)buf;
@end
