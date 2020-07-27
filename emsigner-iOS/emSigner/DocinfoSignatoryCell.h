//
//  DocinfoSignatoryCell.h
//  emSigner
//
//  Created by EMUDHRA on 28/05/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocinfoSignatoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *Signertype;

@end
