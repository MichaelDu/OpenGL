//
//  AppDelegate.h
//  Tutorial01
//
//  Created by Michael Du on 13-8-22.
//  Copyright (c) 2013年 com.redianying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    OpenGLView *_glView;
}
@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet OpenGLView *glView;

@end
