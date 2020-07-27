//
//  CommentsController.h
//  emSigner
//
//  Created by EMUDHRA on 14/08/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentsController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *commetsView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UITableView *docTableView;
@property (weak, nonatomic) IBOutlet UITextField *commentsTextField;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *post_Btn;
@property (nonatomic, strong) NSString *workflowID;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableview;
@property (strong,nonatomic) NSMutableArray * documentNamesArray;
@property (strong,nonatomic) NSMutableArray * getDcommentsArray;
@property (nonatomic, strong) NSString *documentID;

@end

NS_ASSUME_NONNULL_END
