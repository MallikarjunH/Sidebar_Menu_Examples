//
//  DraftInactiveVC.h
//  emSigner
//
//  Created by Administrator on 12/29/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import <PDFKit/PDFKit.h>

@interface DraftInactiveVC : UIViewController<UIAlertViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UIScrollViewDelegate>
{
    int currentPreviewIndex;
}
@property (weak, nonatomic) IBOutlet PDFView *pdfView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *myTitle;
@property (strong, nonatomic) NSString *pdfImagedetail;
@property (strong,nonatomic) NSMutableArray *pdfImageArray;
@property (nonatomic, strong) NSMutableArray *inactiveArray;
@property (strong, nonatomic) NSString *workflowID;
@property(nonatomic,strong) NSMutableArray *addFile;
@property (strong, nonatomic) PDFDocument *pdfDocument;
@property (nonatomic, assign) const char *passwordForPDF;

- (IBAction)inactiveBtn:(id)sender;
- (IBAction)downloadBtn:(id)sender;
- (IBAction)shareBtn:(id)sender;


@end
