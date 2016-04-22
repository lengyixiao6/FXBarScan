//
//  FXCreatQr.h
//  FXBarScan
//
//  Created by Benniu15 on 16/3/15.
//  Copyright © 2016年 Wind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "qrencode.h"

@interface FXCreatQR : NSObject

//使用libqrencode生成二维码
+ (UIImage *)creatQRFromString:(NSString *)string withSize:(CGFloat)size;

//原生方法生成二维码
+ (UIImage *)createNativeQRForString:(NSString *)String withSize:(CGFloat)size;

//将黑白二维码转为彩色二维码
+ (UIImage *)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue;

//读取本地图片的二维码
+ (NSString *)fromQRImgeReadInfo:(UIImage *)qrImg;

@end
