//
//  DGSwitch.m
//  FamilyConnect
//
//  Created by Dov Goldberg on 3/28/11.
//  Copyright 2011 Ogonium. All rights reserved.
//  http://www.ogonium.com

#import "DGSwitch.h"
#import <QuartzCore/QuartzCore.h>

#define SLIDER_X_ON  0
#define SLIDER_X_OFF  -56
#define SLIDER_TAG  430

@implementation DGSwitch

@synthesize on = _on;

- (id)initWithFrame:(CGRect)frame
{
    CGRect cframe = CGRectMake(frame.origin.x, frame.origin.y, 95.0f, 27.0f);
    self = [super initWithFrame:cframe];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        CGRect cframe = CGRectMake(self.frame.origin.x, self.frame.origin.y, 95.0f, 27.0f);
        self.layer.cornerRadius = 4;
        self.frame = cframe;
        [self setNeedsDisplay];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self=[super initWithCoder: aDecoder];
    if(self) {
        self.clipsToBounds = YES;
        CGRect cframe = CGRectMake(self.frame.origin.x, self.frame.origin.y, 95.0f, 27.0f);
        self.layer.cornerRadius = 4;
        self.frame = cframe;
        [self setNeedsDisplay];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIImageView *slider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider.png"]];
    CGRect sliderFrame = slider.frame;
    if (_on) {
        sliderFrame.origin.x = SLIDER_X_ON;
    } else {
        sliderFrame.origin.x = SLIDER_X_OFF;
    }
    sliderFrame.origin.y = 0;
    slider.tag = SLIDER_TAG;
    slider.frame = sliderFrame;
    [self addSubview:slider];
    [slider release];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    tapPt = [[touches anyObject] locationInView: self];
    xPos = tapPt.x + SLIDER_X_OFF;
    
    UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    if (xPos > SLIDER_X_ON) {
        xPos = SLIDER_X_ON;
    }
    if (xPos < SLIDER_X_OFF) {
        xPos = SLIDER_X_OFF;
    }
    sliderFrame.origin.x = xPos;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint tappedPt = [[touches anyObject] locationInView: self];
    xPos = tappedPt.x + SLIDER_X_OFF;
    
    UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    if (xPos > SLIDER_X_ON) {
        xPos = SLIDER_X_ON;
    }
    if (xPos < SLIDER_X_OFF) {
        xPos = SLIDER_X_OFF;
    }
    sliderFrame.origin.x = xPos;

    slider.frame = sliderFrame;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    BOOL value;
    if (sliderFrame.origin.x < (SLIDER_X_OFF / 2)) {
        sliderFrame.origin.x = SLIDER_X_OFF;
        value = NO;
    } else {
        sliderFrame.origin.x = SLIDER_X_ON;
        value = YES;
    }
    if (xPos < (SLIDER_X_OFF / 2)) {
        sliderFrame.origin.x = SLIDER_X_OFF;
        value = NO;
    } else {
        sliderFrame.origin.x = SLIDER_X_ON;
        value = YES;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];	
    slider.frame = sliderFrame;
    [UIView commitAnimations];
    
    if (value != _on) {
        _on = value;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    BOOL value;
    if (sliderFrame.origin.x < (SLIDER_X_OFF / 2)) {
        sliderFrame.origin.x = SLIDER_X_OFF;
        value = NO;
    } else {
        sliderFrame.origin.x = SLIDER_X_ON;
        value = YES;
    }
    if (xPos < (SLIDER_X_OFF / 2)) {
        sliderFrame.origin.x = SLIDER_X_OFF;
        value = NO;
    } else {
        sliderFrame.origin.x = SLIDER_X_ON;
        value = YES;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];	
    slider.frame = sliderFrame;
    [UIView commitAnimations];
    
    if (value != _on) {
        _on = value;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setOn:(BOOL)on
{
    UIImageView *slider = (UIImageView *)[self viewWithTag:SLIDER_TAG];
    CGRect sliderFrame = slider.frame;
    _on = on;
    if (_on) {
        sliderFrame.origin.x = SLIDER_X_ON;
    } else {
        sliderFrame.origin.x = SLIDER_X_OFF;
    }
    slider.frame = sliderFrame;
}

- (void)dealloc
{
    [super dealloc];
}

@end
