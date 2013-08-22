//
//  GLESUtils.h
//  Tutorial01
//
//  Created by Michael Du on 13-8-22.
//  Copyright (c) 2013年 com.redianying. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/es2/gl.h>

@interface GLESUtils : NSObject


// Create a shader object, load the shader source string, and compile the shader.
//
+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;

+(GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath;


@end
