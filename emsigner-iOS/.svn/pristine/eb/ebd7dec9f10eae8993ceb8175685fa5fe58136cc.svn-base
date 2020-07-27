//
//  PendingVC.h
//  emSigner
//
//  Created by Administrator on 12/1/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PendingListVC.h"
#import "ShareVC.h"
#import "CoSignPendingListVC.h"
#import "CaptureSignatureView.h"
#import "PendingVCTableViewCell.h"
#import <PDFKit/PDFKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface PendingVC : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate,UITextViewDelegate,CaptureSignatureViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate>
{
    int currentPreviewIndex;
}
@property (weak, nonatomic) IBOutlet UIToolbar *mySignatureToolbar;

@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//
@property (strong, nonatomic) NSMutableArray *coSignPendingArray;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSMutableArray *filterSecondArray;

@property (assign, nonatomic) NSUInteger totalRow;
@property (strong, nonatomic) PDFDocument *pdfDocument;

@property (assign, nonatomic) NSUInteger currentPage;
@property(nonatomic,strong)  NSMutableArray *addFile;
@property (strong,nonatomic) NSString *pdfFileName;
@property (strong,nonatomic) NSString *pdfFiledata;
@property (strong,nonatomic) NSMutableArray *pdfImageArray;
@property (strong,nonatomic) NSString *pdfName;
@property (strong,nonatomic) NSString *filePath;
@property (strong,nonatomic) NSMutableArray *arrayMail;
@property (nonatomic,strong) NSMutableArray *docInfoArray;

- (void)viewWillAppear:(BOOL)animated;
- (void)makeServieCallWithPageNumaber:(NSUInteger)pageNumber;


@end
