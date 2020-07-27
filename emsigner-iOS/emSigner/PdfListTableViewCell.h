//
//  PdfListTableViewCell.h
//  emSigner
//
//  Created by Administrator on 3/30/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PdfListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numberCount;
@property (weak, nonatomic) IBOutlet UILabel *documentName;
@property (weak, nonatomic) IBOutlet UILabel *signatory;
@property (weak, nonatomic) IBOutlet UIImageView *expandCollapsImageView;
@property (weak, nonatomic) IBOutlet UIView *customView;

@end
