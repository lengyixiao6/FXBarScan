//
//  ViewController.m
//  FXBarScan
//
//  Created by Benniu15 on 16/3/15.
//  Copyright © 2016年 Wind. All rights reserved.
//

#import "ViewController.h"
#import "FXNativeScanController.h"
#import "FXCreatQr.h"

@interface ViewController (){
    
    UITextView  *_textView;
    UIImageView *_imgView;
    UILabel     *_readInfoLab;
}

@end

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"二维码/条形码";
    
    [self setupView];
}

- (void)setupView{
    
    UIButton * nativeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nativeBtn.tag = 100;
    nativeBtn.frame = CGRectMake(80, 80, self.view.frame.size.width-160, 40);
    [nativeBtn setTitle:@"原生二维码扫描" forState:UIControlStateNormal];
    [nativeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [nativeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    nativeBtn.layer.borderWidth = 0.5;
    nativeBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [nativeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nativeBtn];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(40, 160, self.view.frame.size.width-80, 60)];
    _textView.text = @"请输入信息生成二维码...";
    _textView.layer.borderWidth = 0.5;
    _textView.layer.borderColor = [UIColor grayColor].CGColor;
    _textView.layer.cornerRadius = 8.0;
    _textView.layer.masksToBounds = YES;
    [self.view addSubview:_textView];
    
    UIButton * creatQRNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    creatQRNavBtn.tag = 400;
    creatQRNavBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    creatQRNavBtn.frame = CGRectMake(40, 260, SCREEN_W/4, 30);
    [creatQRNavBtn setTitle:@"原生二维码" forState:UIControlStateNormal];
    [creatQRNavBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [creatQRNavBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    creatQRNavBtn.layer.borderWidth = 0.5;
    creatQRNavBtn.layer.borderColor = [UIColor grayColor].CGColor;
    creatQRNavBtn.layer.cornerRadius = 8.0;
    creatQRNavBtn.layer.masksToBounds = YES;
    [creatQRNavBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:creatQRNavBtn];
    
    UIButton * creatQRBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    creatQRBtn.tag = 500;
    creatQRBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    creatQRBtn.frame = CGRectMake(40, 320, SCREEN_W/4, 30);
    [creatQRBtn setTitle:@"第三方二维码" forState:UIControlStateNormal];
    [creatQRBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [creatQRBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    creatQRBtn.layer.borderWidth = 0.5;
    creatQRBtn.layer.borderColor = [UIColor grayColor].CGColor;
    creatQRBtn.layer.cornerRadius = 8.0;
    creatQRBtn.layer.masksToBounds = YES;
    [creatQRBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:creatQRBtn];
    
    //二维码显示
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2+60, 230, 200, 200)];
    [self.view addSubview:_imgView];
    _imgView.image = [FXCreatQR creatQRFromString:_textView.text withSize:200];
    
    //读取本地的图片二维码
    UIButton * readInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    readInfoBtn.tag = 600;
    readInfoBtn.frame = CGRectMake(80, 440, self.view.frame.size.width-160, 40);
    [readInfoBtn setTitle:@"读取本地的图片二维码" forState:UIControlStateNormal];
    [readInfoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [readInfoBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    readInfoBtn.layer.borderWidth = 1.0;
    readInfoBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [readInfoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readInfoBtn];
    
    _readInfoLab = [[UILabel alloc] initWithFrame:CGRectMake(30, 500, self.view.frame.size.width-60, 60)];
    _readInfoLab.font = [UIFont systemFontOfSize:14];
    _readInfoLab.numberOfLines = 0;
    _readInfoLab.textColor = [UIColor redColor];
    _readInfoLab.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    [self.view addSubview:_readInfoLab];
}

- (void)btnClick:(UIButton *)btn{
    
    if (btn.tag == 100) {
        
        FXNativeScanController *nativeScanVC = [[FXNativeScanController alloc] init];
        [self.navigationController pushViewController:nativeScanVC animated:YES];
        
    }else if(btn.tag == 400){
        
        _imgView.image = [FXCreatQR creatQRFromString:_textView.text withSize:200];
        
    }else if(btn.tag == 500){
        
        UIImage * imge = [FXCreatQR createNativeQRForString:_textView.text withSize:200];
        _imgView.image = [FXCreatQR imageBlackToTransparent:imge withRed:[self randomNumber] andGreen:[self randomNumber] andBlue:[self randomNumber]];
    }else{
        
        //需要传入一张二维码图片
        NSString * infoStr = [FXCreatQR fromQRImgeReadInfo:[UIImage imageNamed:@"test.png"]];
        _readInfoLab.text = infoStr;
    }
}
//随机数
- (CGFloat)randomNumber{
    
    NSInteger p = rand()%255;
    return (CGFloat)p;
}


@end
