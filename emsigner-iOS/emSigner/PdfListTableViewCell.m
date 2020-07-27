//
//  PdfListTableViewCell.m
//  emSigner
//
//  Created by Administrator on 3/30/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "PdfListTableViewCell.h"

@implementation PdfListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _numberCount.layer.masksToBounds = YES;
    _numberCount.layer.cornerRadius = 4.0;
    //
    _expandCollapsImageView.layer.masksToBounds = YES;
    _expandCollapsImageView.layer.cornerRadius = 4.0;
    //
    _documentName.layer.masksToBounds = YES;
    _documentName.layer.cornerRadius = 4.0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
