//
//  AccountViewController.h
//  emSigner
//
//  Created by Emudhra on 05/09/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "emSigner-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccountViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *accountTableView;

@property(nonatomic,strong)NSMutableArray *profileArray;
@property(strong,nonatomic) swiftController *cntroller;

@end

NS_ASSUME_NONNULL_END
