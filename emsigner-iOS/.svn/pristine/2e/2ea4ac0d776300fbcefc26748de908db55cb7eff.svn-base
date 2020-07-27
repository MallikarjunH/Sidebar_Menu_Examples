//
//  DocStoreVC.h
//  emSigner
//
//  Created by Nawin Kumar on 7/17/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotStartedTableViewCell.h"
#import "PendingVCTableViewCell.h"
#import "RecallTableViewCell.h"
#import "CompletedTableViewCell.h"
#import "DeclineTableViewCell.h"
#import "DocsStoreNextVC.h"
#import "PendingListVC.h"
#import "CoSignPendingListVC.h"
#import "CompletedNextVC.h"
#import "DraftInactiveVC.h"
#import <PDFKit/PDFKit.h>

@interface DocStoreVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIAlertViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UIActionSheetDelegate,UITabBarDelegate>
{
    int currentPreviewIndex;
    __weak IBOutlet UITabBar *tabBar;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *docsStoretoolbar;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarItem;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *inactiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (nonatomic, weak) NSIndexPath *selectedIndexPath;

@property (strong, nonatomic) PDFDocument *pdfDocument;
@property (strong, nonatomic) NSMutableArray *checkNullArray;
@property (nonatomic,strong) NSMutableArray *filterArray;
@property (nonatomic, strong) NSMutableArray * filterSecondDocstoreArray;

@property (nonatomic, strong) NSMutableArray *documentArray;
//@property (nonatomic, strong) NSString *pdfImageArray;
@property (assign, nonatomic) NSUInteger currentPage;
@property (nonatomic,strong)NSString *titleName;
@property (assign, nonatomic) NSUInteger totalRow;
@property (nonatomic, assign) int selectedIndex;
@property (strong, nonatomic) NSString *workflowID;
@property (nonatomic, strong) NSMutableArray *inactiveArray;
@property (nonatomic, strong) NSString *openFileName;
@property (assign,nonatomic) NSInteger documentCount;
@property (assign,nonatomic) NSInteger attachmentCount;
@property(nonatomic,strong)  NSMutableArray *addFile;
@property (strong,nonatomic) NSString *pdfFileName;
@property (strong,nonatomic) NSString *pdfFiledata;
@property (strong,nonatomic) NSString *pdfName;
@property (strong,nonatomic) NSString *filePath;
@property (strong,nonatomic) NSMutableArray *pdfImageArray;
@property (strong,nonatomic)   NSString *path ;
@property (strong,nonatomic)  NSMutableString * mstrXMLString ;
@property(strong,nonatomic) NSMutableDictionary *signPadDict;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic,strong) NSMutableArray *docInfoArray;
@property (assign) BOOL isDocStore;
- (IBAction)cancelBtn:(id)sender;
- (IBAction)inactiveBtn:(id)sender;
- (IBAction)downloadBtn:(id)sender;
- (IBAction)shareBtn:(id)sender;

@end
