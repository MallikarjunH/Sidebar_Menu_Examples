//
//  DocInfoTableViewCell.h
//  emSigner
//
//  Created by Administrator on 1/27/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *statusLable;
@property (weak, nonatomic) IBOutlet UILabel *timeDateLable;
@property (weak, nonatomic) IBOutlet UILabel *sizeLable;

@end
