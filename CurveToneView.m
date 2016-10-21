//
//  CurveToneView.m
//  Demo-1
//
//  Created by admin on 16/10/21.
//  Copyright © 2016年 admin. All rights reserved.
//

typedef enum{
    HeadType = 200,
    MidType,
}BesselType;

#define ArbitrarilyA (float)7.0/40

#import "CurveToneView.h"

@interface CurveToneView ()
{
    //当前区域
    int _nowArea;
}

@property (nonatomic, assign) BesselType besselType;
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint secondPoint;
@property (nonatomic, assign) CGPoint thirdPoint;
@property (nonatomic, assign) CGPoint fourthPoint;
@property (nonatomic, assign) CGPoint fifthPoint;

/** 存放百分比label数组*/
@property (nonatomic, strong) NSMutableArray *labelArr;

@end

@implementation CurveToneView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.layer.borderColor = [UIColor whiteColor].CGColor;
        //self.layer.borderWidth = 1.0f;
        self.backgroundColor = [UIColor clearColor];
        
        float width = frame.size.width;
        float height = frame.size.height;
        self.firstPoint = CGPointMake(0, height);
        self.secondPoint = CGPointMake(width * 6 / 25, height * 19 / 25);
        self.thirdPoint = CGPointMake(width/2, height/2);
        self.fourthPoint = CGPointMake(width * 19 / 25, height * 6 / 25);
        self.fifthPoint = CGPointMake(width, 0);
        [self prepareUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)prepareUI
{
    self.labelArr = [NSMutableArray array];
    NSArray *textArr = @[@"Blacks",@"Shadouws",@"Midtones",@"Highlights",@"Whites"];
    float width = self.frame.size.width/5;
    float height = 10;
    float y = self.frame.size.height - height + 5;
    for (NSInteger i = 0; i < 5; i ++) {
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(width * i, y, width, height);
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label.numberOfLines = 0;
        label.text = textArr[i];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:8];
    }
    
    y = y - 10;
    NSArray *array = @[@"0%",@"25%",@"50%",@"75%",@"100%"];
    for (NSInteger i = 0; i < 5; i ++) {
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(width * i, y, width, height);
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label.numberOfLines = 0;
        label.text = array[i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:8];
        [self.labelArr addObject:label];
    }
    
}


#pragma mark - 绘图
- (void)drawRect:(CGRect)rect
{
    //根据关键点获取控制点
    NSDictionary *dic1 = [self getTwoControlWithPoint1:self.firstPoint Point2:self.secondPoint point3:self.thirdPoint point4:CGPointZero BesselType:HeadType];
    CGPoint controlA1 = CGPointMake([dic1[@"controlAx"] floatValue], [dic1[@"controlAy"] floatValue]);
    CGPoint controlB1 = CGPointMake([dic1[@"controlBx"] floatValue], [dic1[@"controlBy"] floatValue]);
    NSDictionary *dic2 = [self getTwoControlWithPoint1:self.firstPoint Point2:self.secondPoint point3:self.thirdPoint point4:self.fourthPoint BesselType:MidType];
    CGPoint controlA2 = CGPointMake([dic2[@"controlAx"] floatValue], [dic2[@"controlAy"] floatValue]);
    CGPoint controlB2 = CGPointMake([dic2[@"controlBx"] floatValue], [dic2[@"controlBy"] floatValue]);
    
    NSDictionary *dic3 = [self getTwoControlWithPoint1:self.secondPoint Point2:self.thirdPoint point3:self.fourthPoint point4:self.fifthPoint BesselType:MidType];
    CGPoint controlA3 = CGPointMake([dic3[@"controlAx"] floatValue], [dic3[@"controlAy"] floatValue]);
    CGPoint controlB3 = CGPointMake([dic3[@"controlBx"] floatValue], [dic3[@"controlBy"] floatValue]);
    
    NSDictionary *dic4 = [self getTwoControlWithPoint1:self.fifthPoint Point2:self.fourthPoint point3:self.thirdPoint point4:CGPointZero BesselType:HeadType];
    CGPoint controlA4 = CGPointMake([dic4[@"controlAx"] floatValue], [dic4[@"controlAy"] floatValue]);
    CGPoint controlB4 = CGPointMake([dic4[@"controlBx"] floatValue], [dic4[@"controlBy"] floatValue]);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, self.firstPoint.x, self.firstPoint.y);
    CGContextAddCurveToPoint(ctx, controlA1.x, controlA1.y, controlB1.x, controlB1.y, self.secondPoint.x, self.secondPoint.y);
    CGContextAddCurveToPoint(ctx, controlA2.x, controlA2.y, controlB2.x, controlB2.y, self.thirdPoint.x, self.thirdPoint.y);
    CGContextAddCurveToPoint(ctx, controlA3.x, controlA3.y, controlB3.x, controlB3.y, self.fourthPoint.x, self.fourthPoint.y);
    [[UIColor whiteColor] set];
    CGContextStrokePath(ctx);
    CGContextMoveToPoint(ctx, self.fifthPoint.x, self.fifthPoint.y);
    CGContextAddCurveToPoint(ctx, controlA4.x, controlA4.y, controlB4.x, controlB4.y, self.fourthPoint.x, self.fourthPoint.y);
    [[UIColor whiteColor] set];
    CGContextStrokePath(ctx);
    
    CGContextMoveToPoint(ctx, 0, self.frame.size.height);
    CGContextAddLineToPoint(ctx, self.frame.size.width, 0);
    [[UIColor whiteColor]set];
    CGContextSetLineWidth(ctx, 0.5f);
    CGContextStrokePath(ctx);
    
}


#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //确定区域
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    _nowArea = location.x / (self.frame.size.width/5);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint star = [touch previousLocationInView:self];
    CGPoint end = [touch locationInView:self];
    CGPoint change = CGPointMake((end.x - star.x)/3, (end.y - star.y)/3);
    CGPoint temp;
    float newY;
    //修改关键点的位置并限制
    switch (_nowArea) {
        case 0:{
            temp = self.firstPoint;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.firstPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.firstPoint.y;
        }
            break;
        case 1:{
            temp = self.secondPoint;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.secondPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.secondPoint.y;
        }
            break;
        case 2:
        {
            temp = self.thirdPoint;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.thirdPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.thirdPoint.y;
        }
            break;
        case 3:
        {
            temp = self.fourthPoint;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.fourthPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.fourthPoint.y;
        }
            break;
        case 4:
        {
            temp = self.fifthPoint;
            if (temp.y + change.y > self.frame.size.height || temp.y + change.y < 0) {
                break;
            }
            self.fifthPoint = CGPointMake(temp.x, temp.y + change.y);
            newY = self.fifthPoint.y;
        }
            break;
        default:
        break;
    }
    [self setNeedsDisplay];
    
    [self modifyNumberByNewY:newY];
}

#pragma mark - 修改百分比数值
- (void)modifyNumberByNewY:(float)y
{
    UILabel *label = self.labelArr[_nowArea];
    int new =  (self.frame.size.height - y) * 100 / self.frame.size.height;
    NSLog(@"new:%d",new);
    label.text = [NSString stringWithFormat:@"%d%%",new];
}

#pragma mark - 计算中间贝塞尔曲线的控制点
- (NSDictionary *)getTwoControlWithPoint1:(CGPoint)point1
                                   Point2:(CGPoint)point2
                                   point3:(CGPoint)point3
                                   point4:(CGPoint)point4
                               BesselType:(BesselType)besselType
{
    CGPoint pointA;
    CGPoint pointB;
    if (besselType == HeadType) {
        pointA = CGPointMake(point1.x + ArbitrarilyA *(point2.x - point1.x), point1.y + ArbitrarilyA * (point2.y - point1.y));
        pointB = CGPointMake(point2.x - ArbitrarilyA * (point3.x - point1.x), point2.y - ArbitrarilyA * (point3.y - point1.y));
    }else
    {
        pointA = CGPointMake(point2.x + ArbitrarilyA * (point3.x - point1.x), point2.y + ArbitrarilyA * (point3.y - point1.y));
        pointB = CGPointMake(point3.x - ArbitrarilyA * (point4.x - point2.x), point3.y - ArbitrarilyA * (point4.y - point2.y));
    }
    
    
    if (pointB.y >= self.frame.size.height) {
        pointB = CGPointMake(pointB.x, self.frame.size.height);
    }
    if (pointB.y <= 0) {
        pointB = CGPointMake(pointB.x, 0);
    }
    
    if (pointA.y >= self.frame.size.height) {
        pointA = CGPointMake(pointA.x, self.frame.size.height);
    }
    if (pointA.y <= 0) {
        pointA = CGPointMake(pointA.x, 0);
    }
    return @{@"controlAx":[NSNumber numberWithFloat:pointA.x],@"controlAy":[NSNumber numberWithFloat:pointA.y],@"controlBx":[NSNumber numberWithFloat:pointB.x],@"controlBy":[NSNumber numberWithFloat:pointB.y]};
}



@end
