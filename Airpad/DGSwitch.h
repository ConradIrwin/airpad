//
//  DGSwitch.h
//  FamilyConnect
//
//  Created by Dov Goldberg on 3/28/11.
//  Copyright 2011 Ogonium. All rights reserved.
//  http://www.ogonium.com

#import <UIKit/UIKit.h>


@interface DGSwitch : UIControl {
    CGPoint tapPt;
    int     xPos;
@private
    BOOL    _on;
}

@property (nonatomic, assign) BOOL on;

@end
