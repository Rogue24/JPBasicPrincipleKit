//
//  ViewController.m
//  01-性能优化-异步图片解码
//
//  Created by 周健平 on 2019/12/28.
//  Copyright © 2019 周健平. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)startDecode:(id)sender {
    
    if (self.imageView.image) {
        [UIView transitionWithView:self.imageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.imageView.image = nil;
        } completion:^(BOOL finished) {
            [self startDecode:sender];
        }];
        return;
    }
    
    /*
     * self.imageView.image = [UIImage imageNamed:@"image111"];
        - 这种方法加载的图片其实不能直接显示到屏幕上，这本来是图片经过压缩后的二进制数据，渲染到屏幕上得需要进行解码，要解码成屏幕所需要的那种格式才能显示到屏幕上
        - 首先等imageView真正显示出来的时候（有了frame和添加到父视图上后），才去拿这个二进制数据去进行解码操作，并且默认是在【主线程】上完成的，所以如果图片很大，就会造成卡顿。
     */
    
    // 异步解码（在子线程解码成屏幕所需要的格式）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageNamed:@"image111"];
        
        // 获取CGImage
        CGImageRef cgImage = image.CGImage;
        
        // alphaInfo
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }
        
        // bitmapInfo
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
        
        // size
        CGFloat pixelWidth = CGImageGetWidth(cgImage);
        CGFloat pixelHeight = CGImageGetHeight(cgImage);
        
        // colorSpace
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // context【创建位图上下文】
        CGContextRef context = CGBitmapContextCreate(NULL, pixelWidth, pixelHeight, 8, 0, colorSpace, bitmapInfo);
        
        // draw【将图片数据画到位图上下文去，完成解码操作】
        CGContextDrawImage(context, CGRectMake(0, 0, pixelWidth, pixelHeight), cgImage);
        
        // get CGImage【从位图上下文中获取解码后的图片】
        cgImage = CGBitmapContextCreateImage(context);
        
        // into UIImage【把图片包装成UIImage，这是解码后的UIImage】
        UIImage *decodeImage = [UIImage imageWithCGImage:cgImage];// scale:image.scale orientation:image.imageOrientation];
        
        // release
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        CGImageRelease(cgImage);
        
        // 回到主线程显示
        dispatch_async(dispatch_get_main_queue(), ^{
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            [self.imageView.layer addAnimation:transition forKey:@"JPFadeAnimation"];
            self.imageView.image = decodeImage;
        });
    });
    
}

@end
