//
//  SignatureImagesCell.h
//  emSigner
//
//  Created by Emudhra on 06/09/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatureImagesCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *signatureImages;
@property (strong, nonatomic) IBOutlet UIImageView *addCheckImage;

@property (strong,nonatomic) IBOutlet UIButton *deleteBtn;

@end