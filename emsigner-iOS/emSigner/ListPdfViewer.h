//
//  ListPdfViewer.h
//  emSigner
//
//  Created by Administrator on 3/21/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdfListTableViewCell.h"
@interface ListPdfViewer : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *hideView;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (strong, nonatomic) NSMutableArray *listArray;
@property (strong, nonatomic) NSMutableArray *countArray;
@property (strong, nonatomic) NSMutableArray *expandedCells;
@property (weak, nonatomic) IBOutlet UIImageView *transparentImageView;
- (IBAction)cancelBtnPressed:(id)sender;


@end
