//
//  AttachedViewVC.h
//  emSigner
//
//  Created by Administrator on 7/20/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
@interface AttachedViewVC : UIViewController<UIAlertViewDelegate,QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *attachedToolbar;
@property (strong, nonatomic) NSString *pdfImagedetail;
@property (strong, nonatomic) NSString *workFlowID;
@property (nonatomic, assign) BOOL isPasswordProtected;
@property (nonatomic, strong) NSString *myTitle;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic,strong) NSString *documentID;
@property (strong,nonatomic) NSString *pdfImageArray;
@property (strong,nonatomic) NSMutableArray *inactiveArray;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (nonatomic, weak) NSIndexPath *selectedIndexPath;


@property (weak, nonatomic) IBOutlet UIWebView *attchedWebview;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

- (IBAction)downloadBtn:(id)sender;
- (IBAction)deleteBtn:(id)sender;
@end
