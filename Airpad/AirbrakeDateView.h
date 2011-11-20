//
//  AirbrakeDateView.h
//  Airpad
//
//  Created by Conrad Irwin on 19/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AirbrakeDateView : UIView
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) NSInteger count;

@end
