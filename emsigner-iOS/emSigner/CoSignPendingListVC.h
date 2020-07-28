//
//  CoSignPendingListVC.h
//  emSigner
//
//  Created by Nawin Kumar on 12/4/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "InprogressMultiplePdf.h"
#import <PDFKit/PDFKit.h>

@interface CoSignPendingListVC : UIViewController<UIAlertViewDelegate,UITextViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,PreviousViewcontrollerDelegate,UIPopoverPresentationControllerDelegate,UIScrollViewDelegate>
{
    int currentPreviewIndex;
}

@property (weak, nonatomic) IBOutlet UILabel *signatorylbl;
@property (weak, nonatomic) IBOutlet PDFView *pdfView;
@property (strong,nonatomic) NSString *pdfFileName;
@property (strong,nonatomic) NSString *pdfFiledata;
@property (nonatomic, strong) UIPopoverPresentationController *popover;
@property (weak, nonatomic) IBOutlet UIButton *inactiveBtn;
@property (nonatomic, assign) int selectedIndex;
@property (nonatomic, strong) NSString *myTitle;
@property (strong, nonatomic) NSString *pdfImagedetail;
@property (strong,nonatomic) NSMutableArray *declineArray;
@property (strong,nonatomic) NSMutableArray *shareArray;
@property (strong,nonatomic) NSMutableArray *pdfImageArray;
@property (nonatomic, strong) NSMutableArray *inactiveArray;
@property (strong, nonatomic) NSString *strExcutedFrom;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *workflowID;
@property (strong, nonatomic) NSString *multiplePdfImagedetail;
@property (weak, nonatomic) IBOutlet UIButton *docLog;
@property (strong, nonatomic) NSString *documentID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSString *documentCount;
@property (strong,nonatomic) NSString *attachmentCount;
@property(nonatomic,strong) NSMutableArray *addFile;
@property (nonatomic,strong) NSString *signatoryString;

@property(nonatomic,strong) NSString *pathForDoc;

@property (strong, nonatomic) PDFDocument *pdfDocument;
@property (strong,nonatomic) NSString *workFlowType;

@property (nonatomic, assign) const char *passwordForPDF;
@property (weak, nonatomic) IBOutlet UITabBar *waitingForOthersTabBar;

- (IBAction)downloadBtn:(id)sender;
- (IBAction)shareBtn:(id)sender;
- (IBAction)inActiveBtn:(id)sender;

@end
