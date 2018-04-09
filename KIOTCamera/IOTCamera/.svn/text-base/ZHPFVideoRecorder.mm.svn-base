

#import "ZHPFVideoRecorder.h"

static ZHPFVideoRecorder* instance=nil;
const AudioStreamBasicDescription asbd = {8000.0, kAudioFormatLinearPCM, 12, 2, 1, 2, 1, 16, 0};

@implementation ZHPFVideoRecorder

@synthesize isRecordingVideo;

+(ZHPFVideoRecorder* ) getInstance
{
    @synchronized(self)
    {
        if(instance==nil){
            instance=[[ZHPFVideoRecorder alloc] init];
        }
        
    }
    return instance;
}
- (id)init
{
    if(self=[super init])
    {
        isRecordingVideo=false;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Release Video Recorder Instance!!!!!! ");
    
    [instance release];
    instance=nil;
    [super dealloc];
}

-(BOOL)CreateDirect:(NSString *)documentPath dirName:(NSString *)dirName
{
    //NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsPath = [dirs objectAtIndex:0];
    NSString *strPath = [NSString stringWithFormat:@"%@/%@",documentPath,dirName];
    BOOL isExit = [[[NSFileManager alloc] init]fileExistsAtPath:strPath];
    if (!isExit)
    {
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        [fileManager createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return isExit;
}


-(void)initVideoAndAudioWriter:(NSString *)filePath
{
    NSError *error = nil;
    
    assetWriter = [[AVAssetWriter alloc] initWithURL:
                   [NSURL fileURLWithPath:filePath] fileType:AVFileTypeQuickTimeMovie
                                               error:&error];
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
    }
    NSParameterAssert(assetWriter);
}


- (void)initVideoAssertWriterInput
{
    currentSeconds = 0;
    
    CGSize imageSize = CGSizeMake(640, 368);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:imageSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:imageSize.height], AVVideoHeightKey,
                                   nil];
    
    
    
    videoWriterInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                          outputSettings:videoSettings] retain];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:imageSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:imageSize.width] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    videoInputPixelBufAdaptor = [[AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:attributes] retain];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([assetWriter canAddInput:videoWriterInput]);

    [assetWriter addInput:videoWriterInput];
    videoWriterInput.expectsMediaDataInRealTime = YES;
    videoWriterInput.mediaTimeScale = 600;
    
}

- (BOOL) initAudioAssertWriterInput
{
    AudioChannelLayout acl = {kAudioChannelLayoutTag_Mono};
    NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
							   [NSNumber numberWithFloat: 8000], AVSampleRateKey,
							   [NSNumber numberWithInt: kAudioFormatLinearPCM], AVFormatIDKey,
							   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
							   [NSNumber numberWithInt: 16], AVLinearPCMBitDepthKey,
							   [NSNumber numberWithBool: NO], AVLinearPCMIsFloatKey,
							   [NSNumber numberWithBool: NO], AVLinearPCMIsBigEndianKey,
							   [NSNumber numberWithBool: NO], AVLinearPCMIsNonInterleaved,
							   [NSData dataWithBytes: &acl length: sizeof (acl)], AVChannelLayoutKey,
							   nil
							   ];

	if ([assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
		audioWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
		if ([assetWriter canAddInput:audioWriterInput])
			[assetWriter addInput:audioWriterInput];
		else {
			NSLog(@"Couldn't add asset writer audio input.");
            return NO;
		}
	}
	else {
		NSLog(@"Couldn't apply audio output settings.");
        return NO;
	}
    
    return YES;
}

- (void)writeVideoWithImageframe: (CVPixelBufferRef)frameImage
{
    [self processPixelBuffer:frameImage];
    
    if(isRecordingVideo)
    {
        
        isHaveVideoFrame = YES;
        if (videoInputPixelBufAdaptor.assetWriterInput.readyForMoreMediaData)
        {
            currentSeconds++;

            CMTime presentTime=CMTimeMake((CFAbsoluteTimeGetCurrent() - d_stream_time) * videoWriterInput.mediaTimeScale, videoWriterInput.mediaTimeScale);
            BOOL result = [videoInputPixelBufAdaptor appendPixelBuffer:frameImage withPresentationTime:presentTime];
            
            if (result == NO) //failes on 3GS, but works on iphone 4
            {
            }
        }
        else
        {
            currentSeconds--;
        }
    }
    
}


- (void)writeVideoWithUIImage: (CGImageRef)frameImage
{
    
    CVPixelBufferRef buffer = NULL;
   
    if(isRecordingVideo)
    {
        
        isHaveVideoFrame = YES;
        if (videoInputPixelBufAdaptor.assetWriterInput.readyForMoreMediaData)
        {
            currentSeconds++;
            NSLog(@"--------%f-------------------------------------------",currentSeconds);

            CMTime presentTime=CMTimeMake((CFAbsoluteTimeGetCurrent() - d_stream_time) * videoWriterInput.mediaTimeScale, videoWriterInput.mediaTimeScale);

            buffer = [self pixelBufferFromCGImage:frameImage];
            if (buffer == NULL)
            {
                return;
            }
            BOOL result = [videoInputPixelBufAdaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
            
            if (result == NO) 
            {

            }
            if(buffer)
                CVBufferRelease(buffer);
        }
        else
        {
            currentSeconds--;
        }
    }

}

- (void)processPixelBuffer: (CVImageBufferRef)pixelBuffer
{
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	
	int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
	int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
	unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
	for( int row = 0; row < bufferHeight; row++ ) {
		for( int column = 0; column < bufferWidth; column++ ) {
            unsigned char tempPixel=pixel[0];
			pixel[0] = pixel[2]; // De-green (second pixel in BGRA is green)
            pixel[2]=tempPixel;
			pixel += 4;
		}
	}
	
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
}

#define D_CAMERA_RECODER_ERROR(status) if (status != kCMBlockBufferNoErr) {printf ("status error : %s and error code : %lu", #status, status);}
- (void)writeAudioFrame:(NSData *)data{
    if (isRecordingVideo == NO) {
        return;
    }
    
    int len = [data length];
    
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
    
    
    if (audioWriterInput.readyForMoreMediaData) {
        CMBlockBufferRef			block_buffer;
        CMSampleBufferRef			sample_buffer;
        CMAudioFormatDescriptionRef audio_format;
        
        int number = len / 2;
        CMTime time = CMTimeMakeWithSeconds(number / 8000.0, 1);
        const AudioStreamPacketDescription packet = {0, number, len};
        if (audioWriterInput.readyForMoreMediaData) {
            
            OSStatus block_buffer_create_status		= CMBlockBufferCreateWithMemoryBlock(NULL, NULL, len, NULL, NULL, 0, len, kCMBlockBufferAssureMemoryNowFlag, &block_buffer);
            OSStatus block_buffer_repalce_status	= CMBlockBufferReplaceDataBytes([data bytes], block_buffer, 0, len);
            OSStatus audio_format_status			= CMAudioFormatDescriptionCreate(NULL, &asbd, 0, NULL, 0, NULL, NULL,  &audio_format);
            OSStatus audio_sample_buffer_status		= CMAudioSampleBufferCreateWithPacketDescriptions(NULL, block_buffer, YES, NULL, NULL, audio_format, number, time, &packet, &sample_buffer);
            
            if (!sample_buffer) {
                CFRelease(block_buffer);
                CFRelease(audio_format);
                return;
            } else {
                OSStatus append_sample = [audioWriterInput appendSampleBuffer:sample_buffer];
                append_sample = ! append_sample;
                CFRelease(sample_buffer);
                CFRelease(block_buffer);
                CFRelease(audio_format);
                
                D_CAMERA_RECODER_ERROR (block_buffer_create_status);
                D_CAMERA_RECODER_ERROR (block_buffer_repalce_status);
                D_CAMERA_RECODER_ERROR (audio_format_status);
                D_CAMERA_RECODER_ERROR (audio_sample_buffer_status);
                D_CAMERA_RECODER_ERROR (append_sample);
            }
        }
    }
	
	[p release];
}

-(void)updateTimer
{
    currentSeconds++;
}

- (void)stopWrittingVideo
{
    
    [videoWriterInput markAsFinished];
    [assetWriter finishWriting];
    [videoInputPixelBufAdaptor release];
    [assetWriter release];
    [videoWriterInput release];
    [audioWriterInput release];
    
    currentSeconds=0;
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef)image
{
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    //图像倒立变换
    //CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, CGImageGetHeight(image));
    //CGContextConcatCTM(context, flipVertical);
    //CGAffineTransform flipHorizontal = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0);
    //CGContextConcatCTM(context, flipHorizontal);
    
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

-(void)startVideoRecord:(NSString *)filePath{
    if(isRecordingVideo == true)
    {
        [self stopVideoRecord];
    }
    NSLog(@"startVideoRecord %@",filePath);
    [instance initVideoAndAudioWriter:filePath];
    [instance initVideoAssertWriterInput];
    [instance initAudioAssertWriterInput];
    
    [assetWriter startWriting];
    [assetWriter startSessionAtSourceTime: CMTimeMake(0, videoWriterInput.mediaTimeScale)];
    d_stream_time = CFAbsoluteTimeGetCurrent();
    
    isRecordingVideo=true;
    isHaveVideoFrame = false;
}
-(BOOL)stopVideoRecord{
    if(isRecordingVideo == true)
    {
        isRecordingVideo=false;
        [instance stopWrittingVideo];
    }
    
    return isHaveVideoFrame;
}
@end
