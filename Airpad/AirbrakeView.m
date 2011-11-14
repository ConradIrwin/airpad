//
//  AirbrakeView.m
//  Airpad
//
//  Created by Conrad Irwin on 13/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeView.h"

@implementation AirbrakeView
@synthesize isAnimating;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (isAnimating) {
        return;
    }
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(con, 0.0, 192.5);
    CGContextAddLineToPoint(con, [self frame].size.width, 192.5);
    CGContextSetLineWidth(con, 1.0);
    CGContextStrokePath(con);
}
@end
