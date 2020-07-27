//
//  DocsStoreMultiplePdf.h
//  emSigner
//
//  Created by Administrator on 6/26/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "ViewController.h"
#import "MultiplePdfTableViewCell.h"
@protocol PreviousDocStoreViewControllerTwoDelegate<NSObject>
@required
-(void)dataFromControllerTwo:(NSString *)data;
-(void)documentNameControllerTwo:(NSString *)dName;
-(void)selectedCellIndexTwo:(int)iIndex;
@end
@interface DocsStoreMultiplePdf : ViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) id<PreviousDocStoreViewControllerTwoDelegate> delegate;
@property (strong,nonatomic) NSMutableArray *listArray;
@property (strong, nonatomic) NSString *workFlowId;
@property (strong,nonatomic) NSString *document;
@property (nonatomic, assign) int selectedRow;
@property (nonatomic, assign) int currentSelectedRow;

@property (nonatomic, strong) NSMutableDictionary *documentInfoArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
