//
//  LYProgressView.m
//  LYPhotoBrowserDemo
//
//  Created by Shangen Zhang on 17/3/19.
//  Copyright © 2017年 HHLY. All rights reserved.
//

#import "LYProgressView.h"

@interface LYProgressView ()

/** center point */
@property (nonatomic,assign) CGPoint centerP;

/** 外部大圆圈 */
@property (nonatomic,strong) UIBezierPath *outCirclePath;

/** 里面的进度圈 */
@property (nonatomic,strong) UIBezierPath *inCirclePath;

/** 背景底色 */
@property (nonatomic,strong) UIBezierPath *backgoundPath;

/** 开始角度 */
@property (nonatomic,assign) CGFloat startAngle;

/** 结束角度 */
@property (nonatomic,assign) CGFloat endAngle;

@end

@implementation LYProgressView
#pragma mark - class
+ (instancetype)progressViewWithWidth:(CGFloat)width {
    return [[self alloc] initWithFrame:CGRectMake(0, 0, width, width)];
}
+ (instancetype)progressView {
    return [self progressViewWithWidth:50.0];
}
#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}
#pragma mark - setter
- (void)setProgress:(CGFloat)progress {
    
    _progress = progress;
    
    [self setNeedsDisplay];
}
#pragma mark - drawing
- (void)drawRect:(CGRect)rect {
    
    // 背景颜色
    [[UIColor colorWithWhite:0.0 alpha:0.4] set];
    
    [self.backgoundPath fill];
    
    // 大圈
    [[UIColor whiteColor] set];
    [self.outCirclePath stroke];
    
    // 进度圈
    self.endAngle = _progress * M_PI * 2 + self.startAngle;
    
    self.inCirclePath = [UIBezierPath bezierPathWithArcCenter:self.centerP radius:self.width * 0.5 - 4 startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    
    [self.inCirclePath addLineToPoint:self.centerP];
    
    [[UIColor colorWithWhite:1 alpha:0.9] set];
    
    [self.inCirclePath fill];
}
#pragma mark - getter
- (CGPoint)centerP {
    
    if (!_centerP.x) {
        _centerP = CGPointMake(self.width * 0.5, self.height * 0.5);
    }
    return _centerP;
}

- (UIBezierPath *)backgoundPath {
    
    if (!_backgoundPath) {
        
        _backgoundPath = [UIBezierPath bezierPathWithArcCenter:self.centerP radius:self.width * 0.5 - 5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    }
    
    return _backgoundPath;
}
- (UIBezierPath *)outCirclePath {
    
    if (!_outCirclePath) {
        
        _outCirclePath = [UIBezierPath bezierPathWithArcCenter:self.centerP radius:self.width * 0.5 -2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        _outCirclePath.lineWidth = 2.0;
    }
    
    return _outCirclePath;
}

- (CGFloat)startAngle {
    return - M_PI_2;
}
- (CGFloat)width {
    return self.bounds.size.width;
}
- (CGFloat)height {
    return self.bounds.size.height;
}
@end
