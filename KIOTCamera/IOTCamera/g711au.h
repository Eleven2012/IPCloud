#ifndef _G711AU_H
#define _G711AU_H

#ifdef __cplusplus
extern "C" {
#endif

 int g711a_Encode(unsigned char *src, unsigned int srclen,unsigned char *dest, unsigned int *dstlen);
 int g711a_Decode(unsigned char *src, unsigned int srclen,unsigned char *dest, unsigned int *dstlen);

 int g711u_Encode(unsigned char *src, unsigned int srclen,unsigned char *dest, unsigned int *dstlen);
 int g711u_Decode(unsigned char *src, unsigned int srclen,unsigned char *dest, unsigned int *dstlen);

#ifdef __cplusplus
}
#endif

#endif

