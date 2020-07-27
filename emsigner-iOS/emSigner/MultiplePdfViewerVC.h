//
//  MultiplePdfViewerVC.h
//  emSigner
//
//  Created by Administrator on 5/24/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiplePdfTableViewCell.h"
#import <PDFKit/PDFKit.h>

@protocol SecondViewControllerDelegate <NSObject>
@required
- (void)dataFromController:(NSString *)data;
-(void)dataFordocumentName:(NSString *)dName;
-(void)dataForWorkflowId:(NSString *)dWorkflowid;
-(void)selectedCellIndex:(int)iIndex;

@end

@interface MultiplePdfViewerVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UIPopoverPresentationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, weak) id<SecondViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableDictionary *documentInfoArray;
@property (strong, nonatomic) NSMutableArray *checkNullArray;


@property (nonatomic, strong) UIPopoverPresentationController *popover;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (strong,nonatomic) NSArray *placeholderArray;
@property (strong, nonatomic) NSString *workFlowId;
@property (strong, nonatomic) NSString *workFlowType;
@property (strong,nonatomic) NSString *document;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) int currentSelectedRow;
@property (strong, nonatomic) NSString *strExcutedFrom;
@property (strong,nonatomic)  NSMutableString * mstrXMLString ;
@property (strong,nonatomic)  UIImage * signatureImage;
@property (strong,nonatomic) NSString *parallel;
@property (strong,nonatomic) NSArray *signatoryHolderArray;
@property (strong, nonatomic) PDFDocument *pdfDocument;


@end
