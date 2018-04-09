//#ifndef _H264IPHONE_H_
//#define _H264IPHONE_H_
//
//
//// ************************ OS Selection ******************************  
////#define OS_ANDROID
//#define OS_IPHONE
//
//
//#ifdef __cplusplus
//extern "C" {
//#endif //__cplusplus
//
//
//
////@para	*framePara: int xx[4]
//    int DecoderNal(uint8_t *in, int inLen, int *framePara, uint8_t *out);
//
//#ifdef __cplusplus
//}
//#endif //__cplusplus
//
//#endif

#import <UIKit/UIKit.h>

@interface H264iPhone : NSObject
{
    struct AVCodecContext *c;
    struct AVFrame *picture;
    
    long int crv_tab[256];
    long int cbu_tab[256];
    long int cgu_tab[256];
    long int cgv_tab[256];
    long int tab_76309[256];
    
    unsigned char clp[1024];
    
    struct AVCodec *codec;
}
-(int)InitDecoder;
-(int)UninitDecoder;
-(int)DecoderNal:(uint8_t *)in: (int )inLen:(int *)framePara:(uint8_t *)out;
@end