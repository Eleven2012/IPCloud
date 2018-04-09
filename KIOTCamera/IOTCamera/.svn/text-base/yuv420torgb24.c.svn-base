//
//  yuv420torgb24.c
//  IOTCamera
//
//  Created by Cloud Hsiao on 12/8/13.
//
//

#include <stdio.h>
#include "yuv420torgb24.h"

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

long int crv_tab[256];
long int cbu_tab[256];
long int cgu_tab[256];
long int cgv_tab[256];
long int tab_76309[256];

unsigned char clp[1024];

void yuv420torgb24_c_init() {
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
void  yuv420torgb24_c(unsigned char *src0, int stride_y,
					  unsigned char *src1, unsigned char *src2, int stride_uv,
					  unsigned char *dst_ori, int width, int height)
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