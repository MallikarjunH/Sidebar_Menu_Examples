//
//  SignersCellTableViewCell.m
//  emSigner
//
//  Created by EMUDHRA on 29/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "SignersCellTableViewCell.h"
#import "SignersCollectionCell.h"

@implementation SignersCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.uploaddocument.layer.cornerRadius = 15;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
