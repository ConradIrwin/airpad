//
//  AirbrakeErrorCell.m
//  Airpad
//
//  Created by Conrad Irwin on 12/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeErrorCell.h"

@implementation AirbrakeErrorCell
@synthesize airbrake;

- (void)setAirbrake:(AirbrakeError *)value {
    if (airbrake) {
        [airbrake removeObserver:self forKeyPath:@"isResolved"];
        [airbrake removeObserver:self forKeyPath:@"errorMessage"];
    }
    
    [self willChangeValueForKey:@"airbrake"];
    airbrake = value;
    [self didChangeValueForKey:@"airbrake"];
    if (airbrake) {
        [airbrake addObserver:self forKeyPath:@"isResolved" options:NSKeyValueObservingOptionInitial context:@"isResolved"];
        [airbrake addObserver:self forKeyPath:@"errorMessage" options:NSKeyValueObservingOptionInitial context:@"errorMessage"];
    } else {
        [self.textLabel setText: @"<unattached>"];
        [self.imageView setImage: nil];
    }
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
 
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"isResolved"){
        if ([airbrake.isResolved boolValue]) {
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            self.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (context == @"errorMessage") {
        [self.textLabel setText: airbrake.errorMessage];
    }
}
- (void)dealloc{
    [self setAirbrake:nil];
}

@end
