//
//  OpenGLView.m
//  Tutorial01
//
//  Created by Michael Du on 13-8-22.
//  Copyright (c) 2013年 com.redianying. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"

@interface OpenGLView()

-(void)setupLayer;
-(void)setupProgram;

@end

@implementation OpenGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupProgram
{
    // Load shaders
    //
    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader"
                                                                  ofType:@"glsl"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader"
                                                                    ofType:@"glsl"];
    GLuint vertexShader = [GLESUtils loadShader:GL_VERTEX_SHADER
                                   withFilepath:vertexShaderPath];
    GLuint fragmentShader = [GLESUtils loadShader:GL_FRAGMENT_SHADER
                                     withFilepath:fragmentShaderPath];
    
    // Create program, attach shaders.
    _programHandle = glCreateProgram();
    if (!_programHandle) {
        NSLog(@"Failed to create program.");
        return;
    }
    
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fragmentShader);
    
    // Link program
    //
    glLinkProgram(_programHandle);
    
    // Check the link status
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked );
    if (!linked)
    {
        GLint infoLen = 0;
        glGetProgramiv (_programHandle, GL_INFO_LOG_LENGTH, &infoLen );
        
        if (infoLen > 1)
        {
            char * infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog (_programHandle, infoLen, NULL, infoLog );
            NSLog(@"Error linking program:\n%s\n", infoLog );
            
            free (infoLog );
        }
        
        glDeleteProgram(_programHandle);
        _programHandle = 0;
        return;
    }
    
    glUseProgram(_programHandle);
    
    // Get attribute slot from program
    //
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
     // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}


- (void)setupContext {
      // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    //设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    //为color renderbuffer分配内存空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    //  设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

-(void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

-(void)render
{
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };
    
    // Load the vertex data
    //
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw triangle
    //
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)layoutSubviews {
    [self setupLayer];
    [self setupContext];
    [self destoryRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self setupProgram];
    [self render];
}

+(Class)layerClass {
     // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
