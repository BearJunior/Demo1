//
//  ViewController.m
//  Demo-1
//
//  Created by admin on 16/10/10.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ViewController.h"
#import "DrawView.h"
#import "ProportionCutView.h"
#import "CurveToneView.h"

@interface ViewController ()
{
    //记录放大比例
    float _proportion;
}
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) DrawView *drawView;
@property (nonatomic, strong) ProportionCutView *proportionCutView;
@property (nonatomic, strong) CurveToneView *curveToneView;

/** 毛玻璃效果*/
//@property (nonatomic, strong) UIImageView *lightImageView;
//@property (nonatomic, strong) UIVisualEffectView *effectView;
//@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self setImgWithImage:[UIImage imageNamed:@"bg2.jpg"]];
//    [self.view addSubview:self.effectView];
//    [self.view addSubview:self.lightImageView];
}

- (void)prepareUI
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.imageView];
    
    NSArray *titles = @[@"手势截图",@"4:3",@"16:9",@"色调"];
    float width = (kMainWidth - 3)/4;
    float height = 50;
    float y = kMainHeight - height;
    for (NSInteger i = 0; i < titles.count; i ++) {
        UIButton *button = [UIButton new];
        [button setTitle:titles[i] forState:0];
        button.tag = 100 + i;
        [button setBackgroundColor:[UIColor grayColor]];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake((width + 1) * i, y, width, height);
        [self.view addSubview:button];
    }
    
    UIButton *resetBtn = [UIButton new];
    [self.view addSubview:resetBtn];
    resetBtn.layer.cornerRadius = 5.0f;
    [resetBtn setTitle:@"Reset" forState:0];
    [resetBtn setBackgroundColor:[UIColor grayColor]];
    [resetBtn setTitleColor:[UIColor cyanColor] forState:0];
    resetBtn.frame = CGRectMake(20, AUTO_MATE_HEIGHT(30), AUTO_MATE_WIDTH(80), 40);
    [resetBtn addTarget:self action:@selector(resetBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *clipBtn = [UIButton new];
    [self.view addSubview:clipBtn];
    clipBtn.layer.cornerRadius = 5.0f;
    [clipBtn setTitle:@"clip" forState:0];
    [clipBtn setBackgroundColor:[UIColor grayColor]];
    [clipBtn setTitleColor:[UIColor cyanColor] forState:0];
    clipBtn.frame = CGRectMake(kMainWidth - AUTO_MATE_WIDTH(80) - 20, AUTO_MATE_HEIGHT(30), AUTO_MATE_WIDTH(80), 40);
    [clipBtn addTarget:self action:@selector(clipBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageView.userInteractionEnabled = YES;
}

#pragma mark - 懒加载
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, AUTO_MATE_HEIGHT(80), kMainWidth, AUTO_MATE_HEIGHT(400))];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (DrawView *)drawView
{
    if (!_drawView) {
        _drawView = [[DrawView alloc]initWithFrame:self.imageView.bounds];
    }
    return _drawView;
}

- (CurveToneView *)curveToneView
{
    if (!_curveToneView) {
        float x = self.imageView.frame.origin.x + 50;
        float width = self.imageView.frame.size.width - 100;
        float height = width * 4 / 5;
        float y = CGRectGetMaxY(self.imageView.frame) - height - 5;
        _curveToneView = [[CurveToneView alloc]initWithFrame:CGRectMake(x, y, width, height)];
    }
    return _curveToneView;
}

#pragma mark - 截图类型点击事件
- (void)buttonPressed:(UIButton *)sender
{
    [self resetBtnAction];
    //弱引用
    __weak __typeof(self) weakSelf = self;
    switch (sender.tag) {
        case 100:
        {
            _cutImgType = CutImgGestureType;
            [self.imageView addSubview:self.drawView];
        }
            break;
        case 101:
        {
            _cutImgType = CutImgfourType;
            self.proportionCutView = [[ProportionCutView alloc]initWithImageViewFrame:weakSelf.imageView.frame ImageViewImage:weakSelf.image ProportionType:FourThreeType WeakController:weakSelf];

            [self.view addSubview:self.proportionCutView];
            self.proportionCutView.drawViewR = self.imageView.frame;
            self.proportionCutView.center = self.imageView.center;
            [self.proportionCutView proportionFrameChanged];
        }
            break;
        case 102:
        {
            _cutImgType = CutImgSixteenType;
            self.proportionCutView = [[ProportionCutView alloc]initWithImageViewFrame:self.imageView.frame ImageViewImage:weakSelf.image ProportionType:SixteenNineType WeakController:weakSelf];
            [self.view addSubview:self.proportionCutView];
            self.proportionCutView.drawViewR = self.imageView.frame;
            self.proportionCutView.center = self.imageView.center;
            [self.proportionCutView proportionFrameChanged];
        }
            break;
        case 103:
        {
            _cutImgType = CureToneType;
            [self.view addSubview:self.curveToneView];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 返回点击事件
- (void)resetBtnAction
{
    [self.curveToneView removeFromSuperview];
    self.curveToneView = nil;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.drawView removeFromSuperview];
    self.drawView = nil;
    [self.proportionCutView removeFromSuperview];
    self.imageView.image = self.image;
}

#pragma mark - 截图点击事件
- (void)clipBtnAction:(UIButton *)sender
{
    switch (_cutImgType) {
        case CutImgGestureType:
        {
            NSDictionary *dic = [self.drawView cutImage];
            if (nil == dic) {
                break;
            }
            [self areaCutImgWithDic:dic];
        }
            break;
        case CutImgfourType:
        {
            [self proportionCutImg];
        }
            break;
        case CutImgSixteenType:
        {
            [self proportionCutImg];
        }
            break;
        default:
            break;
    }

    [self.drawView removeFromSuperview];
    self.drawView = nil;
    [self.proportionCutView removeFromSuperview];
}

#pragma mark - 设置图片
- (void)setImgWithImage:(UIImage *)img
{
    self.image = img;
    self.imageView.image = img;

    //根据imageView的高度计算出image宽高比的宽度
    float imageViewW;
    float imageViewH;
    imageViewW = self.imageView.frame.size.height *img.size.width / img.size.height;
    if (imageViewW > kMainWidth) {
        imageViewW = kMainWidth;
        imageViewH = kMainWidth * img.size.height / img.size.width;
    }else
    {
        imageViewH = self.imageView.frame.size.height;
    }
    float imageViewX = self.view.center.x - imageViewW/2;
    self.imageView.frame = CGRectMake(imageViewX, self.imageView.frame.origin.y, imageViewW, imageViewH);
}

#pragma mark - 比例截取图片
- (void)proportionCutImg
{
    CGFloat cutX = CGRectGetMinX(self.proportionCutView.frame) - CGRectGetMinX(self.imageView.frame);
    CGFloat cutY = CGRectGetMinY(self.proportionCutView.frame) - CGRectGetMinY(self.imageView.frame);
    //计算出缩放比例
    float proportion = self.imageView.image.size.width/self.imageView.frame.size.width;
    CGRect cutRect = CGRectMake(cutX * proportion, cutY * proportion, self.proportionCutView.frame.size.width * proportion, self.proportionCutView.frame.size.height * proportion);
    
    UIImage *newImage = [self imageFromImage:self.imageView.image inRect:cutRect];
    self.imageView.image = newImage;
    self.imageView.contentMode = UIViewContentModeCenter;
}

#pragma mark - 截取图片的一部分
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

#pragma mark - 根据封闭空间截图
- (void)areaCutImgWithDic:(NSDictionary *)dic
{
    float proportion = self.imageView.image.size.width/self.imageView.frame.size.width;
    
    NSArray *xArr = dic[@"xArr"];
    NSArray *yArr = dic[@"yArr"];
    CGFloat width = self.image.size.width;
    CGFloat height = self.image.size.height;
    //开始绘制图片
    UIGraphicsBeginImageContext(self.imageView.image.size);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(gc, [xArr[0] floatValue] * proportion, [yArr[0] floatValue] * proportion);
    for (int i = 1; i < xArr.count - 1; i ++) {
        CGContextAddLineToPoint(gc, [xArr[i] floatValue] * proportion, [yArr[i] floatValue] * proportion);
    }
    
    CGContextClip(gc);
    
    //坐标系转换
    //因为CGContextDrawImage会使用Quartz内的以左下角为(0,0)的坐标系
    CGContextTranslateCTM(gc, 0, height);
    CGContextScaleCTM(gc, 1, -1);
    CGContextDrawImage(gc, CGRectMake(0, 0, width, height), [self.image CGImage]);
    //结束绘画
    UIImage *destImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = destImg;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
