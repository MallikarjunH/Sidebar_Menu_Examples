//
//  AttachedVC.h
//  emSigner
//
//  Created by Administrator on 7/16/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachedMultiplePdfTableViewCell.h"
#import <QuickLook/QuickLook.h>
#import "Reachability.h"

@interface AttachedVC : UIViewController<UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UIDocumentPickerDelegate, UIDocumentMenuDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *attachedToolBar;
@property (weak, nonatomic) IBOutlet UITableView *attachedTableView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *inactiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;

@property (weak, nonatomic) IBOutlet UIView *documentView;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@property (strong,nonatomic) NSString *pdfFileName;
@property (strong,nonatomic) NSString *pdfFiledata;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (strong,nonatomic) NSMutableArray *threeDotsArray;

@property (strong,nonatomic) NSString *pdfImageArray;
@property (strong,nonatomic) NSMutableArray *inactiveArray;
@property (nonatomic, assign) int currentSelectedRow;
@property (strong, nonatomic) NSString *workFlowId;
@property (strong,nonatomic) NSString *document;
@property (strong,nonatomic) NSString *documentName;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic,strong) NSString *documentID;
@property(nonatomic,strong) NSString *base64Image;
@property(assign) BOOL isAttached;
@property(assign) BOOL isDocStore;
- (IBAction)inactiveBtn:(id)sender;
- (IBAction)downloadBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *uploadAttachment;

@property (nonatomic,strong) NSMutableArray *parametersForWorkflow;

//@property (strong,nonatomic) NSMutableArray *inactiveArray;
@property (weak, nonatomic) IBOutlet UITextField *descText;

@property(nonatomic,strong) NSMutableArray *addFile;

- (IBAction)cancelBtn:(id)sender;

@end
