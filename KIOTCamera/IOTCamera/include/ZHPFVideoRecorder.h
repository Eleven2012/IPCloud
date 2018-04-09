 
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <sys/time.h>

@interface ZHPFVideoRecorder : NSObject
{
    volatile bool                                    isRecordingVideo;
    double                                     currentSeconds;
    
    AVAssetWriterInputPixelBufferAdaptor*   videoInputPixelBufAdaptor;
    AVAssetWriterInput*                     videoWriterInput;
    AVAssetWriterInput*                     audioWriterInput;
    
    AVAssetWriter *                         assetWriter;
    
    CFAbsoluteTime d_stream_time;
    BOOL isHaveVideoFrame;
}
@property (nonatomic,readwrite)bool                                    isRecordingVideo;

+ (ZHPFVideoRecorder* )getInstance;

-(void)startVideoRecord:(NSString *)filePath;
-(BOOL)stopVideoRecord;

- (void)processPixelBuffer: (CVImageBufferRef)pixelBuffer;

- (void)writeVideoWithUIImage: (CGImageRef)frameImage;
- (void)writeVideoWithImageframe: (CVPixelBufferRef)frameImage;//modify


@end
