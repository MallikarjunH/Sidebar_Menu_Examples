//
//  CompleteMultipleDocumentVC.h
//  emSigner
//
//  Created by Administrator on 6/1/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiplePdfTableViewCell.h"
#import <PDFKit/PDFKit.h>



@protocol PreviousViewControllerTwoDelegate<NSObject>
@required
-(void)dataFromControllerTwo:(NSString *)data;
-(void)documentNameControllerTwo:(NSString *)dName;
-(void)dataForWorkflowId:(NSString *)dWorkflowid;
-(void)selectedCellIndexTwo:(int)iIndex;
@end

@interface CompleteMultipleDocumentVC : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id<PreviousViewControllerTwoDelegate> delegate;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (strong, nonatomic) NSString *workFlowId;
@property (strong,nonatomic) NSString *document;
@property (nonatomic, assign) int selectedRow;
@property (nonatomic, assign) int currentSelectedRow;
@property (strong, nonatomic) NSString *strExcutedFrom;
@property (strong, nonatomic) PDFDocument *pdfDocument;

@property (nonatomic, strong) NSMutableDictionary *documentInfoArray;

@end
