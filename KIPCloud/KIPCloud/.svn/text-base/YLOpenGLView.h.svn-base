//
//  YLOpenGLView.h
//  KIPCloud
//
//  Created by 孔雨露 on 2017/7/14.
//  Copyright © 2017年 孔雨露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "YLMonitorDelegate.h"

@interface YLOpenGLView : UIView



@property (nonatomic, assign) CGSize minZoom;
@property (nonatomic, assign) CGSize maxZoom;
@property (nonatomic, assign) CGPoint gestureStartPoint;
@property (nonatomic, assign) NSInteger minGestureLength;
@property (nonatomic, assign) NSInteger maxVariance;
@property (nonatomic, weak)  id<YLMonitorDelegate> delegate;
@property (nonatomic, strong) Camera* camera;

@property (readonly) GLuint positionRenderTexture;
@property (readonly) GLuint videoFrameTexture;


- (void)tearDownGL;
- (void)renderVideo:(CVImageBufferRef)videoFrame;
- (void)drawFrame;

- (BOOL)loadVertexShader:(NSString *)vertexShaderName fragmentShader:(NSString *)fragmentShaderName forProgram:(GLuint *)programPointer;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

// OpenGL drawing
- (BOOL)createFramebuffers;
- (void)destroyFramebuffer;
- (void)setDisplayFramebuffer;
- (void)setPositionThresholdFramebuffer;
- (BOOL)presentFramebuffer;


- (void)attachCamera:(Camera *)camera;
- (void)deattachCamera;
- (void)setMinimumGestureLength:(NSInteger)length MaximumVariance:(NSInteger)variance;

@end
