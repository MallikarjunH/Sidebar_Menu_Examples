//
//  RenameDocument.h
//  emSigner
//
//  Created by EMUDHRA on 12/12/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RenameDocument : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
