//
//  FXNativeScanController.m
//  FXBarScan
//
//  Created by Benniu15 on 16/3/15.
//  Copyright © 2016年 Lengyixiao. All rights reserved.
//

#import "FXNativeScanController.h"
#import <AVFoundation/AVFoundation.h>

@interface FXNativeScanController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>{
    
    BOOL _upOrDown;
    NSTimer *_timer;
}

@property (nonatomic, strong) UIImageView  *barView;
@property (nonatomic, strong) UIImageView  *scanLineView;
@property (nonatomic, strong) UILabel      *titleLab;
@property (nonatomic, strong) UIView       *bottomView;
@property (nonatomic, strong) UIButton     *qrcodeBtu;
@property (nonatomic, strong) UIButton     *barcodeBtu;
@property (nonatomic, strong) UILabel      *qrcodeLab;
@property (nonatomic, strong) UILabel      *barcodeLab;

@property (nonatomic, strong) AVCaptureDevice            *device;
@property (nonatomic, strong) AVCaptureDeviceInput       *input;
@property (nonatomic, strong) AVCaptureMetadataOutput    *output;
@property (nonatomic, strong) AVCaptureSession           *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;

@end

#define IOS_Version [[[UIDevice currentDevice] systemVersion] floatValue]
#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H [UIScreen mainScreen].bounds.size.height
#define BAR_W     240.0
#define BAR_H     240.0
#define BOTTOM_H  80.0

@implementation FXNativeScanController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"原生";
    
    [self setupView];
}
- (void)setupView{
    
    self.titleLab.text = @"请将二维码/条码置于扫描框内";
    self.bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    [self.qrcodeBtu addTarget:self action:@selector(btuClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.barcodeBtu addTarget:self action:@selector(btuClick:) forControlEvents:UIControlEventTouchUpInside];
    _upOrDown = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
    
    [self setupMediaScan];
}
//设置扫描
- (void)setupMediaScan{
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (error) {
        
        return;
    }
    
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.rectOfInterest =[self rectOfInterestByScanViewRect:self.barView.frame];

    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input]){
        
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]){
        
        [self.session addOutput:self.output];
    }
    
    //条码类型AVMetadataObjectTypeQRCode（必须放在这里，否则报错）
    self.output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code];
    
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResize;
    self.preview.frame =self.view.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    [self.view bringSubviewToFront:self.barView];
    
    [self setOverView];
    
    //session->Start
    [self.session startRunning];
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0){
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        //获取扫描结果
        stringValue = metadataObject.stringValue;
    }
    
    if (IOS_Version >= 9.0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"扫描结果：%@", stringValue] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [self.session startRunning];
        }]];
        [self presentViewController:alert animated:true completion:nil];
        
    }else{
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"扫描结果：%@", stringValue] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
    [self.session stopRunning];
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [self.session startRunning];
}
- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    
    CGFloat x = rect.origin.y / SCREEN_H;
    CGFloat y = rect.origin.x / SCREEN_W;
    CGFloat w = rect.size.height / SCREEN_H;
    CGFloat h = rect.size.width / SCREEN_W;
    
    return CGRectMake(x,y,w,h);
}

#pragma mark - 添加半透明效果
- (void)setOverView {
    
    CGFloat x = CGRectGetMinX(self.barView.frame);
    CGFloat y = CGRectGetMinY(self.barView.frame);
    CGFloat w = CGRectGetWidth(self.barView.frame);
    CGFloat h = CGRectGetHeight(self.barView.frame);
    
    [self creatView:CGRectMake(0, 0, SCREEN_W, y) index:1];
    [self creatView:CGRectMake(0, y, x, h) index:2];
    [self creatView:CGRectMake(0, y + h, SCREEN_W, SCREEN_H - y - h-80) index:3];
    [self creatView:CGRectMake(x + w, y, SCREEN_W - x - w, h) index:4];
    
    //切换扫描框大小用的
    [self creatView:CGRectMake(x, y, w, 70) index:5];
    [self creatView:CGRectMake(x, y + h - 70, w, 70) index:6];
    UIView * view5 = [self.view viewWithTag:1005];
    UIView * view6 = [self.view viewWithTag:1006];
    view5.hidden = YES;
    view6.hidden = YES;
}
- (void)creatView:(CGRect)rect index:(NSInteger)index{
    
    UIView * view = [[UIView alloc] initWithFrame:rect];
    view.tag = 1000 + index;
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.5;
    [self.view addSubview:view];
}
//切换扫描
- (void)btuClick:(UIButton *)btn{
    
    UIView * view5 = [self.view viewWithTag:1005];
    UIView * view6 = [self.view viewWithTag:1006];
    
    if (btn == self.qrcodeBtu) {
        
        self.qrcodeBtu.selected = YES;
        self.barcodeBtu.selected = NO;
        self.qrcodeLab.textColor = [UIColor colorWithRed:31/255.0 green:185/255.0 blue:34/255.0 alpha:1];
        self.barcodeLab.textColor = [UIColor lightGrayColor];
        
        self.barView.frame = CGRectMake((SCREEN_W-BAR_W)/2, (SCREEN_H-BAR_H)/2-80, BAR_W, BAR_H);
        self.scanLineView.hidden = NO;
        view5.hidden = YES;
        view6.hidden = YES;
        
    }else{
        
        self.qrcodeBtu.selected = NO;
        self.barcodeBtu.selected = YES;
        self.qrcodeLab.textColor = [UIColor lightGrayColor];
        self.barcodeLab.textColor = [UIColor colorWithRed:31/255.0 green:185/255.0 blue:34/255.0 alpha:1];
        
        self.barView.frame = CGRectMake((SCREEN_W-BAR_W)/2, (SCREEN_H-BAR_H)/2-80+70, BAR_W, BAR_H-140);
        self.scanLineView.hidden = YES;
        view5.hidden = NO;
        view6.hidden = NO;
    }
}
//延迟加载
- (void)lineAnimation{
    
    if (!_upOrDown) {
        
        CGRect rect = self.scanLineView.frame;
        rect.origin.y += 2.5;
        self.scanLineView.frame = rect;
        if (rect.origin.y > (self.barView.bounds.origin.y + BAR_H -5)) {
            
            _upOrDown = YES;
        }
    }else{
        
        CGRect rect = self.scanLineView.frame;
        rect.origin.y -= 2.5;
        self.scanLineView.frame = rect;
        if (rect.origin.y < (self.barView.bounds.origin.y+5)) {
            
            _upOrDown = NO;
        }
    }
}
- (UIImageView *)barView{
    
    if (!_barView) {
        
        _barView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_W-BAR_W)/2, (SCREEN_H-BAR_H)/2-80, BAR_W, BAR_H)];
        _barView.image = [UIImage imageNamed:@"scanBg"];
        [self.view addSubview:_barView];
    }
    return _barView;
}
- (UIImageView *)scanLineView{
    
    if (!_scanLineView) {
        
        _scanLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, BAR_W, 3)];
        _scanLineView.image = [UIImage imageNamed:@"scanLine"];
        [self.barView addSubview:_scanLineView];
    }
    return _scanLineView;
}
- (UILabel *)titleLab{
    
    if (!_titleLab) {
        
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_W-BAR_W)/2, (SCREEN_H-BAR_H)/2+BAR_H-BOTTOM_H, BAR_W, 36)];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_titleLab];
    }
    return _titleLab;
}
- (UIView *)bottomView{
    
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_H-BOTTOM_H, SCREEN_W, BOTTOM_H)];
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}
- (UIButton *)qrcodeBtu{
    
    if (!_qrcodeBtu) {
        
        _qrcodeBtu = [UIButton buttonWithType:UIButtonTypeCustom];
        _qrcodeBtu.frame = CGRectMake(SCREEN_W/2-60, 10, 50, 50);
        [_qrcodeBtu setImage:[UIImage imageNamed:@"ScanQRCode"] forState:UIControlStateNormal];
        [_qrcodeBtu setImage:[UIImage imageNamed:@"ScanQRCode_HL"] forState:UIControlStateSelected];
        _qrcodeBtu.selected = YES;
        [self.bottomView addSubview:_qrcodeBtu];
        
        self.qrcodeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_W/2-60, 54, 50, 20)];
        self.qrcodeLab.text = @"扫码";
        self.qrcodeLab.textColor = [UIColor colorWithRed:31/255.0 green:185/255.0 blue:34/255.0 alpha:1];
        self.qrcodeLab.font = [UIFont systemFontOfSize:13];
        self.qrcodeLab.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:self.qrcodeLab];
    }
    return _qrcodeBtu;
}
- (UIButton *)barcodeBtu{
    
    if (!_barcodeBtu) {
        
        _barcodeBtu = [UIButton buttonWithType:UIButtonTypeCustom];
        _barcodeBtu.frame = CGRectMake(SCREEN_W/2+20, 10, 50, 50);
        [_barcodeBtu setImage:[UIImage imageNamed:@"ScanStreet"] forState:UIControlStateNormal];
        [_barcodeBtu setImage:[UIImage imageNamed:@"ScanStreet_HL"] forState:UIControlStateSelected];
        [self.bottomView addSubview:_barcodeBtu];
        
        self.barcodeLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_W/2+20, 54, 50, 20)];
        self.barcodeLab.text = @"街景";
        self.barcodeLab.textColor = [UIColor lightGrayColor];
        self.barcodeLab.font = [UIFont systemFontOfSize:13];
        self.barcodeLab.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:self.barcodeLab];
    }
    return _barcodeBtu;
}

- (void)dealloc{
    
    [_timer invalidate];
    _timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
