//
//  MultiplePdfTableViewCell.h
//  emSigner
//
//  Created by Administrator on 6/1/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiplePdfTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *documentNameLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *documentImageView;
@property (weak, nonatomic) IBOutlet UIButton *docInfoBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *signatoryScrollView;
@property (weak, nonatomic) IBOutlet UILabel *signatoryLabel;
- (IBAction)docInfoBtn:(id)sender;

@end
