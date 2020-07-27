//
//  MyProfileVC.h
//  emSigner
//
//  Created by Administrator on 7/26/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPFloatingPlaceholderTextField.h"
#import "RPFloatingPlaceholderTextView.h"
@interface MyProfileVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
   // CGPoint svos;
}

@property (weak, nonatomic) IBOutlet UITableView *profileTableView;
@property (strong, nonatomic) NSMutableArray *profileArray;
@property (weak, nonatomic) NSMutableArray *updateProfileArray;
@property(nonatomic,strong) NSString *titleName;
@property(strong,nonatomic) NSMutableArray *section1tableTitleArray;
@property(strong,nonatomic) NSMutableArray *section2tableTitleArray;

@end
