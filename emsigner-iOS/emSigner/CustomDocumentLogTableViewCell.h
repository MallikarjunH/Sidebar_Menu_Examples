//
//  CustomDocumentLogTableViewCell.h
//  emSigner
//
//  Created by Administrator on 8/17/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomDocumentLogTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *documentName;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *customerNumber;
@property (weak, nonatomic) IBOutlet UILabel *dateLable;
@property (weak, nonatomic) IBOutlet UILabel *categoryLable;

@end
