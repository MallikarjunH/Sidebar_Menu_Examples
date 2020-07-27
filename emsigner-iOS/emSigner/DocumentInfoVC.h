//
//  DocumentInfoVC.h
//  emSigner
//
//  Created by Administrator on 1/19/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocInfoTableViewCell.h"
#import "DocAssignedTableViewCell.h"
#import "AppDelegate.h"

@interface DocumentInfoVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *authorisedSignatureLabel;

@property (strong, nonatomic) IBOutlet UITableView *documentTable;
@property (strong, nonatomic)  UICollectionView *signcollectionView;
@property (nonatomic,strong) NSMutableArray *recalledArray;

@property (nonatomic,strong) NSMutableArray *documentInfoArray;

@property (nonatomic,strong)NSString *titleString;

@property (nonatomic,strong) NSString *nullCheck;
@property (nonatomic,strong) NSMutableArray *lableArray;
@property (nonatomic, strong) NSString *docInfoWorkflowId;
//@property (nonatomic,strong) NSString *statusStringToDocumentInfo;
@property (nonatomic, strong) NSString *status;
@property (nonatomic , strong) NSArray *tableTitleArray;
@property (nonatomic,strong) NSArray *tableSubtitleArray;



@end
