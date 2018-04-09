//
//  mpeg4.m
//  IOTCamera
//
//  Created by Cloud Hsiao on 12/8/7.
//
//

#import "mpeg4.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libavcodec/avcodec.h"
#include "yuv420torgb24.h"

@interface mpeg4()
{
    AVCodec                 *pCodec;
    AVPacket                packet;
    AVCodecContext          *pCodecCtx;
    AVCodecParserContext    *pCodecParser;
    AVFrame                 *pFrame;
    AVPicture               picture;
    struct SwsContext       *img_convert_ctx;
    int videoWidth;
    int videoHeight;
}

@property int videoWidth;
@property int videoHeight;

@end

@implementation mpeg4

@synthesize videoHeight, videoWidth;

-(id)initWithWidth:(int)width Height:(int)height
{
    self = [super init];
    
    if (self) {
        
        yuv420torgb24_c_init();
        
        // Register all formats and codecs
        av_register_all();
        av_init_packet(&packet);
        
        pCodecParser = av_parser_init(CODEC_ID_MPEG4);
        
        // Find the decoder for the codec
        pCodec = avcodec_find_decoder(CODEC_ID_MPEG4);
        
        if(pCodec == NULL) {
            NSLog(@"mpeg4 codec not found");
        }
                
        pCodecCtx = avcodec_alloc_context();
        
        pCodecCtx->width = width;
        pCodecCtx->height = height;
        videoWidth = width;
        videoHeight = height;
        
        if (pCodec->capabilities & CODEC_CAP_TRUNCATED)
            pCodecCtx->flags |= CODEC_FLAG_TRUNCATED;
        
        // Open codec
        if(avcodec_open(pCodecCtx, pCodec) < 0) {
            NSLog(@"could not open mpeg4 codec");
        }
        
        pFrame = avcodec_alloc_frame();

        NSLog(@"init mpeg4 codec success, width:%d, height:%d", width, height);
    }
    return self;
}

-(void)release
{
    // Free scaler
    sws_freeContext(img_convert_ctx);
    
    // Free RGB picture
    avpicture_free(&picture);
    
    // Free the YUV frame
    av_free(pFrame);
    
    av_parser_close(pCodecParser);
    
    // Close the codec
    if (pCodecCtx) avcodec_close(pCodecCtx);
    
    [super release];
    
    NSLog(@"uninit mpeg4 codec success");
}


-(void)setupScaler {
    
    // Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    // Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24,pCodecCtx->width,pCodecCtx->height);
    
    // Setup scaler
    static int sws_flags =  SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(pCodecCtx->width,
                                     pCodecCtx->height,
                                     pCodecCtx->pix_fmt,
                                     pCodecCtx->width,
                                     pCodecCtx->height,
                                     PIX_FMT_RGB24,
                                     sws_flags, NULL, NULL, NULL);
    
}

-(void)convertFrameToRGB
{    
    [self setupScaler];
    sws_scale (img_convert_ctx,pFrame->data, pFrame->linesize,
               0, pCodecCtx->height,
               picture.data, picture.linesize);
}


- (void)decode:(char *)in_buf SizeOfBufferToDecode:(int)in_size decodedBuffer:(char *)out_buf decodedBufferSize:(int *)out_size imgWidth:(int *)out_width imageHeight:(int *)out_height
{
    int parserLength_In, parserLen;
    uint8_t *parserBuffer_In;
    int got_picture;
    int videoLen = 0;
    AVPacket Temp;
        
    packet.size = in_size;
    packet.data = (unsigned char *)in_buf;
    parserLength_In = packet.size;
    parserBuffer_In = packet.data;
    
    while (parserLength_In) {
        
        av_init_packet(&Temp);
        parserLen = av_parser_parse2(pCodecParser, pCodecCtx, &Temp.data, &Temp.size, (const uint8_t *)parserBuffer_In, parserLength_In, AV_NOPTS_VALUE, AV_NOPTS_VALUE, AV_NOPTS_VALUE);
        
        parserLength_In -= parserLen;
        parserBuffer_In += parserLen;
        
        if (Temp.size)
        {
            videoLen = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, &Temp);
            
            if(videoLen > 0 && got_picture) {
                
                [self convertFrameToRGB];
                //yuv420torgb24_c(pFrame->data[0], pFrame->linesize[0], pFrame->data[1], pFrame->data[2], pFrame->linesize[1], (unsigned char *)out_buf, pCodecCtx->width, pCodecCtx->height);
                
                if (pCodecCtx->width <= videoWidth && pCodecCtx->height <= videoHeight) {
                    *out_width = self.videoWidth;
                    *out_height = self.videoHeight;
                    *out_size = self.videoWidth * self.videoHeight * 2;
                    memcpy(out_buf, picture.data[0], *out_size);
                } else
                    continue;
            }
            
        } else
            continue;
    }
}

@end
