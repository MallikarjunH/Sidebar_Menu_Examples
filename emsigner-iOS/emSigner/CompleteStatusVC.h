//
//  CompleteStatusVC.h
//  emSigner
//
//  Created by Administrator on 11/15/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompletedTableViewCell.h"
#import "CompletedNextVC.h"
#import <PDFKit/PDFKit.h>

@interface CompleteStatusVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIAlertViewDelegate,UIActionSheetDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource>


@property (weak, nonatomic) IBOutlet UISearchBar *searchBarItem;
@property (nonatomic, strong) NSMutableArray *filterArray;
@property (nonatomic, strong) NSMutableArray *filterSecondArray;

@property (nonatomic) NSMutableArray *completedArray;
@property (nonatomic,strong) NSString *pdfImageString;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) NSUInteger totalRow;
@property(nonatomic,strong) NSMutableArray *addFile;
@property (strong,nonatomic) NSString *pdfFileName;
@property (strong,nonatomic) NSString *pdfFiledata;
@property (strong,nonatomic) NSMutableArray *pdfImageArray;
@property (nonatomic,assign) NSString *workflowId;
@property (nonatomic, strong) NSString *myTitle;

@property (nonatomic,strong) NSMutableArray *docInfoArray;
@property (strong, nonatomic) PDFDocument *pdfDocument;

@property (strong,nonatomic) NSString *workFlowType;

@property (strong,nonatomic) NSString *pdfName;
@property (strong,nonatomic) NSString *filePath;
@property (strong,nonatomic)   NSString *path ;

@end
