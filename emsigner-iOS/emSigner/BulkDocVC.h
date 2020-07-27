//
//  BulkDocVC.h
//  emSigner
//
//  Created by Emudhra on 17/06/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PendingVC.h"
#import "CoSignPendingVC.h"
#import "RecallStatusVC.h"
#import "DeclineStatusVC.h"
#import "CompleteStatusVC.h"
#import "ShareVC.h"
#import "CoSignPendingListVC.h"
#import "CaptureSignatureView.h"
#import "SingletonAPI.h"
#import <QuickLook/QuickLook.h>
#import "DocumentInfoVC.h"
#import "CustomPopOverVC.h"
#import <PDFKit/PDFKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface BulkDocVC : UIViewController<QLPreviewControllerDelegate,QLPreviewControllerDataSource> {
    
    
     int currentPreviewIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *workflowTable;
 @property (nonatomic, retain) NSArray *arrayOriginal;
    @property (nonatomic, retain) NSMutableArray *arForTable;
    @property (strong) NSArray *responseArray;
    @property (strong,nonatomic) NSMutableArray *subarray;
    @property (strong,nonatomic) NSMutableArray *mainarray;
@property(strong,nonatomic)NSString *lotId;
@property(strong,nonatomic)NSString *type;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (strong,nonatomic)NSString *workFlowId;
@property (strong,nonatomic) NSMutableArray *pdfImageArray;
@property (strong,nonatomic) NSString *pdfFileName;
@property (strong,nonatomic) NSString *pdfFiledata;
@property(nonatomic,strong) NSMutableArray *addFile;
@property (strong,nonatomic) NSMutableArray *docInfoArray;
@property (strong, nonatomic) NSMutableArray *checkNullArray;
@property (strong, nonatomic) PDFDocument *pdfDocument;
@property (strong,nonatomic) NSString *workflowType;
@end

NS_ASSUME_NONNULL_END
