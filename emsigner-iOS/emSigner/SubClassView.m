//
//  SubClassView.m
//  CustomView
//
//  Created by Paul Solt on 4/28/14.
//  Copyright (c) 2014 Paul Solt. All rights reserved.
//

#import "SubClassView.h"

@interface SubClassView()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *onSwitch;

@end

@implementation SubClassView

// Note: You can customize the behavior after calling the super method

// Called when loading programatically
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        // Call a common method to setup gesture and state of UIView
    }
    return self;
}

// Called when loading from embedded .xib UIView
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Call a common method to setup gesture and state of UIView
    }
    return self;
}



@end
