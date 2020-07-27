//
//  CustomDocumentLogTableViewCell.m
//  emSigner
//
//  Created by Administrator on 8/17/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "CustomDocumentLogTableViewCell.h"

@implementation CustomDocumentLogTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
//    [self.customView setAlpha:1];
//    self.customView.layer.masksToBounds = NO;
//    self.customView.layer.cornerRadius = 5; // if you like rounded corners
//    self.customView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f); //%%% this shadow will hang slightly down and to the right
//    self.customView.layer.shadowRadius = 0.5; //%%% I prefer thinner, subtler shadows, but you can play with this
//    self.customView.layer.shadowOpacity = 0.005;
//    //%%% same thing with this, subtle is better for me
//    
//    //%%% This is a little hard to explain, but basically, it lowers the performance required to build shadows.  If you don't use this, it will lag
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.customView.bounds];
//    self.customView.layer.shadowPath = path.CGPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
