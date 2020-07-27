//
//  AttachedMultiplePdfTableViewCell.h
//  emSigner
//
//  Created by Administrator on 7/4/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachedMultiplePdfTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UILabel *documentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelOfAttachment;
@property (weak, nonatomic) IBOutlet UIImageView *pdfImage;
@property (weak, nonatomic) IBOutlet UIButton *threedotsImageBtn;
@property (weak, nonatomic) IBOutlet UILabel *noOfPages;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;

@end
