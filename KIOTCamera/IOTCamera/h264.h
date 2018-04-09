//
//  h264.h
//  IOTCamera
//
//  Created by Cloud Hsiao on 12/8/3.
//
//

#import <Foundation/Foundation.h>


@interface h264 : NSObject
{

}

- (id)init;
- (void)release;
- (void)decode:(char*)in_buf SizeOfBufferToDecode:(int)in_size decodedBuffer:(char *)out_buf decodedBufferSize:(int *)out_size imgWidth:(int *)width imageHeight:(int *)height;
@end
