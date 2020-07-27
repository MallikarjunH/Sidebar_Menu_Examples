//
//  DropDownCell.h
//  emSigner
//
//  Created by EMUDHRA on 14/08/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DropDownCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *Edit_Btn;
@property (weak, nonatomic) IBOutlet UIButton *delete_btn;
@property (weak, nonatomic) IBOutlet UILabel *date_label;
@property (weak, nonatomic) IBOutlet UILabel *comment_label;
@property (weak, nonatomic) IBOutlet UILabel *user_name;

@end

NS_ASSUME_NONNULL_END
