//
//  CoSignPendingVC.h
//  emSigner
//
//  Created by Administrator on 7/15/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotStartedTableViewCell.h"
#import "DraftInactiveVC.h"
#import <QuickLook/QuickLook.h>
@interface CoSignPendingVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIAlertViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource>
{
    int currentPreviewIndex;
}
@property (strong,nonatomic) NSString *pdfFileName;
@property (strong,nonatomic) NSString *pdfFiledata;
@property (nonatomic, strong) NSMutableArray * filterItem;
@property (nonatomic, strong) NSMutableArray * filterArray;

@property (nonatomic) NSMutableArray *draftArray;
@property (nonatomic) NSString *pdfImageArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarItem;
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger totalRow;
@property (strong, nonatomic) NSString *workflowID;
@property (strong, nonatomic) NSString *documentID;
@property (nonatomic, strong) NSMutableArray *inactiveArray;
@property (strong, nonatomic) NSString *pdfImagedetail;
@property (nonatomic, strong) NSString *myTitle;


@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *inactiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIToolbar *draftToolbar;


- (IBAction)cancelBtn:(id)sender;
- (IBAction)inactiveBtn:(id)sender;
- (IBAction)downloadBtn:(id)sender;
- (IBAction)shareBtn:(id)sender;
@end
