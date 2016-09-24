//
//  WDDAnimationButton.m
//  WDDAnimationButtonDemo
//
//  Created by WD on 16/9/24.
//  Copyright © 2016年 WD. All rights reserved.
//

#import "WDDAnimationButton.h"

@interface WDDAnimationButton ()

/**
 *  小圆半径
 */
@property (nonatomic, assign) CGFloat  oriSmallRadius;
/**
 *  小圆
 */
@property (nonatomic, strong) UIView  * smallCircleView;
/**
 *  用于描述不规则矩形的图层
 */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation WDDAnimationButton
#pragma mark - lazyload
- (UIView *)smallCircleView
{
    if (_smallCircleView == nil) {
        
        _smallCircleView = [[UIView alloc] init];
        
        _smallCircleView.backgroundColor = self.backgroundColor;
        
        // 小圆添加按钮的父控件上
        [self.superview insertSubview:_smallCircleView belowSubview:self];
        
    }
    return _smallCircleView;
}

- (CAShapeLayer *)shapeLayer
{
    if (_shapeLayer == nil) {
        
        // 展示不规则矩形，通过不规则矩形路径生成一个图层
        CAShapeLayer *layer = [CAShapeLayer layer];
        
        _shapeLayer = layer;
        
        //设置填充颜色与自己的背景色一致
        layer.fillColor = self.backgroundColor.CGColor;
        
        [self.superview.layer insertSublayer:layer below:self.layer];
    }
    return _shapeLayer;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUp];
    }
    return self;
}
- (void)awakeFromNib
{
    
    [self setUp];
}


-(void)setUp
{
    CGFloat  w = self.bounds.size.width;
    
    _oriSmallRadius = w / 2;//记录小圆最初半径
    
    self.layer.cornerRadius = w / 2;
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    
    UIPanGestureRecognizer * pan =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    
    [self addGestureRecognizer:pan];
    
    // 设置小圆位置和尺寸
    self.smallCircleView.center = self.center;
    self.smallCircleView.bounds = self.bounds;
    self.smallCircleView.layer.cornerRadius = w / 2;
    
}


#define kMaxDistance 80

-(void)pan:(UIPanGestureRecognizer * )pan
{
    
    //获取手指触摸到的点，进而获取手指偏移量
    CGPoint  transP = [pan translationInView:self];
    
    CGPoint center = self.center;
    center.x += transP.x;
    center.y += transP.y;
    
    self.center = center;
    
    //复位
    [pan setTranslation:CGPointZero inView:self];
    
    //添加小圆，根据两个圆心点距离改变小圆的半径
   CGFloat d = [self circleCenterDistanceWithBigCircleCenter:self.center smallCircleCenter:self.smallCircleView.center];
    
    CGFloat smallRadius = _oriSmallRadius - d / 10;
    
    // 设置小圆的尺寸
    self.smallCircleView.bounds = CGRectMake(0, 0, smallRadius * 2, smallRadius * 2);
    
    self.smallCircleView.layer.cornerRadius = smallRadius;
    
    //描述不规则矩形
    if (d  > kMaxDistance) {
        self.smallCircleView.hidden = YES;
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
    } else if (d > 0 && self.smallCircleView.hidden == NO)
    {
        self.shapeLayer.path = [self pathWithBigCirCleView:self smallCirCleView:self.smallCircleView].CGPath;
    }
    
    
    //手指抬起的时候还原
    
    if (pan.state == UIGestureRecognizerStateEnded) {
    
        //如果超出最大范围添加gif动画
        if (d > kMaxDistance) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            NSMutableArray *arrM = [NSMutableArray array];
            for (int i = 1; i < 9; i++) {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]];
                [arrM addObject:image];
            }
            imageView.animationImages = arrM;
            
            imageView.animationRepeatCount = 1;
            
            imageView.animationDuration = 0.5;
            
            [imageView startAnimating];
            
            [self addSubview:imageView];
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });

        }else{ //如果没有超出范围 还原大圆位置以及移除不规则矩形
            
            // 移除不规则矩形
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            
            // 还原位置
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                // 设置大圆中心点位置
                self.center = self.smallCircleView.center;
                
            } completion:^(BOOL finished) {
                // 显示小圆
                self.smallCircleView.hidden = NO;
            }];
            
        }
    }
}

#pragma mark - 私有方法
// 计算两个圆心之间的距离
- (CGFloat)circleCenterDistanceWithBigCircleCenter:(CGPoint)bigCircleCenter smallCircleCenter:(CGPoint)smallCircleCenter
{
    CGFloat offsetX = bigCircleCenter.x - smallCircleCenter.x;
    CGFloat offsetY = bigCircleCenter.y - smallCircleCenter.y;
    
    return  sqrt(offsetX * offsetX + offsetY * offsetY);
}

// 描述两圆之间一条矩形路径,主要涉及几何学
- (UIBezierPath *)pathWithBigCirCleView:(UIView *)bigCirCleView  smallCirCleView:(UIView *)smallCirCleView
{
    CGPoint bigCenter = bigCirCleView.center;
    CGFloat x2 = bigCenter.x;
    CGFloat y2 = bigCenter.y;
    CGFloat r2 = bigCirCleView.bounds.size.width / 2;
    
    CGPoint smallCenter = smallCirCleView.center;
    CGFloat x1 = smallCenter.x;
    CGFloat y1 = smallCenter.y;
    CGFloat r1 = smallCirCleView.bounds.size.width / 2;
    
    // 获取圆心距离
    CGFloat d = [self circleCenterDistanceWithBigCircleCenter:bigCenter smallCircleCenter:smallCenter];
    
    CGFloat sinθ = (x2 - x1) / d;
    
    CGFloat cosθ = (y2 - y1) / d;
    
    // 坐标系基于父控件
    CGPoint pointA = CGPointMake(x1 - r1 * cosθ , y1 + r1 * sinθ);
    CGPoint pointB = CGPointMake(x1 + r1 * cosθ , y1 - r1 * sinθ);
    CGPoint pointC = CGPointMake(x2 + r2 * cosθ , y2 - r2 * sinθ);
    CGPoint pointD = CGPointMake(x2 - r2 * cosθ , y2 + r2 * sinθ);
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * sinθ , pointA.y + d / 2 * cosθ);
    CGPoint pointP =  CGPointMake(pointB.x + d / 2 * sinθ , pointB.y + d / 2 * cosθ);
    
    //路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 起点A
    [path moveToPoint:pointA];
    
    // 绘制AB直线
    [path addLineToPoint:pointB];
    
    // 绘制BC曲线
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    
    // 绘制CD直线
    [path addLineToPoint:pointD];
    
    // 绘制DA曲线
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    
    return path;
}

@end
