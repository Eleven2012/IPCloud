//
//  h264.m
//  IOTCamera
//
//  Created by Cloud Hsiao on 12/8/3.
//
//

#import "h264.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libavcodec/avcodec.h"
#include "yuv420torgb24.h"

@interface h264()
{
    AVCodec            *pCodec;
    AVPacket           packet;
    AVCodecContext     *pCodecCtx;
    AVFrame            *pFrame;
    AVPicture          picture;
    struct SwsContext  *img_convert_ctx;
    BOOL init_first;
}
@end

@implementation h264

-(id)init
{
    self = [super init];
    
    if (self) {

        init_first = false;
        yuv420torgb24_c_init();
        // AVDictionary *opts = NULL;

        // Register all formats and codecs
        av_register_all();
        av_init_packet(&packet);
        
        // av_dict_set(&opts, "profile", "baseline", 0);
        
        // Find the decoder for the 264
        pCodec=avcodec_find_decoder(CODEC_ID_H264);
        
        if(pCodec == NULL) {
            NSLog(@"h264 codec not found");
        }
                
        pCodecCtx = avcodec_alloc_context3(pCodec);
        
        // Open codec
        if(avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
            NSLog(@"could not open h264 codec");
        }
        
        
        // Allocate video frame
        pFrame=avcodec_alloc_frame();
        //    pCodecCtx->width = 640;
        //    pCodecCtx->height = 480;
        //    pCodecCtx->pix_fmt = PIX_FMT_YUV420P;
        NSLog(@"init h264 codec success");
    }
    return self;
}

-(void)release
{
    // Free scaler
    //sws_freeContext(img_convert_ctx);
    
    // Free RGB picture
    //avpicture_free(&picture);
    
    // Free the YUV frame
    av_free(pFrame);
    
    // Close the codec
    if (pCodecCtx) avcodec_close(pCodecCtx);
    
    [super release];
}

/*
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
{    [self setupScaler];
    sws_scale (img_convert_ctx,pFrame->data, pFrame->linesize,
               0, pCodecCtx->height,
               picture.data, picture.linesize);
}
*/

- (void)decode:(char*)in_buf SizeOfBufferToDecode:(int)in_size decodedBuffer:(char *)out_buf decodedBufferSize:(int *)out_size imgWidth:(int *)out_width imageHeight:(int *)out_height
{
    // int parserLength_In, parserLen;
    uint8_t *parserBuffer_In;
    int got_picture;
    int videoLen = 0;
    
    packet.size = in_size;
    packet.data = (unsigned char *)in_buf;
    // parserLength_In = packet.size;
    parserBuffer_In = packet.data;
    
    *out_size = 0;
    *out_width = 0;
    *out_height = 0;    

    while(packet.size > 0)
    {
        if(init_first == true)
        {
            videoLen = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, &packet);
            init_first = false;
        }
        
        videoLen =  avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, &packet);
        
        if(videoLen < 0)
        {
            break;
        }
                    
        if(videoLen >= 0 && got_picture)
        {
            yuv420torgb24_c(pFrame->data[0], pFrame->linesize[0], pFrame->data[1], pFrame->data[2],
                            pFrame->linesize[1], (unsigned char *)out_buf, pCodecCtx->width, pCodecCtx->height);
            
            *out_width = pCodecCtx->width;
            *out_height = pCodecCtx->height;
            *out_size = pCodecCtx->width * pCodecCtx->height * 3;
        }
        
        packet.size -= videoLen;
        packet.data += videoLen;                
    }
    
    /*
    packet.size = in_size;
    packet.data = (unsigned char *)in_buf;
    int got_picture_ptr=0;
    int nImageSize = 0;
    int nWidth = 0;
    int nHeight = 0;
    
    nImageSize = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture_ptr, &packet);
    
    if (nImageSize > 0)
    {
        if (pFrame->data[0])
        {
            // [self convertFrameToRGB];
            yuv420torgb24_c(pFrame->data[0], pFrame->linesize[0], pFrame->data[1], pFrame->data[2],
                            pFrame->linesize[1], (unsigned char *)out_buf, pCodecCtx->width, pCodecCtx->height);
            
            nWidth = pCodecCtx->width;
            nHeight = pCodecCtx->height;
                        
            *width = pCodecCtx->width;
            *height = pCodecCtx->height;
            *out_size = pCodecCtx->width * pCodecCtx->height * 3;
            // memcpy(out_buf, picture.data[0], *out_size);
        }
    }
    */
}
@end

