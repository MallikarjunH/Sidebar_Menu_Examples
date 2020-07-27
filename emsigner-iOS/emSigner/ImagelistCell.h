//
//  ImagelistCell.h
//  emSigner
//
//  Created by Emudhra on 22/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagelistCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ImageList;
@property (weak, nonatomic) IBOutlet UILabel *DocumentName;
@property (weak, nonatomic) IBOutlet UILabel *DateAndTime;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end
