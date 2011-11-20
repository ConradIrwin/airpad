//
//  AirbrakeDateView.m
//  Airpad
//
//  Created by Conrad Irwin on 19/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeDateView.h"
#import "NSDate+DateISOParser.h"

#define DAYS_TO_SHOW 35

@implementation AirbrakeDateView
@synthesize startDate;
@synthesize endDate;
@synthesize count;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (bool) isWeekend:(NSDate*)date
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *day = [cal components:NSWeekdayCalendarUnit fromDate: date];
    return ([day weekday] == 1 || [day weekday] == 7);
}

- (UIFont*)font
{
    return [UIFont systemFontOfSize:12];
}

- (NSString*) formatDate:(NSDate*)date 
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];   
    [fmt setDateFormat: @"d MMM HH:mm"];
    return[fmt stringFromDate:date]; 
}
- (NSString*) getYear:(NSDate*) date
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];   
    [fmt setDateFormat: @"Y"];
    return [fmt stringFromDate:date];    
}

- (CGFloat) dayOffset
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *day = [cal components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate: [NSDate date]];
    return (((day.hour * 60.0) + day.minute) * 60.0 + day.second) / 86400.0;
}

- (NSDate*) startOfLine
{
    return [NSDate dateWithTimeInterval: 0 - (DAYS_TO_SHOW * 86400.0) sinceDate:[NSDate date]];
}

- (bool) date:(NSDate*)date isSameTime:(NSDate*)other
{
    return [[self formatDate:date] isEqualToString: [self formatDate: other]];
}

- (bool) date:(NSDate*)date isSameDate:(NSDate*)other
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];   
    [fmt setDateFormat: @"d mmm Y"];
    return [[fmt stringFromDate:date] isEqualToString: [fmt stringFromDate:other]];
}

- (NSString*) countFormatted
{
    if (self.count == 1) {
        return @"(once only)";
    } else if (self.count == 2) {
        return @"(twice only)";
    } else {
        return [NSString stringWithFormat:@"(%i times)", count];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef con = UIGraphicsGetCurrentContext();
    NSDate* startOfLine = [self startOfLine];
    CGFloat mid = [self frame].size.height * 2.5 / 4.0;
    CGFloat prehistoryDistance = 16.0;
    CGFloat padding = 85.0; // Enough space for a dashWidth and date to appear on the right-hand-side of the line.
    CGFloat day = ([self frame].size.width - 2.0 * padding - prehistoryDistance) / (DAYS_TO_SHOW);
    CGFloat offset = padding + prehistoryDistance + day * (1.0 - [self dayOffset]);
    CGFloat dashTop = [self frame].size.height / 4.0;
    CGFloat dashWidth = day / 3.0;
    CGFloat weekBottom = [self frame].size.height * 6.0 / 8.0;
    CGFloat weekendBottom = [self frame].size.height;
    CGFloat bottom;
    
    // Draw: the horizontal line
    CGContextMoveToPoint(con, padding + prehistoryDistance, mid);
    CGContextAddLineToPoint(con, [self frame].size.width - padding, mid);

    // Draw: the per-day ticks
    for(NSInteger i = 0; i < DAYS_TO_SHOW; i++) {
        NSDate *date = [NSDate dateWithTimeInterval: ((i + 1) * 86400.0) sinceDate:startOfLine];
        if ([self isWeekend: date]) {
            bottom = weekendBottom;
        } else {
            bottom = weekBottom;
        }
        CGContextMoveToPoint(con, i * day + offset, mid);
        CGContextAddLineToPoint(con, i * day + offset, bottom);
    }
    
    CGContextSetLineWidth(con, 0.5);
    CGContextStrokePath(con);
    
    // Draw: the dotted prehistory line at the front
    CGContextMoveToPoint(con, padding, mid);
    CGContextAddLineToPoint(con, padding + prehistoryDistance, mid);
    CGFloat dashes[] = {2.0, 2.0};
    CGContextSetLineDash(con, 0.0, dashes, 2);
    CGContextSetLineWidth(con, 0.5);
    CGContextStrokePath(con);
    CGContextSetLineDash(con, 0.0, NULL, 0);
    
    if (!startDate || !endDate) {
        return;
    }
    
    // Draw: The upwards dash for start, with label
    CGFloat startDistance = MAX(padding, padding + prehistoryDistance + day * ([startDate timeIntervalSinceDate:startOfLine] / 86400.0));
    NSString* startFormatted = [self formatDate: startDate];
    CGSize startSize = [startFormatted sizeWithFont:[self font]];
    
    CGContextMoveToPoint(con, startDistance, mid);
    CGContextAddLineToPoint(con, startDistance, dashTop);
    CGContextAddLineToPoint(con, startDistance - dashWidth, dashTop);
    [startFormatted drawInRect:CGRectMake(startDistance - dashWidth - startSize.width - 5.0, 0.0, startSize.width, startSize.height) withFont:[self font]];
    
    if (startDistance <= padding + prehistoryDistance) {
        NSString *year = [self getYear: endDate];
        CGSize yearSize = [year sizeWithFont:[self font]];
        [year drawInRect: CGRectMake(startDistance - dashWidth - 5.0 - (startSize.width + yearSize.width) / 2.0, startSize.height, yearSize.width, yearSize.height) withFont:[self font]];
    }
    
    // Draw: the upwards dash for end, with label
    CGFloat endDistance = MAX(padding, padding + prehistoryDistance + day * ([endDate timeIntervalSinceDate:startOfLine] / 86400.0));
    NSString *endFormatted;

    if ([self date:startDate isSameTime:endDate]) {
        endFormatted = [self countFormatted];
    } else {
        endFormatted = [self formatDate: endDate];
    } 
    CGSize endSize = [endFormatted sizeWithFont:[self font]];
    CGContextMoveToPoint(con, endDistance, mid);
    CGContextAddLineToPoint(con, endDistance, dashTop);
    CGContextAddLineToPoint(con, endDistance + dashWidth, dashTop);
    [endFormatted drawInRect:CGRectMake(endDistance + dashWidth + 5.0, 0.0, endSize.width, endSize.height) withFont:[self font]];
    

    // Draw: the occurance rate.
    if ([self count] > 1 && ![self date:startDate isSameTime:endDate]) {
        NSString *rateString;
        if ([self count] == 2) {
            rateString = @"(twice only)";
        } else if ([self date:startDate isSameDate: endDate]) {
            rateString = [NSString stringWithFormat: @"(%i times)", count];
        } else {
            rateString = [NSString stringWithFormat: @"(%i times, %0.2f/day)", count, count * 86400.0 / ([endDate timeIntervalSinceDate:startDate]) ];
        }
        
        CGSize rateSize = [rateString sizeWithFont: [self font]];

        CGFloat midSpace = endDistance - startDistance;
        CGFloat leftSpace = startDistance - startSize.width;
        CGFloat rightSpace = self.frame.size.width - endDistance - endSize.width;  
        CGFloat ratePosition;
        
        // Position the rate label, either 
        // 1. In the middle if it fits (for awesomeness)
        // 2. To the left or right, whichever there's more space (if it fits)
        // 3. In¡ the middle if it doesn't fit anywhere, for symetrical disaster.
        if (rateSize.width + 10.0 < midSpace) {
            ratePosition = startDistance + (midSpace - rateSize.width) / 2.0;
        } else if (rateSize.width + 10.0 < leftSpace && leftSpace >= rightSpace) {
            ratePosition = (leftSpace - rateSize.width) / 2.0;
        } else if (rateSize.width + 10.0 < rightSpace) {
            ratePosition = endDistance + (rightSpace - rateSize.width) / 2.0;
        } else {
            ratePosition = startDistance + (midSpace - rateSize.width) / 2.0;
        }
        
        [rateString drawInRect:CGRectMake(ratePosition, 0.0, rateSize.width, rateSize.height) withFont:[self font]];
    }
    
    CGContextSetLineWidth(con, 0.5);
    CGContextStrokePath(con);
}

@end
