//
//  SignatureImagesCell.m
//  emSigner
//
//  Created by Emudhra on 06/09/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import "SignatureImagesCell.h"

@implementation SignatureImagesCell
typedef void(^myCompletion)(BOOL);

- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
        _signatureImages = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        _addCheckImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 25, 25)];
      //  _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.signatureImages.frame.size.width - 20, 0, 30, 30)];
        _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];

        _deleteBtn.userInteractionEnabled = YES;

        [_deleteBtn setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_deleteBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
       // [_deleteBtn addTarget:self action:@selector(deleteSignatures:) forControlEvents:UIControlEventTouchUpInside];

      //  _addCheckImage.image = [UIImage imageNamed:@"completed-1x"];
        [self.signatureImages addSubview:_deleteBtn];
        [self.signatureImages addSubview:_addCheckImage];
        [self.contentView addSubview:_signatureImages];
    }
    return self;
}

-(void)deleteSignatures:(UIButton*)sender
{
    
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
    }
    return self;
}

@end
