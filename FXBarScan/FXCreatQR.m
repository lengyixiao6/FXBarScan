//
//  FXCreatQr.m
//  FXBarScan
//
//  Created by Benniu15 on 16/3/15.
//  Copyright © 2016年 Wind. All rights reserved.
//

#import "FXCreatQr.h"

@implementation FXCreatQR

#pragma mark - ***原生生成二维码***
+ (UIImage *)createNativeQRForString:(NSString *)String withSize:(CGFloat)size{
    
    NSData *stringData = [String dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    //设定容错率：L:7%   M:15%    Q:25%    H:30%
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    //qrFilter.outputImage 是CIImage类型
    return [self createNonInterpolatedUIImageFormCIImage:qrFilter.outputImage withSize:size];
}
//CIImage处理
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size{
    
    CGRect rect = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(rect), size/CGRectGetHeight(rect));
    //创建bitmap;
    size_t width = CGRectGetWidth(rect) * scale;
    size_t height = CGRectGetHeight(rect) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:rect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, rect, bitmapImage);
    //保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    
    free((void*)data);
}
//改变黑白二维码的颜色
+ (UIImage *)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    //遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
}

#pragma mark - ***libqrencode生成二维码***

#define QR_margin 3
+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size {
    
    unsigned char *data = 0;
    int width;
    data = code->data;
    width = code->width;
    float zoom = (double)size / (code->width + 2.0 * QR_margin);
    CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
    
    //draw
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin = CGPointMake((j + QR_margin) * zoom,(i + QR_margin) * zoom);
                CGContextAddRect(ctx, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(ctx);
}
+ (UIImage *)creatQRFromString:(NSString *)string withSize:(CGFloat)size{
    
    if (![string length]) {
        return nil;
    }
    
    QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
    if (!code) {
        return nil;
    }
    
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
    CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
    
    // draw QR on this context
    [self drawQRCode:code context:ctx size:size];
    
    // get image
    CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
    UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
    
    // some releases
    CGContextRelease(ctx);
    CGImageRelease(qrCGImage);
    CGColorSpaceRelease(colorSpace);
    QRcode_free(code);
    
    return qrImage;
}

#pragma mark - ***读取本地图片的二维码***
+ (NSString *)fromQRImgeReadInfo:(UIImage *)qrImg{
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
    CIImage *image = [[CIImage alloc] initWithImage:qrImg];
    NSArray *features = [detector featuresInImage:image];
    NSMutableString * infoStr = [[NSMutableString alloc] init];
    for (CIQRCodeFeature *feature in features){
        
        [infoStr appendString:feature.messageString];
    }
    return infoStr;
}


@end
