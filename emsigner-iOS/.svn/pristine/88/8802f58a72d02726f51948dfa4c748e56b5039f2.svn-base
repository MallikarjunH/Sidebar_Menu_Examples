//
//  CompletedNextVC.h
//  emSigner
//
//  Created by Administrator on 12/21/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentLogVC.h"
#import <QuickLook/QuickLook.h>
#import "CompleteMultipleDocumentVC.h"
#import "CustomPopOverVC.h"
#import "CompleteMultipleDocumentVC.h"
#import <PDFKit/PDFKit.h>


@interface CompletedNextVC : UIViewController<UITextViewDelegate,UIAlertViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,PreviousViewControllerTwoDelegate,UIPopoverPresentationControllerDelegate,UISearchBarDelegate,UITabBarDelegate>
{
    int currentPreviewIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *signatorylbl;

@property (weak, nonatomic) IBOutlet PDFView *pdfView;
@property (weak, nonatomic) IBOutlet UIScrollView *pdfScrollView;
@property (strong,nonatomic) NSString *pdfFileName;
@property (strong,nonatomic) NSString *pdfFiledata;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (nonatomic, assign) int selectedIndex;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *myTitle;
@property (strong, nonatomic) NSString *pdfImagedetail;
@property (strong, nonatomic) NSString *workflowID;
@property (nonatomic, strong) NSString *multiplePdfImagedetail;
@property (strong,nonatomic) NSMutableArray *pdfImageArray;
@property (strong,nonatomic) NSMutableArray *shareArray;
@property (strong,nonatomic) NSString *documentID;
@property (weak, nonatomic) IBOutlet UIButton *documentLog;
@property (strong,nonatomic) NSString *documentCount;
@property (strong,nonatomic) NSString *attachmentCount;
@property (nonatomic, strong) UIPopoverPresentationController *popover;
@property (strong, nonatomic) NSString *strExcutedFrom;
@property(nonatomic,strong) NSMutableArray *addFile;
@property (nonatomic, assign) BOOL isPasswordProtected;
@property(nonatomic,strong) NSMutableString *signatoryString;
@property(nonatomic,assign) NSInteger *parallel;
@property(nonatomic,strong) NSString *_pathForDoc;
@property (strong, nonatomic) PDFDocument *pdfDocument;
@property (nonatomic, assign) const char *passwordForPDF;
@property (weak, nonatomic) IBOutlet UITabBar *completedTabbar;
@property(assign)BOOL isDocStore;
- (IBAction)downloadBtn:(id)sender;
- (IBAction)documentLog:(id)sender;
- (IBAction)shareBtn:(id)sender;


@end
