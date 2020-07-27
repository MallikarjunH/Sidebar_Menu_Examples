//
//  PendingVCTableViewCell.h
//  emSigner
//
//  Created by Administrator on 12/1/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PendingListVC.h"
static const CGFloat kDefaultAccordionHeaderViewHeight = 44.0;
static NSString *const kAccordionHeaderViewReuseIdentifier = @"AccordionHeaderViewReuseIdentifier";
@interface PendingVCTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UIImageView *pdfImage;
@property (weak, nonatomic) IBOutlet UILabel *documentName;
@property (weak, nonatomic) IBOutlet UILabel *ownerName;
@property (weak, nonatomic) IBOutlet UILabel *dateLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *docInfoBtn;
//@property (weak, nonatomic) IBOutlet UILabel *numberOfAttachmentsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attachmentsImage;
//@property (weak, nonatomic) IBOutlet UIImageView *statusImage;


- (IBAction)docInfoBtn:(id)sender;
@end