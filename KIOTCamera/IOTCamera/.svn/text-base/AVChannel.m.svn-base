//
//  SessionChannel.m
//  IOTCamViewer
//
//  Created by tutk on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AVChannel.h"
#import "ip_block_fifo.h"
#import "Queue.h"
#import "AVFRAMEINFO.h"

@interface AVChannel ()
{
    NSInteger channel;
    NSInteger avIndex;
    NSString *viewAcc;
    NSString *viewPwd;
    
    unsigned int videoHeight;
    unsigned int videoWidth;
    char *videoBuffer;
    
    volatile NSInteger videoBps;
    volatile NSInteger audioBps;
    volatile NSInteger videoFps;
    
    NSInteger front;
    NSInteger rear;
    SendIOCtrlStruct_t *sendIOCtrlQueue;   
    
    ip_block_fifo_t *videoQueue;
    ip_block_fifo_t *audioQueue;
}

@property (readwrite, assign) NSInteger avChannel;
@property (readwrite, copy) NSString *viewAcc;
@property (readwrite, copy) NSString *viewPwd;
@end

@implementation AVChannel
@synthesize avChannel;
@synthesize avIndex;
@synthesize chIndexForSendAudio;
@synthesize avIndexForSendAudio;
@synthesize viewAcc;
@synthesize viewPwd;
@synthesize videoQueue;
@synthesize audioQueue;
@synthesize videoBps;
@synthesize videoFps;
@synthesize audioBps;
@synthesize videoWidth;
@synthesize videoHeight;

@synthesize isRunningStartThread;
@synthesize isRunningDecVideoThread;
@synthesize isRunningDecAudioThread;
@synthesize isRunningRecvIOCtrlThread;
@synthesize isRunningRecvVideoThread;
@synthesize isRunningRecvAudioThread;
@synthesize isRunningSendIOCtrlThread;
@synthesize isRunningSendAudioThread;

@synthesize startThread;
@synthesize recvAudioThread;
@synthesize recvVideoThread;
@synthesize recvIOCtrlThread;
@synthesize decVideoThread;
@synthesize decAudioThread;
@synthesize sendIOCtrlThread;
@synthesize sendAudioThread;

@synthesize startThreadLock;
@synthesize recvAudioThreadLock;
@synthesize recvVideoThreadLock;
@synthesize recvIOCtrlThreadLock;
@synthesize decVideoThreadLock;
@synthesize decAudioThreadLock;
@synthesize sendIOCtrlThreadLock;
@synthesize sendAudioThreadLock;

@synthesize serviceType;
@synthesize connectionState;
@synthesize videoCodec;
@synthesize audioCodec;
@synthesize videoDataSize;

- (id)initWithChannel:(NSInteger)channel_ ViewAccount:(NSString *)viewAcc_ ViewPassword:(NSString *)viewPwd_ 
{    
    self = [super init];
    
    if (self) {
        
        self.avChannel = channel_;
        self.viewAcc = viewAcc_;
        self.viewPwd = viewPwd_;
        self.videoBps = self.videoFps = self.audioBps = 0;
        self.videoWidth = self.videoHeight = 0;
    
        avIndex = -1;
        chIndexForSendAudio = -1;
        avIndexForSendAudio = -1;
        
        serviceType = 0xFFFFFFFF; // turn off all features
        connectionState = CONNECTION_STATE_NONE;
        videoCodec = MEDIA_CODEC_UNKNOWN;
        audioCodec = MEDIA_CODEC_UNKNOWN;
        videoDataSize = 0;
    
        if (videoQueue) 
            ip_block_FifoRelease(videoQueue);
        
        videoQueue = ip_block_FifoNew();
        audioQueue = ip_block_FifoNew();
        
        sendIOCtrlQueue = malloc(QUEUE_SIZE * sizeof(SendIOCtrlStruct_t));
        videoBuffer = malloc(MAX_IMG_BUFFER_SIZE);        
        
        [self initSendIOCtrlQueue];
    }
    
    return self;
}

- (void)dealloc 
{    
    [self releaseSendIOCtrlQueue];
    
    if (sendIOCtrlQueue) free(sendIOCtrlQueue);    
    if (videoBuffer) free(videoBuffer);
    if (videoQueue) ip_block_FifoRelease(videoQueue);
    if (audioQueue) ip_block_FifoRelease(audioQueue);    
    
    videoQueue = NULL;
    audioQueue = NULL;
    
    [viewAcc release];
    [viewPwd release];
    
    [startThread release];
    [recvAudioThread release];
    [recvIOCtrlThread release];
    [recvVideoThread release];
    [sendIOCtrlThread release];
    [decVideoThread release];
    [decAudioThread release];
    [sendAudioThread release];

    [startThreadLock release];
    [recvAudioThreadLock release];
    [recvIOCtrlThreadLock release];
    [recvVideoThreadLock release];
    [sendIOCtrlThreadLock release];
    [decVideoThreadLock release];
    [decAudioThreadLock release];
    [sendAudioThreadLock release];
    
    viewAcc = nil;
    viewPwd = nil;
    
    startThread = nil;
    recvAudioThread = nil;
    recvIOCtrlThread = nil;
    recvVideoThread = nil;
    sendIOCtrlThread = nil;
    decVideoThread = nil;
    decAudioThread = nil;
    sendAudioThread = nil;
    
    startThreadLock = nil;
    recvAudioThreadLock = nil;
    recvIOCtrlThreadLock = nil;
    recvVideoThreadLock = nil;
    sendIOCtrlThreadLock = nil;
    decVideoThreadLock = nil;
    decVideoThreadLock = nil;
    sendAudioThreadLock = nil;
       
    [super dealloc];
}

- (void)initSendIOCtrlQueue 
{    
    memset(sendIOCtrlQueue, 0, QUEUE_SIZE * sizeof(SendIOCtrlStruct_t));    
    front = rear = 0;
}

- (void)releaseSendIOCtrlQueue 
{            
    for (int i = 0; i < QUEUE_SIZE; i++) {
        
        sendIOCtrlQueue[i].type = 0;
        sendIOCtrlQueue[i].buffer_size = 0;
        
        memset(sendIOCtrlQueue[i].buffer, 0, MAX_IOCTRL_BUFFER_SIZE);
    }    
}

- (Boolean)isSendIOCtrlQueueEmtpy 
{    
    return front == rear;
}


- (int)enqueueSendIOCtrl:(int)type :(char *)buffer :(int)buffer_size 
{    
    @synchronized(self) {
        
        int r = (rear + 1) % QUEUE_SIZE;
        
        if (front == r) {
            return 0;
        }

        memset(sendIOCtrlQueue[r].buffer, 0, MAX_IOCTRL_BUFFER_SIZE);
        
        sendIOCtrlQueue[r].type = type;        
        sendIOCtrlQueue[r].buffer_size = buffer_size;        
        memcpy(sendIOCtrlQueue[r].buffer, buffer, buffer_size);
        
        rear = r;
    }
    
    return 1;
}

- (int)dequeueSendIOCtrl:(int *)type :(char *)buffer :(int *)buffer_size 
{
    
    @synchronized(self) {
        
        int f;
        
        if (front == rear)
            return 0;
        
        f = (front + 1) % QUEUE_SIZE;
        
        *type = sendIOCtrlQueue[f].type;        
        *buffer_size = sendIOCtrlQueue[f].buffer_size;                
        memcpy(buffer, sendIOCtrlQueue[f].buffer, sendIOCtrlQueue[f].buffer_size);        
        
        memset(sendIOCtrlQueue[f].buffer, 0, MAX_IOCTRL_BUFFER_SIZE);        
        sendIOCtrlQueue[f].buffer_size = 0;
        sendIOCtrlQueue[f].type = 0;
        
        front = f;
    }
    
    return 1;
}


- (unsigned int)getVideoBuffer:(char **)buf
{
    if (videoBuffer) {
        *buf = videoBuffer;
        return MAX_IMG_BUFFER_SIZE;
    }
    return 0;
}
@end
