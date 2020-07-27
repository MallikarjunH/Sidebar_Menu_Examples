//
//  ParallelSigning.h
//  emSigner
//
//  Created by Emudhra on 25/02/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentLogVC.h"
#import <QuickLook/QuickLook.h>
#import "CompleteMultipleDocumentVC.h"
#import "CustomPopOverVC.h"
#import "CompleteMultipleDocumentVC.h"


#import <PDFKit/PDFKit.h>

@interface ParallelSigning : UIViewController<UITextViewDelegate,UIAlertViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,PreviousViewControllerTwoDelegate,UIPopoverPresentationControllerDelegate,UISearchBarDelegate>
{
    int currentPreviewIndex;

}
@property (weak, nonatomic) IBOutlet UILabel *Signatorylbl;
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
@property(strong,nonatomic) NSArray* matchSignersList;
@property (nonatomic, assign) const char *passwordForPDF;
@property (strong,nonatomic) NSArray *placeholderArray;
@property(strong,nonatomic)UIImage *signatureImage;

@property (strong, nonatomic) PDFDocument *pdfDocument;


@end
