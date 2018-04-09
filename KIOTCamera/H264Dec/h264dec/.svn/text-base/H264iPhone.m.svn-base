
/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "H264.h"

#include "avcodec.h"
#import "H264iPhone.h"


#define SCALEY     76309
#define SCALECrv   104597
#define SCALECbu   132201
#define SCALECgu   25675
#define SCALECgv   53279

#define SHIFTY     16
#define SHIFTCC    128
#define SHIFTCrv   128
#define SHIFTCbu   128
#define SHIFTCgu   128
#define SHIFTCgv   128

extern AVCodec h264_decoder;

@implementation H264iPhone

-(void)yuv420torgb24_c_init
{        
	long int crv,cbu,cgu,cgv;
	int i,ind;   
	
	crv = SCALECrv; cbu = SCALECbu;
	cgu = SCALECgu; cgv = SCALECgv;
	
	for(i = 0; i < 256; i++){
		crv_tab[i] = (i-SHIFTCrv) * crv;
		cbu_tab[i] = (i-SHIFTCbu) * cbu;
		cgu_tab[i] = (i-SHIFTCgu) * cgu;
		cgv_tab[i] = (i-SHIFTCgv) * cgv;
		tab_76309[i]= SCALEY*(i-SHIFTY);
	}
	
	for(i=0; i<384; i++) clp[i] =0;
	ind=384;
	for(i=0;i<256; i++) clp[ind++]=i;
	ind=640;
	for(i=0;i<384;i++) clp[ind++]=255;
}

//how to use:
//yuv420torgb24_c(y, yStride, v, u, uvStride, rgb, 320, 240);
-(void)yuv420torgb24_c:(unsigned char *)src0:(int)stride_y:(
					  unsigned char *)src1:(unsigned char *)src2:(int) stride_uv:
					  (unsigned char *)dst_ori:(int) width:(int) height
{
    int y1,y2,u,v;    
    unsigned char *py1,*py2, *pSrc1, *pSrc2;
	int yDeltaPerRow =(stride_y-width+stride_y), 
		uvDeltaPerRow=((stride_uv-width+stride_uv)>>1);
	
	int i,j, c1, c2, c3, c4;   
    unsigned char *d1, *d2;
	
    py1=src0;
    py2=src0+stride_y;
	pSrc1=src1;
	pSrc2=src2;
	
    d1=dst_ori;
    d2=d1+3*width;
    for(j=0; j<height; j+=2)	//height/2
    {
        for(i=0; i<width; i+=2) //width/2
        {
            u = *pSrc1++;   
            v = *pSrc2++;   
			
            c1 = crv_tab[v];   
            c2 = cgu_tab[u];
            c3 = cgv_tab[v];   
            c4 = cbu_tab[u];   
			
            //up-left   
            y1 = tab_76309[*py1++];
            *d1++ = clp[384+((y1 + c1)>>16)];     
            *d1++ = clp[384+((y1 - c2 - c3)>>16)];   
            *d1++ = clp[384+((y1 + c4)>>16)];   
			
            //down-left   
            y2 = tab_76309[*py2++];   
            *d2++ = clp[384+((y2 + c1)>>16)];     
            *d2++ = clp[384+((y2 - c2 - c3)>>16)];   
            *d2++ = clp[384+((y2 + c4)>>16)];   
			
			
            //up-right   
            y1 = tab_76309[*py1++];   
            *d1++ = clp[384+((y1 + c1)>>16)];     
            *d1++ = clp[384+((y1 - c2 - c3)>>16)];   
            *d1++ = clp[384+((y1 + c4)>>16)];   
			
            //down-right   
            y2 = tab_76309[*py2++];   
            *d2++ = clp[384+((y2 + c1)>>16)];     
            *d2++ = clp[384+((y2 - c2 - c3)>>16)];   
            *d2++ = clp[384+((y2 + c4)>>16)];   
        }//for(width)--end
		
        d1 += 3*width;   
        d2 += 3*width;
		
        py1+= yDeltaPerRow;
        py2+= yDeltaPerRow;
		pSrc1+=uvDeltaPerRow;
		pSrc2+=uvDeltaPerRow;
    }//for(height)--end
}


-(int)InitDecoder
{
    NSLog(@"InitDecoder");
    //多画面修改

	codec = &h264_decoder;
    
	[self yuv420torgb24_c_init];
    // find the mpeg1 video decoder
    avcodec_init();
    avcodec_register_all();
    
    c= avcodec_alloc_context();
	
    // For some codecs, such as msmpeg4 and mpeg4, width and height
    // MUST be initialized there because this information is not
    // available in the bitstream.
    if(avcodec_open(c, codec) < 0) {
        //fprintf(stderr, "could not open codec\n");
        return -1;
    }
	
	{
		H264Context *h = c->priv_data;
		MpegEncContext *s = &h->s;
		s->dsp.idct_permutation_type =1;
		dsputil_init(&s->dsp, c);
	}
	picture  = avcodec_alloc_frame();
    
	return 1;
}

-(int)UninitDecoder
{
    NSLog(@"UninitDecoder");
	if(c){
		avcodec_close(c);
		av_free(c);
		c=NULL;
	}

	if(picture){
		av_free(picture);
		picture = NULL;
	}

	return 1;	
}

//@para	*framePara: int xx[4]
-(int)DecoderNal:(uint8_t *)in: (int )inLen:(int *)framePara:(uint8_t *)out
{
    
	int got_picture;
	int consumed_bytes = avcodec_decode_video(c, picture, &got_picture, in, inLen);
    
	framePara[0]=got_picture;
//    NSLog(@"DecoderNal %d %d %d %d",c->width,c->height,consumed_bytes,got_picture);
	if(consumed_bytes > 0 && got_picture>0)
	{
		framePara[1]=0;
		framePara[2]=c->width;
		framePara[3]=c->height;
        
        

        [self yuv420torgb24_c:picture->data[0] :picture->linesize[0] :picture->data[1] :picture->data[2] :picture->linesize[1] :(unsigned char *)out :c->width :c->height];
//		yuv420torgb24_c(picture->data[0], picture->linesize[0], picture->data[1], picture->data[2],
//						picture->linesize[1], (unsigned char *)out, c->width, c->height);

	}
    
	return consumed_bytes;
}
@end
