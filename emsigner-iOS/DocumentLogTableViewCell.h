//
//  DocumentLogTableViewCell.h
//  emSigner
//
//  Created by Administrator on 8/17/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentLogTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLable;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLable;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
