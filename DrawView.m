//
//  DrawView.m
//  Demo-1
//
//  Created by admin on 16/10/13.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _pointXrr = [NSMutableArray array];
        _pointYArr = [NSMutableArray array];
        _segmentArr = [NSMutableArray array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

    if (self.pointXrr.count == 0) {
        return;
    }
    //1 取得和当前视图相关联的图形上下文(因为图形上下文决定绘制的输出目标)
    //如果是在drawRect方法中调用UIGraphicsGetCurrentContext方法获取出来的就是Layer的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();//不需要*
    
    //2 绘图（绘制直线），保存绘图信息
    CGContextMoveToPoint(ctx, [self.pointXrr[0] floatValue], [self.pointYArr[0] floatValue]);
    for (int i = 1; i < self.pointXrr.count - 1; i ++) {
        CGContextAddLineToPoint(ctx, [self.pointXrr[i] floatValue], [self.pointYArr[i] floatValue]);
    }
    
    //设置绘图的状态
    //设置线条的颜色为蓝色
    CGContextSetRGBStrokeColor(ctx, 0, 1.0, 0, 1.0);
    
    //3 渲染（绘制出一条空心的线）
    CGContextStrokePath(ctx);
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch preciseLocationInView:self];
    CGPoint previous = [touch precisePreviousLocationInView:self];
    [_pointXrr addObject:[NSNumber numberWithFloat:previous.x]];
    [_pointYArr addObject:[NSNumber numberWithFloat:previous.y]];
    
    NSArray *array = @[[NSValue valueWithCGPoint:previous],[NSValue valueWithCGPoint:location]];
    [_segmentArr addObject:array];
    [self setNeedsDisplay];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self clear];
}


#pragma mark - 获取封闭空间的坐标数组
- (NSDictionary *)cutImage
{
    BOOL flg = NO;
    NSMutableArray *closeXArr = [NSMutableArray array];
    NSMutableArray *closeYArr = [NSMutableArray array];
    for (int i = 0; i < _pointXrr.count; i ++) {
        for (int j = i + 2; j < _pointXrr.count - 1; j ++) {
            NSArray *array1 = _segmentArr[i];
            NSArray *array2 = _segmentArr[j];
            CGPoint isIntersect = [self isIntersectWithPoint1:[array1[0] CGPointValue] Point2:[array1[1] CGPointValue] Point3:[array2[0] CGPointValue] Point4:[array2[1] CGPointValue]];
            if (isIntersect.x != 0 || isIntersect.y != 0) {
                [closeXArr addObject:[NSNumber numberWithFloat:isIntersect.x]];
                [closeYArr addObject:[NSNumber numberWithFloat:isIntersect.y]];
                
                flg = YES;
                NSArray *xArr = [_pointXrr subarrayWithRange:NSMakeRange(i, j - i + 1)];
                NSArray *yArr = [_pointYArr subarrayWithRange:NSMakeRange(i, j - i + 1)];
                [closeXArr addObjectsFromArray:xArr];
                [closeYArr addObjectsFromArray:yArr];
                break;
            }
        }
        if (flg == YES) {
            break;
        }
    }
    NSLog(@"flg:%d",flg);
    if (flg == YES) {
        return @{@"xArr":closeXArr,@"yArr":closeYArr};
    }else
    {
        return nil;
    }
}


#pragma mark - 判断两条线段是否相交
- (CGPoint)isIntersectWithPoint1:(CGPoint)point1
                       Point2:(CGPoint)point2
                       Point3:(CGPoint)point3
                       Point4:(CGPoint)point4
{
    //先判断是否平行
    float a1 = (point1.y - point2.y)/(point1.x - point2.x);
    float a2 = (point3.y - point4.y)/(point3.x - point4.x);
    float b1 = point1.y - a1 * point1.x;
    float b2 = point3.y - a2 * point3.x;
    if (a1 * b2 == a2 * b1) {
        return CGPointZero;
    }else
    {
        float x = (b2 - b1)/(a1 - a2);
        float point12min = point1.x >= point2.x ? point2.x : point1.x;
        float point12max = point1.x <= point2.x ? point2.x : point1.x;
        float point34min = point3.x >= point4.x ? point4.x : point3.x;
        float point34max = point3.x <= point4.x ? point4.x : point3.x;
        
        float xmin = point12min >= point34min ? point12min : point34min;
        float xmax = point12max >= point34max ? point34max : point12max;
        if (x >= xmin && x <= xmax) {
            return CGPointMake(x, a1 * x + b1);
        }else
        {
            return CGPointZero;
        }
    }
}

#pragma mark - 清空操作
- (void)clear
{
    [self.pointXrr removeAllObjects];
    [self.pointYArr removeAllObjects];
    [self.segmentArr removeAllObjects];
}


@end
