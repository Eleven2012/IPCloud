//
//  Camera.m
//  IOTCamViewer
//
//  Created by tutk on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <sys/time.h>
#import "Camera.h"
#import "Camera2.h"
#import "AudioRecorder.h"
#import "AVChannel.h"
#import "IOTCAPIs.h"
#import "AVAPIs.h"
#import "AVIOCTRLDEFs.h"
#import "ip_block_fifo.h"
#import "adpcm.h"
#import "mpg123.h"
#import "speex/speex.h"
#import "speex/speex_echo.h"
#import "OpenALPlayer.h"
#import "AudioRecorder.h"
#import "codec_g726.h"

#import "g711au.h"

#import "ZHPFVideoRecorder.h"

#ifdef MJ4
#import "h264.h"
#import "mpeg4.h"
#else
#import "H264iPhone.h"
#endif

#define REAL_AUDIO_OUT
//#define TEST_AUDIO_OUT

#define AVRECVFRAMEDATA2
#define DECODEVIDEO2


#define RECV_VIDEO_BUFFER_SIZE 1280 * 720 * 3
#define RECV_AUDIO_BUFFER_SIZE 1280
#define SPEEX_FRAME_SIZE 160
#define MAX_IOCTRL_BUFFER_SIZE 1024

#define DONE 1
#define NOTDONE 0

#ifdef DEBUG
//#   define LOG(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define LOG(fmt, ...) NSLog((@"" fmt), ##__VA_ARGS__);
#else
#define LOG(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define RLOG(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface Camera() <AudioRecordDelegate>
{
    SpeexBits speex_enc_bits;
    void *speex_enc_state;
    char speex_enc_buffer[200];
    
    NSString *name;
    NSString *uid;
    NSString *aesKey;
    NSInteger sessionID;
    NSInteger sessionMode;
    NSInteger sessionState;
    NSMutableArray *arrayAVChannel;
    
    char recvIOCtrlBuff[MAX_IOCTRL_BUFFER_SIZE];     
    
    id<CameraDelegate> delegate;
    
    unsigned char *hG726Dec;
    unsigned char *hG726Enc;
    
    NSMutableArray *arrayRecvNotifications;
}

@property (readwrite, copy) NSString *uid;
@property (readwrite, copy) NSString *aesKey;
@property (readwrite) NSInteger sessionID;
@property (readwrite) NSInteger sessionMode;
@property (readwrite) NSInteger sessionState;
@property Boolean isRunningConnectingThread;
@property Boolean isRunningCheckingThread;
@property (nonatomic, assign) NSThread *connectThread;
@property (nonatomic, assign) NSThread *checkThread;
@property (nonatomic, assign) NSConditionLock *connectThreadLock;
@property (nonatomic, assign) NSConditionLock *checkThreadLock;
@property (readwrite) NSInteger sessionID4ConnStop;		//In order to keep original program flow, we add this member variable
//for new API IOTC_Connect_Stop_BySID to avoid inproper manipulation
//before get the valid connection decided by the original member variable sessionID
@end

@implementation Camera

@synthesize sessionID;
@synthesize sessionMode;
@synthesize sessionState;
@synthesize uid;
@synthesize name;
@synthesize aesKey;
@synthesize delegate;
@synthesize delegateForMonitor;
@synthesize isRunningConnectingThread;
@synthesize isRunningCheckingThread;
@synthesize connectThread, checkThread;
@synthesize connectThreadLock, checkThreadLock;

@synthesize m_nConnectStatus;


-(void)startRecordVideo:(NSString *)filePath{
    [[ZHPFVideoRecorder getInstance] startVideoRecord:filePath];
}
-(BOOL)stopRecordVideo{
    return [[ZHPFVideoRecorder getInstance] stopVideoRecord];
}

#pragma mark - Common method
unsigned int _getTickCount() {
    
	struct timeval tv;
    
	if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
	return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

unsigned int _getTickCount_() {
    
	struct timeval tv;
    
	if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
	return (tv.tv_sec * 1000000 + tv.tv_usec);
}

- (int)_getSampleRate:(unsigned char)flag {
        
    switch(flag >> 2) {
            
        case AUDIO_SAMPLE_8K:
            return 8000;
            break;
            
        case AUDIO_SAMPLE_11K:
            return 11025;
            break;
            
        case AUDIO_SAMPLE_12K:
            return 12000;
            break;
            
        case AUDIO_SAMPLE_16K:
            return 16000;
            break;
            
        case AUDIO_SAMPLE_22K:
            return 22050;
            break;
            
        case AUDIO_SAMPLE_24K:
            return 24000;
            break;
            
        case AUDIO_SAMPLE_32K:
            return 32000;
            break;
            
        case AUDIO_SAMPLE_44K:
            return 44100;
            break;
            
        case AUDIO_SAMPLE_48K:
            return 48000;
            break;
            
        default:
            return 8000;
    }
}

- (NSString *) _getHexString:(char *)buff Size:(int)size 
{    
    int i = 0;
    char *ptr = buff;
    
    NSMutableString *str = [[NSMutableString alloc] init];
    while(i++ < size) [str appendFormat:@"%02X ", *ptr++ & 0x00FF];
    
    return [str autorelease];
}

-(BOOL)dataIsValidJPEG:(NSData *)data
{
    if (!data || data.length < 2) return NO;
    
    NSInteger totalBytes = data.length;
    const char *bytes = (const char*)[data bytes];
    
    return (bytes[0] == (char)0xff &&
            bytes[1] == (char)0xd8 &&
            bytes[totalBytes-2] == (char)0xff &&
            bytes[totalBytes-1] == (char)0xd9);
}

#pragma mark - Speex AEC

static SpeexEchoState *echo_state = NULL;
//static SpeexPreprocessState *denoise_state;
static short* rec_buffer = NULL;
static short* play_buffer = NULL;
static int sampleRate = 8000;


void initSpeexAEC(int frame_size)
{
    if(echo_state != NULL) return;
    
    rec_buffer = (short *)malloc(frame_size);
    play_buffer = (short *)malloc(frame_size);
    
    LOG(@"init speex aec");
    
    echo_state = speex_echo_state_init(frame_size, frame_size*10);
    //denoise_state = speex_preprocess_state_init(frame_size, sampleRate);
    speex_echo_ctl(echo_state, SPEEX_ECHO_SET_SAMPLING_RATE, &sampleRate);
    //speex_preprocess_ctl(denoise_state, SPEEX_PREPROCESS_SET_ECHO_STATE, echo_state);
}

void uninitSpeexAEC()
{
    if(echo_state != NULL) speex_echo_state_destroy(echo_state);
    echo_state = NULL;
        
    if (play_buffer) free(play_buffer);
    if (rec_buffer) free(rec_buffer);
    
    play_buffer = NULL;
    rec_buffer = NULL;
}

- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[dirs objectAtIndex:0] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

- (NSString *) parseIOTCAPIsVerion:(long)version
{
    char cIOTCVer[4];
    
    cIOTCVer[3] = (char)version;
    cIOTCVer[2] = (char)(version >> 8);
    cIOTCVer[1] = (char)(version >> 16);
    cIOTCVer[0] = (char)(version >> 24);
    
    return [NSString stringWithFormat:@"%d.%d.%d.%d", cIOTCVer[0], cIOTCVer[1], cIOTCVer[2], cIOTCVer[3]];
}

#pragma mark - Public methods

- (id)init
{
    self = [super init];
    
    if (self) {        
        arrayAVChannel = [[NSMutableArray alloc] init];    
        arrayRecvNotifications = [[NSMutableArray alloc] init];
                
        self.sessionID = -1;
        self.sessionMode = CONNECTION_MODE_NONE;
        self.sessionState = CONNECTION_STATE_NONE;
        _natD = -1;
        _natC = -1;
        _connTimes = 0;
        _connFailErrCode = 0;
    }
    
    return self;
}

- (id)initWithName:(NSString *)name_
{
    self = [self init];
    if (self) {        
        self.name = name_;
    }
    return self;
}

- (void)dealloc 
{
    delegate = nil;
    delegateForMonitor = nil;
    
    [uid release];
    [name release];
    [arrayAVChannel release];
    [arrayRecvNotifications release];
    
    [super dealloc];
}

#pragma mark - Public Methods

- (unsigned int)getChannel:(NSInteger)channel Snapshot:(char *)imgData dataSize:(unsigned long)size WithImageWidth:(unsigned int *)width ImageHeight:(unsigned int *)height
{
    unsigned int codec_id = 0;
    return [self getChannel:channel Snapshot:imgData DataSize:size ImageType:&codec_id WithImageWidth:width ImageHeight:height];
}

- (unsigned int)getChannel:(NSInteger)channel Snapshot:(char *)imgData DataSize:(unsigned long)size ImageType:(unsigned int*)codec_id WithImageWidth:(unsigned int *)width ImageHeight:(unsigned int *)height
{    
    AVChannel *ch = nil;
    for (AVChannel *c in arrayAVChannel) {
        
        if (ch.avChannel == channel) {
            ch = c;
            break;
        }
    }
    
    if (ch != nil) {

        if (size < MAX_IMG_BUFFER_SIZE)
            return false;

        int len;
        char *srcBuf = NULL;
        *width = ch.videoWidth;
        *height = ch.videoHeight;
        *codec_id = ch.videoCodec;
         //srcBuf = [ch getVideoBufferWithSize:&len];
        len = [ch getVideoBuffer:&srcBuf];
        NSLog(@"******* snap ***, len=%d, size=%ld",len,size);
        
        if (srcBuf != NULL && len > 100) {
            memcpy(imgData, srcBuf, size);
        }
        

        
        return ch.videoDataSize;
    }
    else 
        return -1;
}

//{{--kongyulu at 20170726

- (UIImage *)getImageByChannel:(NSInteger)channel
{
    UIImage *img = nil;
    AVChannel *ch = nil;
    for (AVChannel *c in arrayAVChannel) {
        
        if (ch.avChannel == channel) {
            ch = c;
            break;
        }
    }
    if (ch != nil) {
        int len;
        char *srcBuf = NULL;
        len = [ch getVideoBuffer:&srcBuf];
        if (ch.videoCodec == MEDIA_CODEC_VIDEO_H264 || ch.videoCodec == MEDIA_CODEC_VIDEO_MPEG4) {
            img = [self getUIImage:srcBuf Width:ch.videoWidth Height:ch.videoHeight];
        }
        else if (ch.videoCodec == MEDIA_CODEC_VIDEO_MJPEG) {
            NSData *data = [[NSData alloc] initWithBytes:srcBuf length:len];
            img = [[[UIImage alloc] initWithData:data] autorelease];
            [data release];
        }
        
        return img;
    }
    else
        return img;
}

- (UIImage *)getImageByChannel:(NSInteger)channel ImageType:(unsigned int*)codec_id WithImageWidth:(unsigned int *)width ImageHeight:(unsigned int *)height
{
    UIImage *img = nil;
    AVChannel *ch = nil;
    for (AVChannel *c in arrayAVChannel) {
        
        if (ch.avChannel == channel) {
            ch = c;
            break;
        }
    }
    
    if (ch != nil) {
        int len;
        char *srcBuf = NULL;
        *width = ch.videoWidth;
        *height = ch.videoHeight;
        *codec_id = ch.videoCodec;
        len = [ch getVideoBuffer:&srcBuf];
        if (ch.videoCodec == MEDIA_CODEC_VIDEO_H264 || ch.videoCodec == MEDIA_CODEC_VIDEO_MPEG4) {
            img = [self getUIImage:srcBuf Width:ch.videoWidth Height:ch.videoHeight];
        }
        else if (ch.videoCodec == MEDIA_CODEC_VIDEO_MJPEG) {
            NSData *data = [[NSData alloc] initWithBytes:srcBuf length:len];
            img = [[[UIImage alloc] initWithData:data] autorelease];
            [data release];
        }
        
        return img;
    }
    else 
        return img;
}

- (UIImage *) getUIImage:(char *)buff Width:(NSInteger)width Height:(NSInteger)height
{
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buff, width * height * 3, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(width, height, 8, 24, width * 3, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, true,  kCGRenderingIntentDefault);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    if (imgRef != nil) {
        CGImageRelease(imgRef);
        imgRef = nil;
    }
    if (colorSpace != nil) {
        CGColorSpaceRelease(colorSpace);
        colorSpace = nil;
    }
    if (provider != nil) {
        CGDataProviderRelease(provider);
        provider = nil;
    }
    return [[img copy] autorelease];
}
//}}--kongyulu at 20170726

- (void)sendIOCtrlToChannel:(NSInteger)channel Type:(NSInteger)type Data:(char *)buff DataSize:(NSInteger)buffer_size 
{    
    AVChannel *sendChannel = nil;
    
    for (AVChannel *ch in arrayAVChannel) {
        
        if (ch.avChannel == channel) {
            sendChannel = ch;
            break;
        }
    }
    
    if (sendChannel != nil) {
        [sendChannel enqueueSendIOCtrl:type :buff :buffer_size];   
    }
}

- (NSString *)getViewAccountOfChannel:(NSInteger)channel
{
    for (AVChannel *ch in arrayAVChannel) {        
        if (ch.avChannel == channel)
            return [ch.viewAcc copy];
    }
    
    return nil;
}

- (NSString *)getViewPasswordOfChannel:(NSInteger)channel
{
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel)
            return [ch.viewPwd copy];
    }
    
    return nil;
}

- (unsigned long)getServiceTypeOfChannel:(NSInteger)channel
{
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel)
            return ch.serviceType;
    }
    return 0xFFFFFFFF;
}

- (NSInteger)getConnectionStateOfChannel:(NSInteger)channel
{
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel)
            return ch.connectionState;
    }    
    return CONNECTION_STATE_NONE;
}

#pragma mark - IOTCApis Methods
	
+ (void)initIOTC 
{       
    unsigned short nUdpPort = (unsigned short)(10000 + (_getTickCount() % 10000));
    int ret = -1;
    
    // ret = IOTC_Initialize(nUdpPort, "50.19.254.134", "122.248.234.207", "m4.iotcplatform.com", "m5.iotcplatform.com"); 
    ret = IOTC_Initialize2(nUdpPort);
    
    if (ret < 0)
        LOG(@"IOTC_Initialize2() failed -> %d", ret);
    
    avInitialize(64);
    LOG(@"avInitialize");
}

+ (void)uninitIOTC 
{
    avDeInitialize();
    LOG(@"avDeInitialize");
    IOTC_DeInitialize();
    LOG(@"IOTC_DeInitialize");
} 

+ (NSString *) getIOTCAPIsVerion 
{    
    unsigned long ulIOTCVer;            
    char cIOTCVer[4];
    
    IOTC_Get_Version(&ulIOTCVer);
    cIOTCVer[3] = (char)ulIOTCVer;
    cIOTCVer[2] = (char)(ulIOTCVer >> 8);
    cIOTCVer[1] = (char)(ulIOTCVer >> 16);
    cIOTCVer[0] = (char)(ulIOTCVer >> 24);
    
    return [NSString stringWithFormat:@"%d.%d.%d.%d", cIOTCVer[0], cIOTCVer[1], cIOTCVer[2], cIOTCVer[3]];
}

+ (NSString *) getAVAPIsVersion 
{    
    int nAVAPIVer;
    char cAVAPIVer[4];
    
    nAVAPIVer = avGetAVApiVer();
    cAVAPIVer[3] = (char)nAVAPIVer;
    cAVAPIVer[2] = (char)(nAVAPIVer >> 8);
    cAVAPIVer[1] = (char)(nAVAPIVer >> 16);
    cAVAPIVer[0] = (char)(nAVAPIVer >> 24);
    
    return [NSString stringWithFormat:@"%d.%d.%d.%d", cAVAPIVer[0], cAVAPIVer[1], cAVAPIVer[2], cAVAPIVer[3]];
}

+ (LanSearch_t *) LanSearch:(int *)num 
{
    int nMaxCount = 16;
    LanSearch_t *pResult = malloc(sizeof(LanSearch_t) * nMaxCount);
    memset( pResult, 0, sizeof(LanSearch_t) * nMaxCount );
    *num = IOTC_Lan_Search(pResult, nMaxCount, 2000 );
    return pResult;
}

+ (LanSearch_t *)LanSearch:(int *)num timeout:(int)timeoutVal
{
    int nMaxCount = 32;
    LanSearch_t* pResult = malloc(sizeof(LanSearch_t)*nMaxCount);
    
    memset( pResult, 0, sizeof(LanSearch_t)*nMaxCount );
    
    *num = IOTC_Lan_Search( pResult, nMaxCount, timeoutVal );
    
    return pResult;
}

- (void)connect:(NSString *)uid_ 
{
    self.uid = uid_;
       
    isRunningConnectingThread = TRUE;
    isRunningCheckingThread = TRUE;
    
    if (connectThread == nil) {
        connectThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
        connectThread = [[NSThread alloc] initWithTarget:self selector:@selector(doConnect) object:nil];
        [connectThread start];
    }

    if (checkThread == nil) {
        checkThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
        checkThread = [[NSThread alloc] initWithTarget:self selector:@selector(doCheckStatus) object:nil];
        [checkThread start];
    }
}

- (void)connect:(NSString *)uid_ AesKey:(NSString *)aesKey_
{
    self.uid = uid_;
    self.aesKey = aesKey_;
    
    isRunningConnectingThread = TRUE;
    isRunningCheckingThread = TRUE;
    
    if (connectThread == nil) {
        connectThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
        connectThread = [[NSThread alloc] initWithTarget:self selector:@selector(doConnect) object:nil];
        [connectThread start];
    }
    
    if (checkThread == nil) {
        checkThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
        checkThread = [[NSThread alloc] initWithTarget:self selector:@selector(doCheckStatus) object:nil];
        [checkThread start];
    }
}

- (void)disconnect {
    
    NSArray *ary = [NSArray arrayWithArray:arrayAVChannel];
    for (AVChannel *ch in ary) {
        
        [self stopSoundToDevice:ch.avChannel];
        [self stopSoundToPhone:ch.avChannel];
        [self stopShow:ch.avChannel];
        [self stop:ch.avChannel];
    }
    
    if (sessionID < 0)
        IOTC_Connect_Stop();
    
    if (checkThread != nil) {
        
        self.isRunningCheckingThread = FALSE;
        
        [checkThreadLock lockWhenCondition:DONE];
        [checkThreadLock unlock];
        [checkThreadLock release];
        
        [checkThread release];
        checkThread = nil;
    }
    
    if (connectThread != nil) {

        self.isRunningConnectingThread = FALSE;
                
        [connectThreadLock lockWhenCondition:DONE];
        [connectThreadLock unlock];
        [connectThreadLock release];
        
        [connectThread release];
        connectThread = nil;
    }
    
    if (sessionID >= 0) {        
        
        IOTC_Session_Close(sessionID);
        LOG("IOTC_Session_Close(%d)", sessionID);
        sessionID = -1;
    }
    
    self.sessionMode = CONNECTION_MODE_NONE;
    self.sessionState = CONNECTION_STATE_DISCONNECTED;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeSessionStatus:)])
        [self.delegate camera:self didChangeSessionStatus:self.sessionState];
}

- (void)start:(NSInteger)channel viewAccount:(NSString *)viewAcc viewPassword:(NSString *)viewPwd
{
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) 
            return;
    }
    
    AVChannel *ch = [[AVChannel alloc] initWithChannel:channel ViewAccount:viewAcc ViewPassword:viewPwd];
    
    ch.isRunningStartThread = TRUE;
    ch.isRunningSendIOCtrlThread = TRUE;
    ch.isRunningRecvIOCtrlThread = TRUE;  
    
    if (ch.startThread == nil) {
        
        ch.startThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
        
        ch.isRunningStartThread = TRUE;
        ch.startThread = [[NSThread alloc] initWithTarget:self selector:@selector(doStart:) object:ch];
        [ch.startThread start];
    }    
    
    if (ch.sendIOCtrlThread == nil) {
        
        ch.sendIOCtrlThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
        
        ch.isRunningSendIOCtrlThread = TRUE;
        ch.sendIOCtrlThread = [[NSThread alloc] initWithTarget:self selector:@selector(doSendIOCtrl:) object:ch];
        [ch.sendIOCtrlThread start];
    }    
    
    
    if (ch.recvIOCtrlThread == nil) {
        
        ch.recvIOCtrlThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
        
        ch.isRunningRecvIOCtrlThread = TRUE;
        ch.recvIOCtrlThread = [[NSThread alloc] initWithTarget:self selector:@selector(doRecvIOCtrl:) object:ch];
        [ch.recvIOCtrlThread start];
    }    
    
    [arrayAVChannel addObject:ch];
    [ch release];
}

- (void)stop:(NSInteger)channel 
{    
    AVChannel *stoppedChannel = nil;
    
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) {
            stoppedChannel = ch;
            break;
        }
    }
         
    if (stoppedChannel != nil) {
        
        [self stopSoundToPhone:channel];
        [self stopSoundToDevice:channel];
        [self stopShow:channel];        
        
        // call threads exit themselves        
        stoppedChannel.isRunningSendIOCtrlThread = FALSE;
        stoppedChannel.isRunningRecvIOCtrlThread = FALSE;
        stoppedChannel.isRunningStartThread = FALSE;              
                
        // close threads and wait for threads exit        
        if (stoppedChannel.recvIOCtrlThread != nil) {
            
            [stoppedChannel.recvIOCtrlThreadLock lockWhenCondition:DONE];
            [stoppedChannel.recvIOCtrlThreadLock unlock];
            [stoppedChannel.recvIOCtrlThreadLock release];
            
            [stoppedChannel.recvIOCtrlThread release];
            stoppedChannel.recvIOCtrlThread = nil; 
        }
        
        if (stoppedChannel.sendIOCtrlThread != nil) {
            
            avSendIOCtrlExit(stoppedChannel.avIndex);
            // LOG(@"avSendIOCtrlExit(%d)", stoppedChannel.avIndex);

            [stoppedChannel.sendIOCtrlThreadLock lockWhenCondition:DONE];
            [stoppedChannel.sendIOCtrlThreadLock unlock];
            [stoppedChannel.sendIOCtrlThreadLock release];
            
            [stoppedChannel.sendIOCtrlThread release];
            stoppedChannel.sendIOCtrlThread = nil;
        }
                        
        if (stoppedChannel.startThread != nil) {
            
            avClientExit(sessionID, stoppedChannel.avChannel);        
            // LOG(@"avClientExit(%d)", stoppedChannel.avChannel);

            [stoppedChannel.startThreadLock lockWhenCondition:DONE];
            [stoppedChannel.startThreadLock unlock];
            [stoppedChannel.startThreadLock release];
            
            [stoppedChannel.startThread release];
            stoppedChannel.startThread = nil; 
        }
        
        // close avClient        
        if (stoppedChannel.avIndex >= 0) {            
            avClientStop(stoppedChannel.avIndex);
            // LOG(@"avClientStop(%d)", stoppedChannel.avIndex);
        }               
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeChannelStatus:ChannelStatus:)])
            [self.delegate camera:self didChangeChannelStatus:channel ChannelStatus:CONNECTION_STATE_DISCONNECTED];
        
        stoppedChannel.avIndex = -1;
        
        [arrayAVChannel removeObject:stoppedChannel];
    }
}

- (Boolean)isStarting:(NSInteger)channel
{
    Boolean result = false;
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) {
            result = self.sessionState == CONNECTION_STATE_CONNECTED && ch.avIndex >= 0;
            break;
        }
    }
    return result;
}

- (void)startShow:(NSInteger)channel 
{    
    AVChannel *showedChannel = nil;
    
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) {
            showedChannel = ch;
            break;
        }
    }
    
    if (showedChannel != nil) {                       

        if (showedChannel.recvVideoThread == nil) {
            
            showedChannel.recvVideoThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
            
            showedChannel.isRunningRecvVideoThread = TRUE;
#ifdef AVRECVFRAMEDATA2
            showedChannel.recvVideoThread = [[NSThread alloc] initWithTarget:self selector:@selector(doRecvVideo2:) object:showedChannel];
#else
            showedChannel.recvVideoThread = [[NSThread alloc] initWithTarget:self selector:@selector(doRecvVideo:) object:showedChannel];
#endif
            [showedChannel.recvVideoThread start];
        }
        
        if (showedChannel.decVideoThread == nil) {
            
            showedChannel.decVideoThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
            
            showedChannel.isRunningDecVideoThread = TRUE;
#ifdef DECODEVIDEO2
            showedChannel.decVideoThread = [[NSThread alloc] initWithTarget:self selector:@selector(doDecodeVideo2:) object:showedChannel];
#else
            showedChannel.decVideoThread = [[NSThread alloc] initWithTarget:self selector:@selector(doDecodeVideo:) object:showedChannel];
#endif
            [showedChannel.decVideoThread start];
        }
                
        int camIndex = 0;
        [self sendIOCtrlToChannel:channel Type:IOTYPE_USER_IPCAM_START Data:(char *)&camIndex DataSize:4];        
    }
}

- (void)stopShow:(NSInteger)channel {
    
    AVChannel *stoppedChannel = nil;
    
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) {
            stoppedChannel = ch;
            break;
        }
    }
    
    if (stoppedChannel != nil) {
        
        int camIndex = 0;
        [self sendIOCtrlToChannel:channel Type:IOTYPE_USER_IPCAM_STOP Data:(char *)&camIndex DataSize:4];
        
        stoppedChannel.isRunningRecvVideoThread = FALSE;
        stoppedChannel.isRunningDecVideoThread = FALSE;
        
        if (stoppedChannel.recvVideoThread != nil) {
            
            [stoppedChannel.recvVideoThreadLock lockWhenCondition:DONE];
            [stoppedChannel.recvVideoThreadLock unlock];
            [stoppedChannel.recvVideoThreadLock release];     
            
            [stoppedChannel.recvVideoThread release];
            stoppedChannel.recvVideoThread = nil;
        }
        
        if (stoppedChannel.decVideoThread != nil) {
            
            [stoppedChannel.decVideoThreadLock lockWhenCondition:DONE];
            [stoppedChannel.decVideoThreadLock unlock];
            [stoppedChannel.decVideoThreadLock release];            
            
            [stoppedChannel.decVideoThread release];
            stoppedChannel.decVideoThread = nil;
        }
    }
}

- (void)startSoundToPhone:(NSInteger)channel {    
        
    AVChannel *playedChannel = nil;
    
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) {
            playedChannel = ch;
            break;
        }
    }
    
    if (playedChannel != nil) {
        
        if (playedChannel.recvAudioThread == nil) {
            
            playedChannel.recvAudioThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
            
            playedChannel.isRunningRecvAudioThread = TRUE;        
            playedChannel.recvAudioThread = [[NSThread alloc] initWithTarget:self selector:@selector(doRecvAudio:) object:playedChannel];
            [playedChannel.recvAudioThread start];             
        }
                
        /*
        if (playedChannel.decAudioThread == nil) {
                        
            playedChannel.decAudioThreadLock = [[NSConditionLock alloc] initWithCondition:NOTDONE];
            
            playedChannel.isRunningDecAudioThread = TRUE;
            playedChannel.decAudioThread = [[NSThread alloc] initWithTarget:self selector:@selector(doDecodeAudio:) object:playedChannel];
            [playedChannel.decAudioThread start];
        }                
        */
        
        int camIndex = 0;
        [self sendIOCtrlToChannel:channel Type:IOTYPE_USER_IPCAM_AUDIOSTART Data:(char *)&camIndex DataSize:4];        
    }
}

- (void)stopSoundToPhone:(NSInteger)channel {
    
    AVChannel *stoppedChannel = nil;
    
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) {
            stoppedChannel = ch;
            break;
        }
    }         
    
    if (stoppedChannel != nil) {
            
        stoppedChannel.isRunningRecvAudioThread = FALSE;
        stoppedChannel.isRunningDecAudioThread = FALSE;
     
        if (stoppedChannel.recvAudioThread != nil) {
            
            int camIndex = 0;
            [self sendIOCtrlToChannel:channel Type:IOTYPE_USER_IPCAM_AUDIOSTOP Data:(char *)&camIndex DataSize:4];

            [stoppedChannel.recvAudioThreadLock lockWhenCondition:DONE];
            [stoppedChannel.recvAudioThreadLock unlock];
            [stoppedChannel.recvAudioThreadLock release];            
        
            [stoppedChannel.recvAudioThread release];
            stoppedChannel.recvAudioThread = nil;
        }   
        
        if (stoppedChannel.decAudioThread != nil) {
            
            [stoppedChannel.decAudioThreadLock lockWhenCondition:DONE];
            [stoppedChannel.decAudioThreadLock unlock];
            [stoppedChannel.decAudioThreadLock release];
            
            [stoppedChannel.decAudioThread release];
            stoppedChannel.decAudioThread = nil;
        }
    }   
}

- (void)startSoundToDevice:(NSInteger)channel{
    
    AVChannel *playedChannel = nil;
    
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) {
            playedChannel = ch;
            break;
        }
    }
    
    if (playedChannel != nil) {
        
        playedChannel.isRunningSendAudioThread = TRUE;   
        
        if (playedChannel.sendAudioThread == nil) {
            
            playedChannel.sendAudioThread = [[NSThread alloc] 
                                             initWithTarget:self 
                                             selector:@selector(doSendAudio:) 
                                             object:playedChannel];            
            [playedChannel.sendAudioThread start];  
        }
    } 
}

- (void)stopSoundToDevice:(NSInteger)channel {
    
    AVChannel *stoppedChannel = nil;
    
    for (AVChannel *ch in arrayAVChannel) {
        if (ch.avChannel == channel) {
            stoppedChannel = ch;
            break;
        }
    }
    
    
    if (stoppedChannel != nil) {
        
        stoppedChannel.isRunningSendAudioThread = FALSE;
        
        if (stoppedChannel.sendAudioThread != nil) {
            
            int camIndex = stoppedChannel.chIndexForSendAudio;
            [self sendIOCtrlToChannel:channel Type:IOTYPE_USER_IPCAM_SPEAKERSTOP Data:(char *)&camIndex DataSize:4];            
            
            avServExit(sessionID, stoppedChannel.chIndexForSendAudio);
            LOG(@"avServExit(%d, %d)", sessionID, stoppedChannel.chIndexForSendAudio);
            
            [stoppedChannel.sendAudioThreadLock lockWhenCondition:DONE];
            [stoppedChannel.sendAudioThreadLock unlock];
            [stoppedChannel.sendAudioThreadLock release];            
            
            [stoppedChannel.sendAudioThread release];
            stoppedChannel.sendAudioThread = nil;
        } 
    }
}

#pragma mark - Threading

- (void)doConnect {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [connectThreadLock lock];
    
    LOG(@"=== Connect Thread Start (%@) ===", uid);   
           
    NSInteger sid = -1;
    // NSInteger nRetryCount = 0;
    
    while (self.isRunningConnectingThread && self.sessionID < 0) {
        
        char *u = (char *)malloc(20);
        memcpy(u, [uid UTF8String], 20);
        
        
        char *aes = NULL;
        if (aesKey != nil && [aesKey length] > 0) {
            aes = (char *)malloc([aesKey length]);
            memcpy(aes, [aesKey UTF8String], [aesKey length]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            self.sessionState = CONNECTION_STATE_CONNECTING;
            LOG(@"session: CONNECTION_STATE_CONNECTING");

            if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeSessionStatus:)])
                [self.delegate camera:self didChangeSessionStatus:CONNECTION_STATE_CONNECTING];
            
        });
        
         sid = IOTC_Connect_ByUID(u);
        //sid = IOTC_Connect_ByUID2(u, aes, IOTC_ARBITRARY_MODE);
        NSLog(@"IOTC_CONNECT");
        _sessionID4ConnStop = IOTC_Get_SessionID();
        LOG(@"invoke IOTC_Connect_ByUID_Parallel(%@ , %zd)", uid, _sessionID4ConnStop );
        _connTimes++;
        if (u) free(u);
        if (aes) free(aes);
        
        LOG(@"IOTC_Connect_ByUID(%@) : %zd", uid, sid);
        
        _connFailErrCode = sid;
        if (sid >= 0) {
            
            self.sessionID = sid;
            
            struct st_SInfo Sinfo;
            int ret;
            
            ret = IOTC_Session_Check(sid, &Sinfo);
            
            if(Sinfo.Mode == 0){
                m_nConnectStatus = 0;
                LOG(@"Remote: [%s:%d; Mode=P2P]",Sinfo.RemoteIP, Sinfo.RemotePort);
            }
            else if(Sinfo.Mode == 1){
                m_nConnectStatus = 1;
                LOG(@"Remote: [%s:%d; Mode=RLY]",Sinfo.RemoteIP, Sinfo.RemotePort);
            }
            else if(Sinfo.Mode == 2){
                m_nConnectStatus = 2;
                LOG(@"Remote: [%s:%d; Mode=LAN]",Sinfo.RemoteIP, Sinfo.RemotePort);
            }
            
            LOG(@"Remote: [IOTCAPIVer=%@]", [self parseIOTCAPIsVerion:Sinfo.IOTCVersion]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.sessionState = CONNECTION_STATE_CONNECTED;
                //_natC = IOTC_Get_Nat_Type(0xFD86AA1C);

                if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeSessionStatus:)])
                    [self.delegate camera:self didChangeSessionStatus:CONNECTION_STATE_CONNECTED];
            });
            
        } else if (sid == IOTC_ER_UNLICENSE || sid == IOTC_ER_UNKNOWN_DEVICE || sid == IOTC_ER_CAN_NOT_FIND_DEVICE) {
            

            dispatch_async(dispatch_get_main_queue(), ^{
                    
                self.sessionState = CONNECTION_STATE_UNKNOWN_DEVICE;
                LOG(@"session: CONNECTION_STATE_UNKNOWN_DEVICE");

                if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeSessionStatus:)])
                    [self.delegate camera:self didChangeSessionStatus:CONNECTION_STATE_UNKNOWN_DEVICE];
            });
            
            break;
            
        } else if (sid == IOTC_ER_TIMEOUT) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.sessionState = CONNECTION_STATE_TIMEOUT;;
                LOG(@"session: CONNECTION_STATE_TIMEOUT");

                if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeSessionStatus:)])
                    [self.delegate camera:self didChangeSessionStatus:CONNECTION_STATE_TIMEOUT];
            });
            
            usleep(1000 * 1000);
            
        } else if (sid == IOTC_ER_CONNECT_IS_CALLING) {
            
            usleep(1000 * 1000);
            
        } else {
                        
            dispatch_async(dispatch_get_main_queue(), ^{
                         
                self.sessionState = CONNECTION_STATE_CONNECT_FAILED;
                LOG(@"session: CONNECTION_STATE_CONNECT_FAILED");

                if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeSessionStatus:)])
                    [self.delegate camera:self didChangeSessionStatus:CONNECTION_STATE_CONNECT_FAILED];
            });
            
            usleep(1000 * 1000);
        }
    }
    
    LOG(@"=== Connect Thread Exit (%@) ===", uid);   
    
    [connectThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

- (void)doCheckStatus
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [checkThreadLock lock];
    
    LOG(@"=== Check Status Thread Start (%@) ===", uid);

    // int retry = 0;
    int ret = -1;
    struct st_SInfo* info = malloc(sizeof(struct st_SInfo));
    
    while (isRunningCheckingThread) {
        
        if (sessionID < 0) {
            usleep(100 * 1000);
            continue;
        }
        else {
            
            ret = IOTC_Session_Check(sessionID, info);
            
            self.sessionMode = info->Mode;
            _natD = info->NatType;
            
            if (ret >= 0) {
                
                self.sessionState = CONNECTION_STATE_CONNECTED;
                            
            } else if (ret == IOTC_ER_REMOTE_TIMEOUT_DISCONNECT || ret == IOTC_ER_TIMEOUT) {

                LOG(@"IOTC_Session_Check(%@) : %d", uid, ret);

                dispatch_async(dispatch_get_main_queue(), ^{

                    self.sessionState = CONNECTION_STATE_TIMEOUT;
                    
                    for (AVChannel *ch in arrayAVChannel) {
                        ch.connectionState = CONNECTION_STATE_TIMEOUT;
                    }
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeSessionStatus:)])
                        [self.delegate camera:self didChangeSessionStatus:CONNECTION_STATE_TIMEOUT];
                });
                
            } else {

                LOG(@"IOTC_Session_Check(%@) : %d", uid, ret);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    self.sessionState = CONNECTION_STATE_CONNECT_FAILED;
                    
                    for (AVChannel *ch in arrayAVChannel) {
                        ch.connectionState = CONNECTION_STATE_CONNECT_FAILED;
                    }
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeSessionStatus:)])                
                        [self.delegate camera:self didChangeSessionStatus:CONNECTION_STATE_CONNECT_FAILED];
                });                
            }
                        
            usleep(1000 * 1000);
        }
    }
    
    free(info);
    
    LOG(@"=== Check Status Thread Exit (%@) ===", uid);
    
    [checkThreadLock unlockWithCondition:DONE];

    [pool release];
}

- (void)doStart:(AVChannel *) channel {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [channel.startThreadLock lock];
    
    LOG(@"=== Start Thread Start (%@) ===", uid);
    
    int avIndex = -1;
    int serverType = 0;
    
    while (channel.isRunningStartThread) {
    
        if (sessionID < 0) {
            usleep(100 * 1000);
            continue;
        }
        
        if (avIndex < 0) {
                        
            dispatch_async(dispatch_get_main_queue(), ^{
            
                channel.connectionState = CONNECTION_STATE_CONNECTING;

                if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeChannelStatus:ChannelStatus:)])
                    [self.delegate camera:self didChangeChannelStatus:channel.avChannel ChannelStatus:channel.connectionState];
            });  
            
            avIndex = avClientStart(sessionID, (char *)[channel.viewAcc UTF8String], (char *)[channel.viewPwd UTF8String], 30, (unsigned long *)&serverType, channel.avChannel);
            
            LOG(@"avClientStart(%@, %d, %s, %s, 60, %d) : %d", 
                self.uid, sessionID, [channel.viewAcc UTF8String], [channel.viewPwd UTF8String], channel.avChannel, avIndex);
            
            if (avIndex >= 0) {                
                
                LOG(@"AVClient(%d) service type:%d ", avIndex, serverType);
                
                channel.avIndex = avIndex;
                channel.serviceType = serverType;
                channel.audioCodec = (serverType & 4096) == 0 ? MEDIA_CODEC_AUDIO_SPEEX : MEDIA_CODEC_AUDIO_ADPCM;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    channel.connectionState = CONNECTION_STATE_CONNECTED;

                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeChannelStatus:ChannelStatus:)])
                        [self.delegate camera:self didChangeChannelStatus:channel.avChannel ChannelStatus:CONNECTION_STATE_CONNECTED];
                });              
                
                break;
                
            } else if (avIndex == AV_ER_WRONG_VIEWACCorPWD) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    channel.connectionState = CONNECTION_STATE_WRONG_PASSWORD;
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeChannelStatus:ChannelStatus:)])
                        [self.delegate camera:self didChangeChannelStatus:channel.avChannel ChannelStatus:CONNECTION_STATE_WRONG_PASSWORD];
                });
                
                break;
                
            } else if (avIndex == AV_ER_REMOTE_TIMEOUT_DISCONNECT || avIndex == AV_ER_TIMEOUT) {
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    channel.connectionState = CONNECTION_STATE_TIMEOUT;
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didChangeChannelStatus:ChannelStatus:)])
                        [self.delegate camera:self didChangeChannelStatus:channel.avChannel ChannelStatus:CONNECTION_STATE_TIMEOUT];
                });
                            
            } else {
                
                usleep(1000 * 1000);
            }         
        }
    }
    
    LOG(@"=== Start Thread Exit (%@) ===", uid);
    
    [channel.startThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

- (void)doRecvVideo:(AVChannel *) channel {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [channel.recvVideoThreadLock lock];

    LOG(@"=== Recv Video Thread Start (%@) ===", uid);

    int readSize = -1;
    char *recvBuf = malloc(RECV_VIDEO_BUFFER_SIZE);
    FRAMEINFO_t frmInfo = {0};
    unsigned int frmNo = 0, prevFrmNo = 0x0FFFFFFF;
    unsigned int timestamp;    
    int onlineNm = 0;
    unsigned long frameCount = 0;
    unsigned long incompleteFrameCount = 0;

    channel.videoBps = 0;

    while (channel.isRunningRecvVideoThread) {
        
        if (sessionID < 0 || channel.avIndex < 0) {
            usleep(10 * 1000);
            continue;
        }
            
        if (sessionID >= 0 && channel.avIndex >= 0 ) {            
                    
            unsigned int t = _getTickCount();
            onlineNm = frmInfo.onlineNum;
            
            if (t - timestamp > 1000) {
                
                int fps = channel.videoFps;
                int vbps = channel.videoBps;
                int abps = channel.audioBps;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                        
                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveFrameInfoWithVideoWidth:VideoHeight:VideoFPS:VideoBPS:AudioBPS:OnlineNm:FrameCount:IncompleteFrameCount:)])                
                        [self.delegate camera:self didReceiveFrameInfoWithVideoWidth:channel.videoWidth VideoHeight:channel.videoHeight VideoFPS:fps VideoBPS:vbps AudioBPS:abps OnlineNm:onlineNm FrameCount:frameCount IncompleteFrameCount:incompleteFrameCount];
                }); 
                
                timestamp = t;
                channel.videoFps = channel.videoBps = channel.audioBps = 0;
            }   
            
            readSize = avRecvFrameData(channel.avIndex, recvBuf, RECV_VIDEO_BUFFER_SIZE, (char *)&frmInfo, sizeof(frmInfo), &frmNo);
            
            if (readSize >= 0) {
                
                if (frmInfo.flags == IPC_FRAME_FLAG_IFRAME || frmNo == (prevFrmNo + 1)) {
                    
                    prevFrmNo = frmNo;
                
                    if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_H264) {
                    
                        ip_block_t *packet = malloc(sizeof(ip_block_t));
                        
                        if (ip_block_Alloc(packet, recvBuf, readSize) > 0) {
                                                    
                            packet->frameNo = frmNo;                    
                            packet->frmState = FRM_STAT_COMPLETE;
                            memcpy(&packet->frmInfo, &frmInfo, sizeof(FRAMEINFO_t));
                            
                            int cnt = ip_block_FifoCount(channel.videoQueue);
                            
                            if (cnt > 3000) {
                                
                                ip_block_t *tmp = ip_block_FifoGet(channel.videoQueue);
                                LOG(@"drop %@ frame", ip_block_isIFrame(tmp) ? @"I" : @"P");
                                ip_block_Release(tmp);
                                
                                while (ip_block_isFirstIFrame(channel.videoQueue) == 0) {
                                    tmp = ip_block_FifoGet(channel.videoQueue);
                                    LOG(@"drop P frame");
                                    ip_block_Release(tmp);
                                }
                            }
                            
                            ip_block_FifoPut(channel.videoQueue, packet);
                            
                        }
                        else if (packet) {
                            free(packet);
                        }
                        
                        // usleep(4 * 1000);
                        
                    } else if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_MPEG4) {
                        
                        ip_block_t *packet = malloc(sizeof(ip_block_t));
                        
                        if (ip_block_Alloc(packet, recvBuf, readSize) > 0) {
                            
                            packet->frameNo = frmNo;
                            packet->frmState = FRM_STAT_COMPLETE;
                            memcpy(&packet->frmInfo, &frmInfo, sizeof(FRAMEINFO_t));
                            ip_block_FifoPut(channel.videoQueue, packet);
                            
                        }
                        else if (packet) {
                            free(packet);
                        }
                        
                        // usleep(4 * 1000);
                        
                    } else if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_MJPEG) {
                        
                        char *imageFrame;
                        [channel getVideoBuffer:&imageFrame];
                        memcpy(imageFrame, recvBuf, readSize);
                        
                        NSData *data = [[NSData alloc] initWithBytes:recvBuf length:readSize];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveJPEGDataFrame:DataSize:)])
                                [self.delegate camera:self didReceiveJPEGDataFrame:(const char *)recvBuf DataSize:readSize];
                            
                            if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveJPEGDataFrame:DataSize:)])
                                [self.delegateForMonitor camera:self didReceiveJPEGDataFrame:(const char *)recvBuf DataSize:readSize];
                            
                            if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveJPEGDataFrame2:)])
                                [self.delegateForMonitor camera:self didReceiveJPEGDataFrame2:data];
                        });
                        
                        if ([self dataIsValidJPEG:data]) {
                            UIImage *image = [[UIImage alloc] initWithData:data];
                            channel.videoWidth = image.size.width;
                            channel.videoHeight = image.size.height;
                            channel.videoFps++;
                            [image release];
                        }
                        
                        [data release];
                        
                        // usleep(4 * 1000);
                    }
                }
                
                channel.videoBps += (readSize * 8);
                frameCount++;
                
            } else if (readSize == AV_ER_BUFPARA_MAXSIZE_INSUFF) {
                
                continue;
                
            } else if (readSize ==  AV_ER_MEM_INSUFF) {
                
                frameCount++;
                incompleteFrameCount++;
                LOG("avRecvFrameData() : AV_ER_MEM_INSUFF");
                
            } else if(readSize == AV_ER_INCOMPLETE_FRAME) {
                
                /*
                ip_block_t *packet = malloc(sizeof(ip_block_t));
                
                if (ip_block_Alloc(packet, recvBuf, readSize) > 0) {

                    packet->frameNo = frmNo;                    
                    packet->frmState = FRM_STAT_INCOMPLETE;
                    ip_block_FifoPut(channel.videoQueue, packet);                
                }
                else if (packet) free(packet);
                */
                
                frameCount++;
                incompleteFrameCount++;
                LOG("avRecvFrameData() : AV_ER_INCOMPLETE_FRAME");

            } else if (readSize == AV_ER_LOSED_THIS_FRAME) {
				
                /*
                ip_block_t *packet = malloc(sizeof(ip_block_t));
                
                if (ip_block_Alloc(packet, recvBuf, readSize) > 0) {

                packet->frameNo = frmNo;                    
                packet->frmState = FRM_STAT_LOSED;
                ip_block_FifoPut(channel.videoQueue, packet);
                }
                else if (packet) free(packet);
                */
                
                frameCount++;
                incompleteFrameCount++;
                LOG("avRecvFrameData() : AV_ER_LOSED_THIS_FRAME");
                
			} else if (readSize == AV_ER_DATA_NOREADY) {
                
                usleep(32 * 1000);
                //LOG("avRecvFrameData() : AV_ER_DATA_NOREADY");

            } else {
                
                usleep(4 * 1000);
                LOG("avRecvFrameData() : %d", readSize);

            }
        }
    }
    
    free(recvBuf);
    ip_block_FifoEmpty(channel.videoQueue);

    LOG(@"=== RecvVideo Thread Exit ===");
    
    [channel.recvVideoThreadLock unlockWithCondition:DONE];
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
                
        [channel.recvVideoThread release];
        channel.recvVideoThread = nil;
        
        LOG(@"=== RecvVideo Thread Exit @ main ===");
        
    });
    */
    
    [pool release];
}

#ifdef AVRECVFRAMEDATA2
- (void)doRecvVideo2:(AVChannel *) channel {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [channel.recvVideoThreadLock lock];
    
    LOG(@"=== Recv Video Thread Start (%@) ===", uid);
    
    int readSize = -1;
    char *recvBuf = malloc(RECV_VIDEO_BUFFER_SIZE);
    FRAMEINFO_t frmInfo = {0};
    unsigned int frmNo = 0, prevFrmNo = 0x0FFFFFFF;
    unsigned int timestamp;
    int onlineNm = 0;
    unsigned long frameCount = 0;
    unsigned long incompleteFrameCount = 0;
    
    int outBufSize = 0, outFrmSize = 0, outFrmInfoSize = 0;
    
    channel.videoBps = 0;
    ip_block_FifoEmpty(channel.videoQueue);
    
    if (sessionID >= 0 && channel.avIndex >= 0)
        avClientCleanBuf(channel.avIndex);

    while (channel.isRunningRecvVideoThread) {
        
        if (sessionID < 0 || channel.avIndex < 0) {
            usleep(10 * 1000);
            continue;
        }
        
        if (sessionID >= 0 && channel.avIndex >= 0 ) {
            
            unsigned int t = _getTickCount();
            onlineNm = frmInfo.onlineNum;
            
            if (t - timestamp > 1000) {
                
                int fps = channel.videoFps;
                int vbps = channel.videoBps;
                int abps = channel.audioBps;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveFrameInfoWithVideoWidth:VideoHeight:VideoFPS:VideoBPS:AudioBPS:OnlineNm:FrameCount:IncompleteFrameCount:)])
                        [self.delegate camera:self didReceiveFrameInfoWithVideoWidth:channel.videoWidth VideoHeight:channel.videoHeight VideoFPS:fps VideoBPS:vbps AudioBPS:abps OnlineNm:onlineNm FrameCount:frameCount IncompleteFrameCount:incompleteFrameCount];
                });
                
                timestamp = t;
                channel.videoFps = channel.videoBps = channel.audioBps = 0;
            }
            
            readSize = avRecvFrameData2(channel.avIndex, recvBuf, RECV_VIDEO_BUFFER_SIZE, &outBufSize, &outFrmSize, (char *)&frmInfo, sizeof(frmInfo), &outFrmInfoSize, &frmNo);

            // readSize = avRecvFrameData(channel.avIndex, recvBuf, RECV_VIDEO_BUFFER_SIZE, (char *)&frmInfo, sizeof(frmInfo), &frmNo);

            // if (readSize != -20012) LOG("  -> FNO: %d, OBS: %d, OFS: %d, OFIS: %d, RV: %d", frmNo, outBufSize, outFrmSize, outFrmInfoSize, readSize);

            if (readSize >= 0) {
    
                if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_H264) {
                    
                    if (frmInfo.flags == IPC_FRAME_FLAG_IFRAME || frmNo == (prevFrmNo + 1)) {
                        
                        prevFrmNo = frmNo;

                        ip_block_t *packet = malloc(sizeof(ip_block_t));
                    
                        if (ip_block_Alloc(packet, recvBuf, readSize) > 0) {
                            
                            packet->frameNo = frmNo;
                            packet->frmState = FRM_STAT_COMPLETE;
                            memcpy(&packet->frmInfo, &frmInfo, sizeof(FRAMEINFO_t));
                            
                            ip_block_FifoPut(channel.videoQueue, packet);
                            
                        }
                        else if (packet) {
                            free(packet);
                        }
                    } else {
                        LOG("Incorrect frame no(%d), prev:%d -> drop frame", frmNo, prevFrmNo);
                    }
                    
                } else if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_MPEG4) {
                    
                    if (frmInfo.flags == IPC_FRAME_FLAG_IFRAME || frmNo == (prevFrmNo + 1)) {
                        
                        prevFrmNo = frmNo;
                        
                        ip_block_t *packet = malloc(sizeof(ip_block_t));
                        
                        if (ip_block_Alloc(packet, recvBuf, readSize) > 0) {
                            
                            packet->frameNo = frmNo;
                            packet->frmState = FRM_STAT_COMPLETE;
                            memcpy(&packet->frmInfo, &frmInfo, sizeof(FRAMEINFO_t));
                            ip_block_FifoPut(channel.videoQueue, packet);
                            
                        }
                        else if (packet) {
                            free(packet);
                        }
                    }
                                        
                } else if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_MJPEG) {
                    
                    char *imageFrame;
                    [channel getVideoBuffer:&imageFrame];
                    memcpy(imageFrame, recvBuf, readSize);

                    NSData *data = [[NSData alloc] initWithBytes:recvBuf length:readSize];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveJPEGDataFrame:DataSize:)])
                            [self.delegate camera:self didReceiveJPEGDataFrame:(const char *)recvBuf DataSize:readSize];
                        
                        if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveJPEGDataFrame:DataSize:)])
                            [self.delegateForMonitor camera:self didReceiveJPEGDataFrame:(const char *)recvBuf DataSize:readSize];
                        
                        if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveJPEGDataFrame2:)])
                            [self.delegateForMonitor camera:self didReceiveJPEGDataFrame2:data];
                    });
                    
                    if ([self dataIsValidJPEG:data]) {
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        channel.videoWidth = image.size.width;
                        channel.videoHeight = image.size.height;
                        channel.videoFps++;
                        channel.videoDataSize = readSize;
                        [image release];
                        LOG(@"JPEG data verified - Camera.m");
                    } else {
                        NSLog(@"JPEG data broken - Camera.m");
                    }
                    
                    [data release];
                }
                
                channel.videoBps += (readSize * 8);
                channel.videoCodec = frmInfo.codec_id;
                frameCount++;
                
            } else if (readSize == AV_ER_BUFPARA_MAXSIZE_INSUFF) {
                
                continue;
                
            } else if (readSize ==  AV_ER_MEM_INSUFF) {
                
                frameCount++;
                incompleteFrameCount++;
                LOG("avRecvFrameData() : AV_ER_MEM_INSUFF");
                
            } else if(readSize == AV_ER_INCOMPLETE_FRAME) {
                
                frameCount++;
                channel.videoBps += (outBufSize * 8);
                                
                if (outFrmInfoSize == 0 || (outFrmSize * 0.9) > outBufSize || frmInfo.flags == IPC_FRAME_FLAG_PBFRAME) {
                    LOG(@" ---> %@ frame, OFS(%d) * 0.9 = %d > OBS(%d)", (frmInfo.flags == IPC_FRAME_FLAG_IFRAME ? @"I" : @"P"), outFrmSize, (int)(outFrmSize * 0.9), outBufSize);
                    incompleteFrameCount++;
                    continue;
                }
                
                if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_MJPEG) {
                    
                    incompleteFrameCount++;
                    continue;
                    
                    /*
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveJPEGDataFrame:DataSize:)])
                            [self.delegate camera:self didReceiveJPEGDataFrame:(const char *)recvBuf DataSize:outFrmSize];
                        
                        
                        if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveJPEGDataFrame:DataSize:)])
                            [self.delegateForMonitor camera:self didReceiveJPEGDataFrame:(const char *)recvBuf DataSize:outFrmSize];
                        
                    });
                    
                    NSData *data = [[NSData alloc] initWithBytes:recvBuf length:outFrmSize];
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    channel.videoWidth = image.size.width;
                    channel.videoHeight = image.size.height;
                    channel.videoFps++;
                    
                    [data release];
                    [image release];
                                                            
                    LOG("avRecvFrameData() : AV_ER_INCOMPLETE_FRAME - MJPEG");
                    */
                    
                } else if (frmInfo.codec_id == MEDIA_CODEC_VIDEO_MPEG4 || frmInfo.codec_id == MEDIA_CODEC_VIDEO_H264) {
                    
                    if (frmInfo.flags == IPC_FRAME_FLAG_IFRAME || frmNo == (prevFrmNo + 1)) {

                        prevFrmNo = frmNo;
                        
                        ip_block_t *packet = malloc(sizeof(ip_block_t));
                        
                        if (ip_block_Alloc(packet, recvBuf, outFrmSize) > 0) {
                            
                            packet->frameNo = frmNo;
                            packet->frmState = FRM_STAT_COMPLETE;
                            ip_block_FifoPut(channel.videoQueue, packet);
                        }
                        else if (packet) free(packet);
                                                                        
                    } else {
                        incompleteFrameCount++;
                        LOG("Incorrect frame no(%d), prev:%d -> AV_ER_INCOMPLETE_FRAME", frmNo, prevFrmNo);
                    }
                
                } else {
                    
                    incompleteFrameCount++;
                    LOG("avRecvFrameData() : AV_ER_INCOMPLETE_FRAME - UNKNOWN");
                }
                
            } else if (readSize == AV_ER_LOSED_THIS_FRAME) {

                frameCount++;
                incompleteFrameCount++;
                LOG(@"avRecvFrameData() : AV_ER_LOSED_THIS_FRAME - %d", frmNo);
                
			} else if (readSize == AV_ER_DATA_NOREADY) {
                
                usleep(32 * 1000);
                //LOG("avRecvFrameData() : AV_ER_DATA_NOREADY");
                
            } else {
                
                LOG("avRecvFrameData() : %d", readSize);
            }
        }
    }
    
    if (sessionID >= 0 && channel.avIndex >= 0)
        avClientCleanBuf(channel.avIndex);
    
    free(recvBuf);
    ip_block_FifoEmpty(channel.videoQueue);

    LOG(@"=== RecvVideo2 Thread Exit ===");
    
    [channel.recvVideoThreadLock unlockWithCondition:DONE];
    
    [pool release];
}
#endif

- (void)doDecodeVideo:(AVChannel *)channel
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [channel.decVideoThreadLock lock];
    
    LOG(@"=== Decode Video Thread Start (%@) ===", uid);    
      
    ip_block_t *pAvFrame = NULL;
	// char bWaitI = 1;
	int avFrameSize = 0;
	unsigned int firstTimeStampFromDevice = 0, firstTimeStampFromLocal = 0;
    int sleepTime;
    int nDelayFrameCnt = 0;
    unsigned int t = 0;
    unsigned int Rt = 0;
   

     H264iPhone *h264iphone = [[H264iPhone alloc]init];
    
#ifdef MJ4
    h264 *h264Dec = nil;
    mpeg4 *mpeg4Dec = nil;
#else
    int consumedBytes = 0;
	int arrFramePara[4] = {0};
    //InitDecoder();
    [h264iphone InitDecoder];
#endif
    
 
    channel.videoFps = 0;
    
    char *imageFrame = NULL;
    int imageSize = 0;
    
    imageSize = [channel getVideoBuffer:&imageFrame];
    
    while (channel.isRunningDecVideoThread && imageFrame != NULL) {
     
        if (sessionID < 0 || channel.avIndex < 0) {
            usleep(10 * 1000);
            continue;
        }
        
        if(ip_block_FifoCount(channel.videoQueue) > 0) {
            
			if (pAvFrame != NULL) 
                ip_block_Release(pAvFrame);
			
			pAvFrame = ip_block_FifoGet(channel.videoQueue);

			if(pAvFrame == NULL)
                continue;        
			
			avFrameSize = pAvFrame->buff_size;
            
            /*
			if ((int)pAvFrame->frmState != FRM_STAT_COMPLETE)
                bWaitI = 1;
            
			if (bWaitI == 1){
                
				if ((ip_block_isIFrame(pAvFrame) > 0) && (int)pAvFrame->frmState == FRM_STAT_COMPLETE) 
                    bWaitI = 0;
				else
                    avFrameSize = 0;
			}
            */
		}
        else  {
            usleep(4 * 1000);
        }        
        
        
        if (ip_block_isIFrame(pAvFrame) <= 0 && nDelayFrameCnt >= 30) {
            continue;
        } 
        

#ifdef MJ4
        
            if (avFrameSize > 0) {
                
                int w = 0;
                int h = 0;
                
                
                if (pAvFrame->frmInfo.codec_id == MEDIA_CODEC_VIDEO_H264) {
                    
                    if (h264Dec == nil) h264Dec = [[h264 alloc] init];
                    
                    [h264Dec decode:pAvFrame->pBuffer SizeOfBufferToDecode:pAvFrame->buff_size   decodedBuffer:imageFrame decodedBufferSize:&imageSize imgWidth:&w imageHeight:&h];
                }
                
                
                if (pAvFrame->frmInfo.codec_id == MEDIA_CODEC_VIDEO_MPEG4) {
                    
                    if (mpeg4Dec == nil) {
                        
                        int w = ((pAvFrame->pBuffer[0x17] & 0x0F) << 9 ) | ((pAvFrame->pBuffer[0x18] & 0xFF) << 1 ) | ((pAvFrame->pBuffer[0x19] & 0x80) >> 7 ) ;
                        int h = ((pAvFrame->pBuffer[0x19] & 0x3F) << 7 ) | ((pAvFrame->pBuffer[0x1A] & 0xFE) >> 1 );
                        
                        mpeg4Dec = [[mpeg4 alloc] initWithWidth:w Height:h];
                    }
                    
                    // char *bufWithHeader = malloc(MPEG4_VOL_SIZE + pAvFrame->buff_size);
                    // memcpy(bufWithHeader, mpeg4_vol_header, MPEG4_VOL_SIZE);
                    // memcpy(&bufWithHeader[MPEG4_VOL_SIZE], pAvFrame->pBuffer, pAvFrame->buff_size);

                    // [mpeg4Dec decode:bufWithHeader SizeOfBufferToDecode:pAvFrame->buff_size + MPEG4_VOL_SIZE decodedBuffer:imageFrame decodedBufferSize:&imageSize imgWidth:&w imageHeight:&h];
                    
                    // free(bufWithHeader);
                    
                    [mpeg4Dec decode:pAvFrame->pBuffer SizeOfBufferToDecode:pAvFrame->buff_size decodedBuffer:imageFrame decodedBufferSize:&imageSize imgWidth:&w imageHeight:&h];
                }
                
                if (imageSize > 0 && w > 0 && h > 0) {
             
                    channel.videoWidth = w;
                    channel.videoHeight = h;
             
                    if (pAvFrame != NULL && firstTimeStampFromLocal != 0 && firstTimeStampFromDevice != 0) {
             
                        unsigned int t = _getTickCount();
                        sleepTime = (firstTimeStampFromLocal + (pAvFrame->frmInfo.timestamp - firstTimeStampFromDevice)) - t;
             
                        //LOG(@"decode %@ frame, sleeptime (%d) = (t0 (%u) + (Tn(%u) - T0(%u) %d ) - tn'(%u)", (ip_block_isIFrame(pAvFrame) == 1 ? @"I" : "P"),sleepTime, firstTimeStampFromLocal, pAvFrame->frmInfo.timestamp, firstTimeStampFromDevice, pAvFrame->frmInfo.timestamp - firstTimeStampFromDevice, t);
             
                        if (sleepTime >= 0 && sleepTime < 3000) {
             
                            usleep(sleepTime * 1000);
                            firstTimeStampFromLocal = firstTimeStampFromLocal - ip_block_FifoCount(channel.videoQueue);
             
                            nDelayFrameCnt = 0;
                            
                        } else {
             
                            firstTimeStampFromDevice = pAvFrame->frmInfo.timestamp;
                            firstTimeStampFromLocal = t;
             
                            nDelayFrameCnt++;
                        }
                    }
             
                    if (firstTimeStampFromDevice == 0 || firstTimeStampFromLocal == 0) {
                        firstTimeStampFromDevice = pAvFrame->frmInfo.timestamp;
                        firstTimeStampFromLocal = _getTickCount();
                    }
             
                    channel.videoFps++;
             
                    dispatch_async(dispatch_get_main_queue(), ^{
             
                        if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveRawDataFrame:VideoWidth:VideoHeight:)])
                            [self.delegate camera:self didReceiveRawDataFrame:imageFrame VideoWidth:channel.videoWidth VideoHeight:channel.videoHeight];
             
                        if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveRawDataFrame:VideoWidth:VideoHeight:)])
                            [self.delegateForMonitor camera:self didReceiveRawDataFrame:imageFrame VideoWidth:channel.videoWidth VideoHeight:channel.videoHeight];
                    });
                }
            }        
        
#else

            
            while (avFrameSize > 0) {

                //consumedBytes = DecoderNal((uint8_t *)pAvFrame->pBuffer, pAvFrame->buff_size, arrFramePara, (uint8_t *)imageFrame);
                
                 consumedBytes = [h264iphone DecoderNal:(uint8_t *)pAvFrame->pBuffer :pAvFrame->buff_size :arrFramePara :(uint8_t *)imageFrame];
                                
                if (consumedBytes < 0) {
                    avFrameSize=0;
                    break;
                }
                
                
                if (!channel.isRunningDecVideoThread) {
                    ip_block_Release(pAvFrame);
                    break;
                }

                
                if (arrFramePara[0] > 0) {
                    
                    if (arrFramePara[2] > 0){
                        
                        channel.videoWidth = arrFramePara[2];
                        channel.videoHeight = arrFramePara[3];
                    }
                    
                    if (pAvFrame != NULL && firstTimeStampFromLocal != 0 && firstTimeStampFromDevice != 0) {
                        
                        t = _getTickCount();
                        sleepTime = (firstTimeStampFromLocal + (pAvFrame->frmInfo.timestamp - firstTimeStampFromDevice)) - t - Rt;

                        LOG(@"decode %@ frame, sleeptime (%d) = (t0 (%u) + (Tn(%u) - T0(%u) %d ) - tn'(%u)", (ip_block_isIFrame(pAvFrame) == 1 ? @"I" : @"P"), sleepTime, firstTimeStampFromLocal, pAvFrame->frmInfo.timestamp, firstTimeStampFromDevice, pAvFrame->frmInfo.timestamp - firstTimeStampFromDevice, t);
                        
                        if (sleepTime >= 0) {
                            
                            if (sleepTime > 1000) sleepTime = 1000;
                            usleep(sleepTime * 1000);
                            
                            firstTimeStampFromLocal = firstTimeStampFromLocal - ip_block_FifoCount(channel.videoQueue);
                            
                            nDelayFrameCnt = 0;
                            Rt = 0;
                            
                        } else if (sleepTime < 0 && sleepTime > -100) {
                          
                            firstTimeStampFromDevice = pAvFrame->frmInfo.timestamp;
                            firstTimeStampFromLocal = t;
                            
                        } else {
                            
                            firstTimeStampFromDevice = pAvFrame->frmInfo.timestamp;
                            firstTimeStampFromLocal = t;                        
                            
                            nDelayFrameCnt++;
                        }
                    }
                    
                    if (firstTimeStampFromDevice == 0 || firstTimeStampFromLocal == 0) {
                        firstTimeStampFromDevice = pAvFrame->frmInfo.timestamp;
                        firstTimeStampFromLocal = _getTickCount();
                    }
                    
                    channel.videoFps++;
                    channel.videoDataSize = avFrameSize;
                    
                    t = _getTickCount();

                    dispatch_async(dispatch_get_main_queue(), ^{
                                            
                        if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveRawDataFrame:VideoWidth:VideoHeight:)]) {
                            [self.delegate camera:self didReceiveRawDataFrame:imageFrame VideoWidth:channel.videoWidth VideoHeight:channel.videoHeight];                    
                        }
                        
                        if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveRawDataFrame:VideoWidth:VideoHeight:)]) {
                            [self.delegateForMonitor camera:self didReceiveRawDataFrame:imageFrame VideoWidth:channel.videoWidth VideoHeight:channel.videoHeight];
                        }
                    });
                    
                    Rt += _getTickCount() - t;
                    
                }
                
                avFrameSize -= consumedBytes;
                
                if (avFrameSize > 0) {
                    memcpy(pAvFrame->pBuffer, pAvFrame->pBuffer + consumedBytes, avFrameSize);
                }
                else {
                    avFrameSize=0;
                }
            }
        
#endif
        
    }
    
#ifdef MJ4
    if (h264Dec != nil) {
        [h264Dec release];
        h264Dec = nil;
    }    
    if (mpeg4Dec != nil) {
        [mpeg4Dec release];
        mpeg4Dec = nil;
    }
#else
    //    UninitDecoder();
    
    if (h264iphone != nil) {
        [h264iphone UninitDecoder];
        [h264iphone release];
        h264iphone = nil;
    }
#endif
    
    LOG(@"=== Decode Video Thread Exit (%@) ===", uid);
    
    [channel.decVideoThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

- (void)doDecodeVideo2:(AVChannel *)channel
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [channel.decVideoThreadLock lock];
    
    LOG(@"=== Decode Video 2 Thread Start (%@) ===", uid);
    
    ip_block_t *pAvFrame = NULL;
	int avFrameSize = 0;
    
    channel.videoFps = 0;
    
    char *imageFrame = NULL;
    int imageSize = 0;
    
    imageSize = [channel getVideoBuffer:&imageFrame];
    
    unsigned int firstTimeStampFromDevice = 0, firstTimeStampFromLocal = 0;
    unsigned int lastFrameTimeStamp = 0;
    int delayTime = 0;
    unsigned int t = 0;

#ifdef MJ4
    h264 *h264Dec = nil;
    mpeg4 *mpeg4Dec = nil;
#else
    int consumedBytes = 0;
	int arrFramePara[4] = {0};
    
    H264iPhone *h264iphone = [[H264iPhone alloc]init];
    [h264iphone InitDecoder];
    
#endif
    
    while (channel.isRunningDecVideoThread && imageFrame != NULL) {
        
        if (sessionID < 0 || channel.avIndex < 0) {
            usleep(10 * 1000);
            continue;
        }
        
        if(ip_block_FifoCount(channel.videoQueue) > 0) {
            
			if (pAvFrame != NULL)
                ip_block_Release(pAvFrame);
			
			pAvFrame = ip_block_FifoGet(channel.videoQueue);
            
			if(pAvFrame == NULL)
                continue;
			
			avFrameSize = pAvFrame->buff_size;
            
		}
        else  {
            usleep(32 * 1000);
        }
        
        while (ip_block_FifoCount(channel.videoQueue) > 0 && delayTime > 1000) {
            
            ip_block_t *tmp = NULL;
            int skipTime = 0;
            
            // drop the first frame, whether it's I or P frame
            tmp = ip_block_FifoGet(channel.videoQueue);
            skipTime += (tmp->frmInfo.timestamp - lastFrameTimeStamp);
            LOG(@"low decode performance, drop %@ frame, skip time: %d, total skip: %d", (ip_block_isIFrame(tmp) == 1 ? @"I" : @"P"), (tmp->frmInfo.timestamp - lastFrameTimeStamp), skipTime);
            lastFrameTimeStamp = tmp->frmInfo.timestamp;
            ip_block_Release(tmp);
            
            // check and drop all the following P frame
            while (true) {
                int r = ip_block_isFirstIFrame(channel.videoQueue);
                
                if (r == 0) {
                    tmp = ip_block_FifoGet(channel.videoQueue);
                    skipTime += (tmp->frmInfo.timestamp - lastFrameTimeStamp);
                    LOG(@"low decode performance, drop P frame, skip time: %d, total skip: %d", (tmp->frmInfo.timestamp - lastFrameTimeStamp), skipTime);
                    lastFrameTimeStamp = tmp->frmInfo.timestamp;
                    ip_block_Release(tmp);
                } else break;
            }
            
            delayTime -= skipTime;
            LOG("delayTime: %d", delayTime);
        }


#ifdef MJ4
         
         if (avFrameSize > 0) {
         
             int w = 0;
             int h = 0;
         
         
             if (pAvFrame->frmInfo.codec_id == MEDIA_CODEC_VIDEO_H264) {
             
                 if (h264Dec == nil) h264Dec = [[h264 alloc] init];
             
                 [h264Dec decode:pAvFrame->pBuffer SizeOfBufferToDecode:pAvFrame->buff_size decodedBuffer:imageFrame decodedBufferSize:&imageSize imgWidth:&w imageHeight:&h];
             }
             
             
             if (pAvFrame->frmInfo.codec_id == MEDIA_CODEC_VIDEO_MPEG4) {
             
                 if (mpeg4Dec == nil) {
             
                     int w = ((pAvFrame->pBuffer[0x17] & 0x0F) << 9 ) | ((pAvFrame->pBuffer[0x18] & 0xFF) << 1 ) | ((pAvFrame->pBuffer[0x19] & 0x80) >> 7 ) ;
                     int h = ((pAvFrame->pBuffer[0x19] & 0x3F) << 7 ) | ((pAvFrame->pBuffer[0x1A] & 0xFE) >> 1 );
             
                     mpeg4Dec = [[mpeg4 alloc] initWithWidth:w Height:h];
                 }
             
                 // char *bufWithHeader = malloc(MPEG4_VOL_SIZE + pAvFrame->buff_size);
                 // memcpy(bufWithHeader, mpeg4_vol_header, MPEG4_VOL_SIZE);
                 // memcpy(&bufWithHeader[MPEG4_VOL_SIZE], pAvFrame->pBuffer, pAvFrame->buff_size);
             
                 // [mpeg4Dec decode:bufWithHeader SizeOfBufferToDecode:pAvFrame->buff_size + MPEG4_VOL_SIZE decodedBuffer:imageFrame decodedBufferSize:&imageSize imgWidth:&w imageHeight:&h];
             
                 // free(bufWithHeader);
             
                 [mpeg4Dec decode:pAvFrame->pBuffer SizeOfBufferToDecode:pAvFrame->buff_size decodedBuffer:imageFrame decodedBufferSize:&imageSize imgWidth:&w imageHeight:&h];
                 
                 LOG("MPEG4 decode width:%d, height:%d", w, h);
             }
             
             if (imageSize > 0 && w > 0 && h > 0) {
             
                 channel.videoWidth = w;
                 channel.videoHeight = h;
             
                 if (pAvFrame != NULL && firstTimeStampFromLocal != 0 && firstTimeStampFromDevice != 0) {
                     
                     t = _getTickCount();
                     int sleepTime = (firstTimeStampFromLocal + (pAvFrame->frmInfo.timestamp - firstTimeStampFromDevice)) - t;
                     delayTime = (sleepTime * -1);
                     
                     LOG(@"%@ frame, sleeptime(%d)=(t0 (%u)+(Tn(%u)-T0(%u) %d)-tn'(%u), deltaT:%d", (ip_block_isIFrame(pAvFrame) == 1 ? @"I" : @"P"), sleepTime, firstTimeStampFromLocal, pAvFrame->frmInfo.timestamp, firstTimeStampFromDevice, pAvFrame->frmInfo.timestamp - firstTimeStampFromDevice, t, (pAvFrame->frmInfo.timestamp - lastFrameTimeStamp));
                     
                     if (sleepTime >= 0) {
                         
                         // sometimes, the time interval from device will large than 1 second, must reset the base timestamp
                         if ((pAvFrame->frmInfo.timestamp - lastFrameTimeStamp) > 1000) {
                             firstTimeStampFromDevice = pAvFrame->frmInfo.timestamp;
                             firstTimeStampFromLocal = t;
                             LOG("RESET base timestamp");
                             
                             if (sleepTime > 1000) sleepTime = 33;
                         }
                         
                         if (sleepTime > 1000) sleepTime = 1000;
                         usleep(sleepTime * 1000);
                     }
                     
                     lastFrameTimeStamp = pAvFrame->frmInfo.timestamp;
                 }
                 
                 if (firstTimeStampFromDevice == 0 || firstTimeStampFromLocal == 0 || lastFrameTimeStamp == 0) {
                     firstTimeStampFromDevice = lastFrameTimeStamp = pAvFrame->frmInfo.timestamp;
                     firstTimeStampFromLocal = _getTickCount();
                 }
             
                 channel.videoFps++;
                 channel.videoDataSize = avFrameSize;
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
             
                     if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveRawDataFrame:VideoWidth:VideoHeight:)])
                         [self.delegate camera:self didReceiveRawDataFrame:imageFrame VideoWidth:channel.videoWidth VideoHeight:channel.videoHeight];
             
                     if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveRawDataFrame:VideoWidth:VideoHeight:)])
                         [self.delegateForMonitor camera:self didReceiveRawDataFrame:imageFrame VideoWidth:channel.videoWidth VideoHeight:channel.videoHeight];
                });
            }
         }
        
#else
         
        while (avFrameSize > 0) {
            
            //consumedBytes = DecoderNal((uint8_t *)pAvFrame->pBuffer, pAvFrame->buff_size, arrFramePara, (uint8_t *)imageFrame);
            consumedBytes = [h264iphone DecoderNal:(uint8_t *)pAvFrame->pBuffer :pAvFrame->buff_size :arrFramePara :(uint8_t *)imageFrame];
            
            if (consumedBytes < 0) {
                avFrameSize=0;
                break;
            }
            
            
            if (!channel.isRunningDecVideoThread) {
                ip_block_Release(pAvFrame);
                break;
            }
            
            
            if (arrFramePara[0] > 0) {
                
                if (arrFramePara[2] > 0){
                    
                    channel.videoWidth = arrFramePara[2];
                    channel.videoHeight = arrFramePara[3];
                }
                
                if (pAvFrame != NULL && firstTimeStampFromLocal != 0 && firstTimeStampFromDevice != 0) {
                    
                    t = _getTickCount();
                    int sleepTime = (firstTimeStampFromLocal + (pAvFrame->frmInfo.timestamp - firstTimeStampFromDevice)) - t;
                    delayTime = (sleepTime * -1);
                    
                    LOG(@"%@ frame, sleeptime(%d)=(t0 (%u)+(Tn(%u)-T0(%u) %d)-tn'(%u), deltaT:%d", (ip_block_isIFrame(pAvFrame) == 1 ? @"I" : @"P"), sleepTime, firstTimeStampFromLocal, pAvFrame->frmInfo.timestamp, firstTimeStampFromDevice, pAvFrame->frmInfo.timestamp - firstTimeStampFromDevice, t, (pAvFrame->frmInfo.timestamp - lastFrameTimeStamp));
                    
                    if (sleepTime >= 0) {
                        
                        // sometimes, the time interval from device will large than 1 second, must reset the base timestamp
                        if ((pAvFrame->frmInfo.timestamp - lastFrameTimeStamp) > 1000) {
                            firstTimeStampFromDevice = pAvFrame->frmInfo.timestamp;
                            firstTimeStampFromLocal = t;
                            LOG("RESET base timestamp");
                            
                            if (sleepTime > 1000) sleepTime = 33;
                        }

                        if (sleepTime > 1000) sleepTime = 1000;
                        usleep(sleepTime * 1000);
                    }
                    
                    lastFrameTimeStamp = pAvFrame->frmInfo.timestamp;
                }
                
                if (firstTimeStampFromDevice == 0 || firstTimeStampFromLocal == 0 || lastFrameTimeStamp == 0) {
                    firstTimeStampFromDevice = lastFrameTimeStamp = pAvFrame->frmInfo.timestamp;
                    firstTimeStampFromLocal = _getTickCount();
                }
                
                
                channel.videoFps++;
                channel.videoDataSize = avFrameSize;
                                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveRawDataFrame:VideoWidth:VideoHeight:)]) {
                        [self.delegate camera:self didReceiveRawDataFrame:imageFrame VideoWidth:channel.videoWidth VideoHeight:channel.videoHeight];
                    }
                    
                    if (self.delegateForMonitor && [self.delegateForMonitor respondsToSelector:@selector(camera:didReceiveRawDataFrame:VideoWidth:VideoHeight:)]) {
                        [self.delegateForMonitor camera:self didReceiveRawDataFrame:imageFrame VideoWidth:channel.videoWidth VideoHeight:channel.videoHeight];
                    }
                });
                            
            }
            
            avFrameSize -= consumedBytes;
            
            if (avFrameSize > 0) {
                memcpy(pAvFrame->pBuffer, pAvFrame->pBuffer + consumedBytes, avFrameSize);
            }
            else {
                avFrameSize=0;
            }
        }
        
#endif
        
    }
    
#ifdef MJ4
    if (h264Dec != nil) {
        [h264Dec release];
        h264Dec = nil;
    }
    if (mpeg4Dec != nil) {
        [mpeg4Dec release];
        mpeg4Dec = nil;
    }
#else
    if (h264iphone != nil) {
        [h264iphone UninitDecoder];
        [h264iphone release];
        h264iphone = nil;
    }
#endif
    
    LOG(@"=== Decode Video Thread Exit (%@) ===", uid);
    
    [channel.decVideoThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

- (void)doRecvAudio:(AVChannel *) channel {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [channel.recvAudioThreadLock lock];
    
    LOG(@"=== RecvAudio Thread Start (%@) ===", uid);
    
    OpenALPlayer *player = nil;
    
    // speex variables
    SpeexBits speex_bits;
    void *speex_dec_state;
    BOOL bSpeexInited = NO;
    float *speexTmpBuf;
    short *speexBuf;
    
    // mpg123 variables
    mpg123_handle *mp3_handle;
    off_t num;
    BOOL bMpg123Inited = NO;
    unsigned char *bbbuf = NULL;
    int ret = 0;
    
    // adpcm variables
    BOOL bADPCMInited = NO;
    char *outADPCMBuf = NULL;
    
    // G726 variables
    BOOL bG726Inited = NO;
    unsigned char *outG726Buf=NULL, *pOutG711Buf=NULL;
    
    unsigned int nSamplingRate = 44100;
    unsigned int nDatabits = 0;
    unsigned int nChannel = 0;
    unsigned int nCodecId = 0;
    unsigned int nTimeStamp = 0;
    
    unsigned int nFPS = 0;
    
    BOOL bFirst = YES;
    
    int readSize = 0;
    char recvBuf[RECV_AUDIO_BUFFER_SIZE] = {0};
       
    FRAMEINFO_t stFrmInfo = {0};
    
    int nBufCnt = 0;
    unsigned int nFrmNo = 0;
    
    channel.audioBps = 0;
    
    while(channel.isRunningRecvAudioThread) {
                        
        if (sessionID >= 0 && channel.avIndex >= 0) {
            
            /*
            nBufCnt = avCheckAudioBuf(channel.avIndex);
            
            if (nBufCnt < nFPS) {
                usleep(nFPS == 0 ? 100 : 1000 / nFPS * 1000);
                continue;
            }            
            */
            
            readSize = avRecvAudioData(channel.avIndex, recvBuf, RECV_AUDIO_BUFFER_SIZE, (char *)&stFrmInfo, sizeof(FRAMEINFO_t), &nFrmNo);
     
            if (readSize >= 0) {
                                
                channel.audioBps += (readSize * 8);
                
                /*
                ip_block_t *packet = malloc(sizeof(ip_block_t));
                
                if (ip_block_Alloc(packet, recvBuf, readSize) > 0) {
                    
                    packet->frameNo = nFrmNo;
                    packet->frmState = FRM_STAT_COMPLETE;
                    memcpy(&packet->frmInfo, &stFrmInfo, sizeof(FRAMEINFO_t));
                    
                    ip_block_FifoPut(channel.audioQueue, packet);
                    
                }
                else if (packet) {
                    free(packet);
                }                
                */
                
                if (bFirst) {
                    
                    bFirst = NO;
                    
                    nSamplingRate = [self _getSampleRate:(stFrmInfo.flags)];
                    nDatabits = (int)(stFrmInfo.flags >> 1 & 1);
                    nChannel = stFrmInfo.flags & 0x01;
                    nCodecId = stFrmInfo.codec_id;
                    nTimeStamp = stFrmInfo.timestamp;
                    
                    // LOG(@"Audio codec:%X, SampleRate:%d, %dbit, %@", nCodecId, nSamplingRate, nDatabits == AUDIO_DATABITS_8 ? 8 : 16, nChannel == AUDIO_CHANNEL_MONO ? @"MONO" : @"STEREO");
                    
                    // nFPS = ((nSamplingRate * (nDatabits == AUDIO_DATABITS_8 ? 8 : 16) * (nChannel == AUDIO_CHANNEL_MONO ? 1 : 2)) / 8) / readSize;
                    
                    
                    if (nCodecId == MEDIA_CODEC_AUDIO_SPEEX) {
                        
                        speexTmpBuf = malloc(SPEEX_FRAME_SIZE * sizeof(float));
                        speexBuf = malloc(SPEEX_FRAME_SIZE * sizeof(short));
                        
                        const SpeexMode* speex_mode = speex_lib_get_mode(SPEEX_MODEID_NB);
                        
                        speex_bits_init(&speex_bits);
                        speex_dec_state = speex_decoder_init(speex_mode);
                        speex_decoder_ctl(speex_dec_state, SPEEX_SET_SAMPLING_RATE, &nSamplingRate);
                        
                        nFPS = 50;
                        
                        bSpeexInited = YES;
                        LOG(@"speex decoder init");
                    }
                    else if (nCodecId == MEDIA_CODEC_AUDIO_MP3) {
                        
                        mpg123_init();
                        
                        mp3_handle = mpg123_new(NULL, &ret);
                        if (mp3_handle == NULL) {
                            LOG(@"unable to create mpg123 handle: %s", mpg123_plain_strerror(ret));
                            break;
                        }
                        
                        ret = mpg123_param(mp3_handle, MPG123_VERBOSE, 2, 0);
                        if (ret != MPG123_OK) {
                            LOG(@"unable to set library options: %s", mpg123_plain_strerror(ret));
                            break;
                        }
                        
                        ret = mpg123_format_none(mp3_handle);
                        if (ret != MPG123_OK) {
                            LOG(@"unable to disable all output formats: %s", mpg123_plain_strerror(ret));
                            break;
                        }
                        
                        int encoding = nDatabits == AUDIO_DATABITS_16 ? MPG123_ENC_SIGNED_16 : MPG123_ENC_SIGNED_8;
                        //int ch = nChannel == AUDIO_CHANNEL_STERO ? MPG123_STEREO : MPG123_MONO;
                        
                        ret = mpg123_format(mp3_handle, nSamplingRate, MPG123_STEREO | MPG123_MONO, encoding);
                        if (ret != MPG123_OK) {
                            LOG(@"unable to set output formats :%s", mpg123_plain_strerror(ret));
                            break;
                        }
                        
                        ret = mpg123_open_feed(mp3_handle);
                        if (ret != MPG123_OK) {
                            LOG(@"unable open feed: %s", mpg123_plain_strerror(ret));
                            break;
                        }
                        
                        bbbuf = malloc(65535);
                        
                        nFPS = 32;
                        
                        bMpg123Inited = YES;
                        LOG(@"mpg123 decoder init");
                    }
                    else if (nCodecId == MEDIA_CODEC_AUDIO_ADPCM) {                                                
                        outADPCMBuf = malloc(640);
                        
                        nFPS = 25;
                        ResetADPCMDecoder();
                        
                        bADPCMInited = YES;
                        LOG(@"ADPCM decoder init");
                    }
                    else if (nCodecId == MEDIA_CODEC_AUDIO_PCM) {
                        nFPS = 25;
                    }
                    else if (nCodecId == MEDIA_CODEC_AUDIO_G726) {                        
                        bG726Inited = g726_state_create(G726_16, AUDIO_ENCODING_LINEAR, &hG726Dec);
                        if (bG726Inited) outG726Buf = malloc(2048);
                        nFPS = 50;
                        LOG(@"G726 decoder init");
                    }
                    else if (nCodecId == MEDIA_CODEC_AUDIO_G711U) {
                        nFPS = 25;
                        RLOG(@"IOTCamera MEDIA_CODEC_AUDIO_G711U\n");
                    }
                    else if (nCodecId == MEDIA_CODEC_AUDIO_G711A) {
                        nFPS = 25;
                        NSLog(@"ADD_G711");
                    }
                                        
                    int format = 0;
                    
                    if (nDatabits == AUDIO_DATABITS_8 && nChannel == AUDIO_CHANNEL_MONO)
                        format = AL_FORMAT_MONO8;
                    else if (nDatabits == AUDIO_DATABITS_8 && nChannel == AUDIO_CHANNEL_STERO)
                        format = AL_FORMAT_STEREO8;
                    else if (nDatabits == AUDIO_DATABITS_16 && nChannel == AUDIO_CHANNEL_MONO)
                        format = AL_FORMAT_MONO16;
                    else if (nDatabits == AUDIO_DATABITS_16 && nChannel == AUDIO_CHANNEL_STERO)
                        format = AL_FORMAT_STEREO16;
                    else
                        format = AL_FORMAT_MONO16;
                    
                    LOG(@"audio format=%x", format);
                    
                    player = [[OpenALPlayer alloc] init];
                    [player initOpenAL:format :nSamplingRate];
                    
                    // usleep(1000 / nFPS * 1000);
                }   
                
                
                if (nCodecId == MEDIA_CODEC_AUDIO_SPEEX) {
                    
                    speex_bits_read_from(&speex_bits, recvBuf, readSize);
                    speex_decode(speex_dec_state, &speex_bits, speexTmpBuf);
                                        
                    for(int i = 0; i < SPEEX_FRAME_SIZE; i++)
                        speexBuf[i] = speexTmpBuf[i];                    
                                        
                    [player openAudioFromQueue:[NSData dataWithBytes:speexBuf length:sizeof(short) * SPEEX_FRAME_SIZE]];                    
                }                
                else if (nCodecId == MEDIA_CODEC_AUDIO_MP3) {          
                    
                    unsigned char **outMP3Buf = (unsigned char **)bbbuf;
                    size_t size;
                    
                    ret = mpg123_feed(mp3_handle, (unsigned char *)recvBuf, readSize);
                    ret = mpg123_decode_frame(mp3_handle, &num, outMP3Buf, &size);
                    
                    if (ret == MPG123_NEW_FORMAT) {                    
                        int ch, enc;
                        long rate;
                        mpg123_getformat(mp3_handle, &rate, &ch, &enc);
                        LOG(@"new format: %li Hz, %i channels, encoding value %i", rate, ch, enc);                    
                    }
                    else if (ret == MPG123_ERR) {
                        LOG(@"mpg123 decode error: %s", mpg123_strerror(mp3_handle));
                        continue;
                    }
                                        
                    if (size > 0) {
                        [player openAudioFromQueue:[NSData dataWithBytes:(const void*)*outMP3Buf length:size]];
                    }
                }     
                else if (nCodecId == MEDIA_CODEC_AUDIO_PCM) {
                    
                    [player openAudioFromQueue:[NSData dataWithBytes:recvBuf length:readSize]];
                }			
                else if (nCodecId == MEDIA_CODEC_AUDIO_ADPCM) {
                    
                    if (outADPCMBuf) {
                        
                        DecodeADPCM(recvBuf, readSize, outADPCMBuf);                   
                                            
                        [player openAudioFromQueue:[NSData dataWithBytes:outADPCMBuf length:640]];
                    }
                }
                else if (nCodecId == MEDIA_CODEC_AUDIO_G726) {
                    
                    unsigned long outLen = 0;
                    
                    g726_decode(hG726Dec, (unsigned char *)recvBuf, readSize, outG726Buf, &outLen);
                    
                    [player openAudioFromQueue:[NSData dataWithBytes:outG726Buf length:outLen]];
                }
                else if(nCodecId == MEDIA_CODEC_AUDIO_G711U){
                    unsigned int outLen = 0;
                    if(pOutG711Buf==NULL) pOutG711Buf=malloc(readSize*2);
                    if(pOutG711Buf){
                        g711u_Decode((unsigned char *)recvBuf, readSize, pOutG711Buf, &outLen);
                        [player openAudioFromQueue:[NSData dataWithBytes:pOutG711Buf length:outLen]];
                    }
                }
                else if (nCodecId == MEDIA_CODEC_AUDIO_G711A) {
                    
                    unsigned int outLen = 0;
                    if(pOutG711Buf==NULL) pOutG711Buf=malloc(readSize*2);
                    if(pOutG711Buf){
                        g711a_Decode((unsigned char *)recvBuf, readSize, pOutG711Buf, &outLen);
                        [player openAudioFromQueue:[NSData dataWithBytes:pOutG711Buf length:outLen]];
                    }
                    
                    NSLog(@"ADD_G711A_01");
                }
            }
            else if (readSize == AV_ER_DATA_NOREADY) {                
                LOG(@"avRecvAudioData return AV_ER_DATA_NOREADY");
                usleep(nFPS == 0 ? 33 * 1000 : 1000 / nFPS * 1000);
            }
            else if (readSize == AV_ER_LOSED_THIS_FRAME) {                
                LOG(@"avRecvAudioData return AV_ER_LOSED_THIS_FRAME");
            }
            else {
                LOG(@"avRecvAudioData return err - %d", readSize);
                usleep(nFPS == 0 ? 33 * 1000 : 1000 / nFPS * 1000);
            }
        }
        else usleep(10 * 1000);
    }
    
    if (bSpeexInited) {
        if (speexTmpBuf) free(speexTmpBuf);
        if (speexBuf) free(speexBuf);
        speex_bits_destroy(&speex_bits);
        speex_decoder_destroy(speex_dec_state);
        bSpeexInited = NO;
        LOG(@"speex decoder destroy");
    }
    
    if (bMpg123Inited) {
        if (bbbuf) free(bbbuf);
        mpg123_delete(mp3_handle);
        mpg123_exit();
        bMpg123Inited = NO;
        LOG(@"mpg123 decoder destroy");
    }
    
    if (bADPCMInited) {
        if (outADPCMBuf) free(outADPCMBuf);
        bADPCMInited = NO;
        LOG(@"ADPCM decoder destroy");
    }
    
    if (bG726Inited) {
        if (outG726Buf) free(outG726Buf);
        g726_state_destroy(&hG726Dec);
        bG726Inited = NO;
        LOG(@"G726 decoder destroy");
    }
    if(pOutG711Buf){
        free(pOutG711Buf);
        pOutG711Buf=NULL;
    }
    
    if (player != nil) {
        [player stopSound];
        [player cleanUpOpenAL];
        [player release];
        player = nil;
    }
    
    LOG(@"=== Recv Audio Thread Exit (%@) ===", uid);
    
    [channel.recvAudioThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

- (void)doDecodeAudio:(AVChannel *) channel {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [channel.decAudioThreadLock lock];
        
    LOG(@"=== Decode Audio Thread Start (%@) ===", uid);

    OpenALPlayer *player = nil;
    
    // speex variables
    SpeexBits speex_bits;
    void *speex_dec_state;
    BOOL bSpeexInited = NO;
    float *speexTmpBuf;
    short *speexBuf;
    
    // mpg123 variables
    mpg123_handle *mp3_handle;
    off_t num;
    BOOL bMpg123Inited = NO;
    unsigned char *bbbuf = NULL;
    int ret = 0;
    
    // adpcm variables
    BOOL bADPCMInited = NO;
    char *outADPCMBuf = NULL;
    
    // G726 variables
    BOOL bG726Inited = NO;
    unsigned char *outG726Buf;
    
    unsigned int nSamplingRate = 44100;
    unsigned int nDatabits = 0;
    unsigned int nChannel = 0;
    unsigned int nCodecId = 0;
    unsigned int nTimeStamp = 0;
    
    unsigned int nFPS = 0;
    
    BOOL bFirst = YES;  
    ip_block_t *pAvFrame = NULL;    
        
    //unsigned int firstTimeStampFromDevice = 0, firstTimeStampFromLocal = 0;
    //int sleepTime;
    
    while (channel.isRunningDecAudioThread) {
        
        if (sessionID < 0 && channel.avIndex < 0) {
            usleep(10 * 1000);
            continue;
        }
        
        if (ip_block_FifoCount(channel.audioQueue) > 0) {            
                  
            if (pAvFrame != NULL) ip_block_Release(pAvFrame);
            
            pAvFrame = ip_block_FifoGet(channel.audioQueue);
            
            if(pAvFrame == NULL) continue;
            
            if (bFirst) {
                
                bFirst = NO;
                            
                nSamplingRate = [self _getSampleRate:pAvFrame->frmInfo.flags];
                nDatabits = (int)(pAvFrame->frmInfo.flags >> 1 & 1);
                nChannel = pAvFrame->frmInfo.flags & 0x01;
                nCodecId = pAvFrame->frmInfo.codec_id;
                nTimeStamp = pAvFrame->frmInfo.timestamp;
                                
                LOG(@"Audio codec:%X, SampleRate:%d, %dbit, %@", nCodecId, nSamplingRate, nDatabits == AUDIO_DATABITS_8 ? 8 : 16, nChannel == AUDIO_CHANNEL_MONO ? @"MONO" : @"STEREO");
                
                if (nCodecId == MEDIA_CODEC_AUDIO_SPEEX) {
                    
                    speexTmpBuf = malloc(SPEEX_FRAME_SIZE * sizeof(float));
                    speexBuf = malloc(SPEEX_FRAME_SIZE * sizeof(short));
                    
                    const SpeexMode* speex_mode = speex_lib_get_mode(SPEEX_MODEID_NB);
                    
                    speex_bits_init(&speex_bits);
                    speex_dec_state = speex_decoder_init(speex_mode);
                    speex_decoder_ctl(speex_dec_state, SPEEX_SET_SAMPLING_RATE, &nSamplingRate);
                    
                    bSpeexInited = YES;
                    LOG(@"speex decoder init");
                }
                else if (nCodecId == MEDIA_CODEC_AUDIO_MP3) {
                    
                    mpg123_init();
                    
                    mp3_handle = mpg123_new(NULL, &ret);
                    if (mp3_handle == NULL) {
                        LOG(@"unable to create mpg123 handle: %s", mpg123_plain_strerror(ret));
                        break;
                    }
                    
                    ret = mpg123_param(mp3_handle, MPG123_VERBOSE, 2, 0);
                    if (ret != MPG123_OK) {
                        LOG(@"unable to set library options: %s", mpg123_plain_strerror(ret));
                        break;
                    }
                    
                    ret = mpg123_format_none(mp3_handle);
                    if (ret != MPG123_OK) {
                        LOG(@"unable to disable all output formats: %s", mpg123_plain_strerror(ret));
                        break;
                    }
                    
                    int encoding = nDatabits == AUDIO_DATABITS_16 ? MPG123_ENC_SIGNED_16 : MPG123_ENC_SIGNED_8;
                    //int ch = nChannel == AUDIO_CHANNEL_STERO ? MPG123_STEREO : MPG123_MONO;
                    
                    ret = mpg123_format(mp3_handle, nSamplingRate, MPG123_STEREO | MPG123_MONO, encoding);
                    if (ret != MPG123_OK) {
                        LOG(@"unable to set output formats :%s", mpg123_plain_strerror(ret));
                        break;
                    }
                    
                    ret = mpg123_open_feed(mp3_handle);
                    if (ret != MPG123_OK) {
                        LOG(@"unable open feed: %s", mpg123_plain_strerror(ret));
                        break;
                    }
                    
                    bbbuf = malloc(65535);
                                        
                    bMpg123Inited = YES;
                    LOG(@"mpg123 decoder init");
                }
                else if (nCodecId == MEDIA_CODEC_AUDIO_ADPCM) {
                    
                    outADPCMBuf = malloc(640);
                    
                    ResetADPCMDecoder();
                    
                    bADPCMInited = YES;
                    LOG(@"ADPCM decoder init");
                }
                else if (nCodecId == MEDIA_CODEC_AUDIO_PCM) {
                }
                else if (nCodecId == MEDIA_CODEC_AUDIO_G726) {
                    bG726Inited = g726_state_create(G726_16, AUDIO_ENCODING_LINEAR, &hG726Dec);
                    if (bG726Inited) outG726Buf = malloc(2048);
                    LOG(@"G726 decoder init");
                }
                else if (nCodecId == MEDIA_CODEC_AUDIO_G711A) {
                    
                    NSLog(@"ADD_G711A_Decode");
                }
                
                int format = 0;
                
                if (nDatabits == AUDIO_DATABITS_8 && nChannel == AUDIO_CHANNEL_MONO)
                    format = AL_FORMAT_MONO8;
                else if (nDatabits == AUDIO_DATABITS_8 && nChannel == AUDIO_CHANNEL_STERO)
                    format = AL_FORMAT_STEREO8;
                else if (nDatabits == AUDIO_DATABITS_16 && nChannel == AUDIO_CHANNEL_MONO)
                    format = AL_FORMAT_MONO16;
                else if (nDatabits == AUDIO_DATABITS_16 && nChannel == AUDIO_CHANNEL_STERO)
                    format = AL_FORMAT_STEREO16;
                else
                    format = AL_FORMAT_MONO16;
                
                LOG(@"audio format=%x", format);
                
                player = [[OpenALPlayer alloc] init];
                [player initOpenAL:format :nSamplingRate];
                
            }            

            if (nCodecId == MEDIA_CODEC_AUDIO_SPEEX) {
                               
                speex_bits_read_from(&speex_bits, pAvFrame->pBuffer, pAvFrame->buff_size);
                speex_decode(speex_dec_state, &speex_bits, speexTmpBuf);
                
                for(int i = 0; i < SPEEX_FRAME_SIZE; i++)
                    speexBuf[i] = speexTmpBuf[i];            
 
                
                [player openAudioFromQueue:[NSData dataWithBytes:speexBuf length:sizeof(short) * SPEEX_FRAME_SIZE]];
                
                nFPS = ((nSamplingRate * (nDatabits == AUDIO_DATABITS_8 ? 8 : 16) * (nChannel == AUDIO_CHANNEL_MONO ? 1 : 2)) / 8) / (sizeof(short) * SPEEX_FRAME_SIZE);

            }
            else if (nCodecId == MEDIA_CODEC_AUDIO_MP3) {
                
                unsigned char **outMP3Buf = (unsigned char **)bbbuf;
                size_t size;
                
                ret = mpg123_feed(mp3_handle, (unsigned char *)pAvFrame->pBuffer, pAvFrame->buff_size);
                ret = mpg123_decode_frame(mp3_handle, &num, outMP3Buf, &size);
                
                if (ret == MPG123_NEW_FORMAT) {
                    int ch, enc;
                    long rate;
                    mpg123_getformat(mp3_handle, &rate, &ch, &enc);
                    LOG(@"new format: %li Hz, %i channels, encoding value %i", rate, ch, enc);
                }
                else if (ret == MPG123_ERR) {
                    LOG(@"mpg123 decode error: %s", mpg123_strerror(mp3_handle));
                    continue;
                }
                
                if (size > 0) 
                    [player openAudioFromQueue:[NSData dataWithBytes:(const void*)*outMP3Buf length:size]];
                
                nFPS = ((nSamplingRate * (nDatabits == AUDIO_DATABITS_8 ? 8 : 16) * (nChannel == AUDIO_CHANNEL_MONO ? 1 : 2)) / 8) / size;
            }
            else if (nCodecId == MEDIA_CODEC_AUDIO_PCM) {
                
                [player openAudioFromQueue:[NSData dataWithBytes:pAvFrame->pBuffer length:pAvFrame->buff_size]];
                
                nFPS = ((nSamplingRate * (nDatabits == AUDIO_DATABITS_8 ? 8 : 16) * (nChannel == AUDIO_CHANNEL_MONO ? 1 : 2)) / 8) / pAvFrame->buff_size;

            }
            else if (nCodecId == MEDIA_CODEC_AUDIO_ADPCM) {
                
                if (outADPCMBuf) {
                    
                    DecodeADPCM(pAvFrame->pBuffer, pAvFrame->buff_size, outADPCMBuf);
                    
                    [player openAudioFromQueue:[NSData dataWithBytes:outADPCMBuf length:640]];
                    
                    nFPS = ((nSamplingRate * (nDatabits == AUDIO_DATABITS_8 ? 8 : 16) * (nChannel == AUDIO_CHANNEL_MONO ? 1 : 2)) / 8) / 640;
                }
            }
            else if (nCodecId == MEDIA_CODEC_AUDIO_G726) {
                
                unsigned long outLen = 0;
                
                g726_decode(hG726Dec, (unsigned char *)pAvFrame->pBuffer, pAvFrame->buff_size, outG726Buf, &outLen);
                
                [player openAudioFromQueue:[NSData dataWithBytes:outG726Buf length:outLen]];
                
                nFPS = ((nSamplingRate * (nDatabits == AUDIO_DATABITS_8 ? 8 : 16) * (nChannel == AUDIO_CHANNEL_MONO ? 1 : 2)) / 8) / outLen;
            }
            else if (nCodecId == MEDIA_CODEC_AUDIO_G711A) {
                
                NSLog(@"ADD_G711A_Decode_01");
            }
            
            usleep(1000 / nFPS * 1000);
            
        }
        else {
            
            usleep(4 * 1000);
        }
    }
    
    /* uninit speex decoder */
    if (bSpeexInited) {
        if (speexTmpBuf) free(speexTmpBuf);
        if (speexBuf) free(speexBuf);
        speex_bits_destroy(&speex_bits);
        speex_decoder_destroy(speex_dec_state);
        bSpeexInited = NO;
        LOG(@"speex decoder destroy");
    }
    
    /* uninit mpg123 decoder */
    if (bMpg123Inited) {
        if (bbbuf) free(bbbuf);
        mpg123_delete(mp3_handle);
        mpg123_exit();
        bMpg123Inited = NO;
        LOG(@"mpg123 decoder destroy");
    }
    
    if (bADPCMInited) {
        if (outADPCMBuf) free(outADPCMBuf);
        bADPCMInited = NO;
        LOG(@"ADPCM decoder destroy");
    }
    
    if (bG726Inited) {
        if (outG726Buf) free(outG726Buf);
        g726_state_destroy(&hG726Dec);
        bG726Inited = NO;
        LOG(@"G726 decoder destroy");
    }
    
    if (player != nil) {
        [player stopSound];
        [player cleanUpOpenAL];
        [player release];
        player = nil;
    }
    
    LOG(@"=== Decode Audio Thread Exit (%@) ===", uid);
    
    [channel.decAudioThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

- (void)doSendAudio:(AVChannel *) channel {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [channel.sendAudioThreadLock lock];
    
    LOG(@"=== SendAudio Thread Start (%@) ===", uid);
    
    AudioRecorder *recorder = nil;
    speex_enc_state = NULL;
    
    BOOL bFirst = YES;     
    BOOL bSpeexInited = NO;
    BOOL bG726Inited = NO;
    BOOL bAudioRecordInited = NO;
    
    FILE *fpAudio = NULL;
    
    while (channel.isRunningSendAudioThread) {
        
        if (sessionID < 0) {
            usleep(10 * 1000);
            continue;
        }
        
        if (bFirst) {
            
            bFirst = NO;
            
            channel.chIndexForSendAudio = IOTC_Session_Get_Free_Channel(sessionID);
            
            LOG(@"IOTC_Session_Get_Free_Channel(%d) : %d", sessionID, channel.chIndexForSendAudio);
            
            if (channel.chIndexForSendAudio < 0) {
                break;
            }   
            
            SMsgAVIoctrlAVStream *s = malloc(sizeof(SMsgAVIoctrlAVStream));
            s->channel = channel.chIndexForSendAudio;
            [self sendIOCtrlToChannel:channel.avChannel Type:IOTYPE_USER_IPCAM_SPEAKERSTART Data:(char *)s DataSize:sizeof(SMsgAVIoctrlAVStream)];        
            free(s);            
            
            
            while(channel.isRunningSendAudioThread && (channel.avIndexForSendAudio = avServStart(sessionID, NULL, NULL, 60, 0, channel.chIndexForSendAudio)) < 0) {
                LOG(@"avServStart(%d, %d) : %d", sessionID, channel.chIndexForSendAudio, channel.avIndexForSendAudio);
                usleep(10 * 1000);
                continue;
            }
            
            LOG(@"avServStart(%d, %d) : %d", sessionID, channel.chIndexForSendAudio, channel.avIndexForSendAudio);
                        
            if (!channel.isRunningSendAudioThread) {
                break;
            }
                                
            if (channel.audioCodec == MEDIA_CODEC_AUDIO_SPEEX) {
                int quality = 8;
                speex_bits_init(&speex_enc_bits);
                speex_enc_state = speex_encoder_init(&speex_nb_mode);
                speex_encoder_ctl(speex_enc_state, SPEEX_SET_QUALITY, &quality);
                bSpeexInited = YES;
                LOG(@"init Speex encoder");
            }
            
            if (channel.audioCodec == MEDIA_CODEC_AUDIO_ADPCM) {
                ResetADPCMEncoder();
                LOG(@"reset ADPCM encoder");
            }
            
            if (channel.audioCodec == MEDIA_CODEC_AUDIO_G726) {                
                g726_state_create(G726_16, AUDIO_ENCODING_LINEAR, &hG726Enc);
                bG726Inited = YES;
                LOG(@"init G726 encoder");
            }
            if (channel.audioCodec == MEDIA_CODEC_AUDIO_G711A) {
                
            }
            if (channel.audioCodec == MEDIA_CODEC_AUDIO_G711U) {
                
            }
            
#ifdef REAL_AUDIO_OUT            
            // init Audio Desc
            AudioStreamBasicDescription format = (AudioStreamBasicDescription) {
                .mSampleRate = 8000,                
                .mFormatID = kAudioFormatLinearPCM,
                .mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
                .mBitsPerChannel = 16,
                .mChannelsPerFrame = 1,
                .mBytesPerFrame = 2,
                .mFramesPerPacket = 1,
                .mBytesPerPacket = 2,
            };
                     
            
            // init AudioRecorder
            recorder = [[AudioRecorder alloc] initAudioRecorderWithAvIndex:channel.avIndexForSendAudio Codec:channel.audioCodec AudioFormat:format Delegate:self];
            
            if (channel.audioCodec == MEDIA_CODEC_AUDIO_G726)
                [recorder start:320];
            else if (channel.audioCodec == MEDIA_CODEC_AUDIO_G711A) {
                [recorder start:320];
            }
            else if (channel.audioCodec == MEDIA_CODEC_AUDIO_G711U) {
                [recorder start:320];
            }
            else
                [recorder start:640];
            
            bAudioRecordInited = YES;   
#endif
            
#ifdef TEST_AUDIO_OUT
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *audioFilePath = [documentsDirectory stringByAppendingPathComponent:@"8k_16bit_1ch_pcm"];    
            
            fpAudio = fopen([audioFilePath UTF8String], "rb");
            if (fpAudio) {
                LOG(@"load file ok");
            }  
#endif
        }
        
#ifdef TEST_AUDIO_OUT
        {
        // for adpcm test        
        unsigned char buffer[640] = {0};
        unsigned char outBuf[160] = {0};
        
        while (channel.isRunningSendAudioThread && avIndexforSendAudio >= 0 && fpAudio) {
            
            FRAMEINFO_t frameInfo;

            int size = fread(buffer, 1, 640, fpAudio);
            
            if (size <= 0) {
                rewind(fpAudio);
                continue;
            }
            
            EncodeADPCM(buffer, 640, outBuf);

            frameInfo.codec_id = MEDIA_CODEC_AUDIO_ADPCM;
            frameInfo.flags = (AUDIO_SAMPLE_8K << 2) | (AUDIO_DATABITS_16 << 1) | AUDIO_CHANNEL_MONO;
            frameInfo.cam_index = 0;
            frameInfo.timestamp = _getTickCount();
            
            int r = avSendAudioData(avIndexforSendAudio, (char *)outBuf, 160, &frameInfo, sizeof(FRAMEINFO_t));
            LOG(@"%d = avSendAudioData(%d, %@)", r, avIndexforSendAudio, [self _getHexString:(char *)outBuf Size:160]);
            usleep(1000000 / 26);
        }
        
 
        }
#endif
        usleep(10 * 1000);
    }

    if (bAudioRecordInited) {
        [recorder stop];
        [recorder release];
        recorder = nil;
    }
    
    if (bSpeexInited) {
        speex_encoder_destroy(speex_enc_state);
        speex_bits_destroy(&speex_enc_bits);        
        speex_enc_state = NULL;
        bSpeexInited = NO;
        LOG(@"speex encoder destroy");
    }
    
    if (bG726Inited) {
        g726_state_destroy(&hG726Enc);
        bG726Inited = NO;
        LOG(@"G726 encoder destroy");
    }
    
    if (fpAudio) {
        fclose(fpAudio);
    }
    
    if (channel.avIndexForSendAudio >= 0) {
        avServStop(channel.avIndexForSendAudio);
    }
    
    if (channel.chIndexForSendAudio >= 0) {
        IOTC_Session_Channel_OFF(sessionID, channel.chIndexForSendAudio);
    }
    
    channel.chIndexForSendAudio = -1;    
    channel.avIndexForSendAudio = -1;
    
    LOG(@"=== SendAudio Thread Exit (%@) ===", uid);
    
    [channel.sendAudioThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

- (void)doSendIOCtrl:(AVChannel *)channel {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [channel.sendIOCtrlThreadLock lock];
   
    LOG(@"=== SendIOCtrl Thread Start (%@) ===", uid);

    int type, size;
    char *buff = malloc(MAX_IOCTRL_BUFFER_SIZE);
        
    while (channel.isRunningSendIOCtrlThread) {
      
        if (self.sessionID >= 0 && channel.avIndex >= 0) {                       
            
            if ([channel dequeueSendIOCtrl:&type :buff :&size] == 1) {
                
                avSendIOCtrl(channel.avIndex, type, buff, size);
                
                /*
                if (type == IOTYPE_USER_IPCAM_STOP) {
                    char *recvBuf = malloc(RECV_VIDEO_BUFFER_SIZE);
                    FRAMEINFO_t frmInfo = {0};
                    unsigned int frmNo = 0;
                    
                    while (avRecvFrameData(channel.avIndex, recvBuf, RECV_VIDEO_BUFFER_SIZE, (char*)&frmInfo, sizeof(FRAMEINFO_t), &frmNo) >= 0);
                    
                    free(recvBuf);
                    
                }
                if (type == IOTYPE_USER_IPCAM_AUDIOSTOP) {
                    char *recvBuf = malloc(RECV_AUDIO_BUFFER_SIZE);
                    FRAMEINFO_t frmInfo = {0};
                    unsigned int frmNo = 0;
                    
                    while (avRecvAudioData(channel.avIndex, recvBuf, RECV_AUDIO_BUFFER_SIZE, (char*)&frmInfo, sizeof(FRAMEINFO_t), &frmNo) >= 0);
                    
                    free(recvBuf);
                }
                */
                
                LOG(@">>> avSendIOCtrl( %d, %d, %X, %@)", self.sessionID, channel.avIndex, type, [self _getHexString:buff Size:size]);

            }
        }
        
        usleep(10 * 1000);
    }
    
    free(buff);
        
    LOG(@"=== SendIOCtrl Thread Exit (%@) ===", uid);
    
    [channel.sendIOCtrlThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

- (void)doRecvIOCtrl:(AVChannel *)channel {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [channel.recvIOCtrlThreadLock lock];
    
    LOG(@"=== RecvIOCtrl Thread Start (%@) ===", uid);
    
    unsigned int type;
    int readSize = 0;
    //char *buff = malloc(MAX_IOCTRL_BUFFER_SIZE);
    
    while (channel.isRunningRecvIOCtrlThread) {
        
        while (channel.isRunningRecvIOCtrlThread && (self.sessionID < 0 || channel.avIndex < 0)) {            
            usleep(10 * 1000);
            continue;
        }
        
        while (channel.isRunningRecvIOCtrlThread) {
                      
            readSize = avRecvIOCtrl(channel.avIndex, &type, recvIOCtrlBuff, MAX_IOCTRL_BUFFER_SIZE, 1000);
            
            if (readSize >= 0) {

                LOG(@"<<< avRecvIOCtrl( %d, %d, %X, %@)", self.sessionID, channel.avIndex, type, [self _getHexString:recvIOCtrlBuff Size:readSize]);
                
                if (type == IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_RESP) {
                    SMsgAVIoctrlGetAudioOutFormatResp *s = (SMsgAVIoctrlGetAudioOutFormatResp *)recvIOCtrlBuff;          
                    
                    for (AVChannel *ch in arrayAVChannel) {
                        if (ch.avChannel == s->channel) {
                            ch.audioCodec = s->format;
                            break;
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didReceiveIOCtrlWithType:Data:DataSize:)])
                        [self.delegate camera:self didReceiveIOCtrlWithType:type Data:recvIOCtrlBuff DataSize:readSize];
                    
                    // LOG(@"--- avRecvIOCtrl( %d, %d, %X, %@)", self.sessionID, channel.avIndex, type, [self _getHexString:recvIOCtrlBuff Size:readSize]);

                });
            }
        }
    }
        
    LOG(@"=== RecvIOCtrl Thread Exit (%@) ===", uid);
    
    [channel.recvIOCtrlThreadLock unlockWithCondition:DONE];
    
    [pool release];
}

#pragma mark - AudioRecorderDelegate Methods
- (void)recvRecordingWithAvIndex:(NSInteger)avIndex Codec:(NSInteger)codec Data:(void *)buff DataLength:(NSInteger)length {
     
    if (avIndex >= 0) {
        
        short *outBuf = buff;
        int r = 0;
                
        FRAMEINFO_t frameInfo;
        frameInfo.cam_index = 0;
        frameInfo.flags = (AUDIO_SAMPLE_8K << 2) | (AUDIO_DATABITS_16 << 1) | AUDIO_CHANNEL_MONO;
        frameInfo.onlineNum = 0;
        frameInfo.timestamp = _getTickCount();
        
        if (codec == MEDIA_CODEC_AUDIO_SPEEX) {
            
            if (speex_enc_state) {
                
                int nBytes = -1;

                speex_bits_reset(&speex_enc_bits);
                speex_encode_int(speex_enc_state, buff, &speex_enc_bits);
                
                nBytes = speex_bits_write(&speex_enc_bits, speex_enc_buffer, 200);
                
                if (nBytes > 0) {

                    frameInfo.codec_id = MEDIA_CODEC_AUDIO_SPEEX;
                    
                    r = avSendAudioData(avIndex, speex_enc_buffer, nBytes, &frameInfo, sizeof(FRAMEINFO_t));
                    
                    LOG(@"avSendAudioData_SPEEX(%d, %@, %d) : %d", avIndex, [self _getHexString:speex_enc_buffer Size:nBytes], nBytes, r);
                }
                else LOG(@"Speex encoder failed");                
            }
        }       
        else if (codec == MEDIA_CODEC_AUDIO_ADPCM) {
            
            unsigned char outADPCMBuf[160] = {0};
            EncodeADPCM((unsigned char *)outBuf, length, outADPCMBuf);
            
            frameInfo.codec_id = MEDIA_CODEC_AUDIO_ADPCM;
            
            r = avSendAudioData(avIndex, (char *)outADPCMBuf, 160, &frameInfo, sizeof(FRAMEINFO_t));
            
            LOG(@"avSendAudioData_ADPCM(%d, %@, %d) : %d", avIndex, [self _getHexString:(char *)outADPCMBuf Size:160], 160, r);
        }
        else if (codec == MEDIA_CODEC_AUDIO_G726) {
    
            unsigned long outLen = 0;
            int consume = 0;
            
            unsigned char outG726[2048] = {0};
            consume = g726_encode(hG726Enc, buff, length, outG726, &outLen);

            frameInfo.codec_id = MEDIA_CODEC_AUDIO_G726;
            
            r = avSendAudioData(avIndex, (char *)outG726, outLen, &frameInfo, sizeof(FRAMEINFO_t));
            
            LOG(@"avSendAudioData_G726(%d, %@, %lu) : %d", avIndex, [self _getHexString:(char *)outG726 Size:outLen], outLen, r);
        }
        else if (codec == MEDIA_CODEC_AUDIO_PCM) {
            
            frameInfo.codec_id = MEDIA_CODEC_AUDIO_PCM;
            
            r = avSendAudioData(avIndex, (char *)buff, length, &frameInfo, sizeof(FRAMEINFO_t));
            
            LOG(@"avSendAudioData_PCM(%d) : %d", avIndex, r);
        }
        else if(codec == MEDIA_CODEC_AUDIO_G711U) {
            unsigned int outLen = 0;
            int consume = 0;
            unsigned char outG711[2048] = {0};
            consume = g711u_Encode(buff, length, outG711, &outLen);
            NSLog(@"%s", outG711);
            frameInfo.codec_id = MEDIA_CODEC_AUDIO_G711U;
            r = avSendAudioData(avIndex, (char *)outG711, outLen, &frameInfo, sizeof(FRAMEINFO_t));
        }
        else if(codec == MEDIA_CODEC_AUDIO_G711A) {
            unsigned int outLen = 0;
            int consume = 0;
            unsigned char outG711[2048] = {0};
            consume = g711a_Encode(buff, length, outG711, &outLen);
            frameInfo.codec_id = MEDIA_CODEC_AUDIO_G711A;
            NSLog(@"%s", outG711);
            r = avSendAudioData(avIndex, (char *)outG711, outLen, &frameInfo, sizeof(FRAMEINFO_t));
            NSLog(@"MEDIA_CODEC_AUDIO_G711A(%d) : %d  %d  %d", avIndex, r, consume, outLen);
        }
    }
}
@end
