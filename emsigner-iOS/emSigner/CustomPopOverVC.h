//
//  CustomPopOverVC.h
//  emSigner
//
//  Created by Administrator on 8/2/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CellPopUp
-(void)dissmissCellPopup:(NSInteger)row;
@end
@interface CustomPopOverVC : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) id <CellPopUp> delegate;
@property (nonatomic, strong) NSArray *documentInfoArray;
@property (nonatomic, strong) NSArray *documentImageArray;
@property (strong,nonatomic) NSString *documentCount;
@property (strong,nonatomic) NSString *attachmentCount;
@property (strong,nonatomic) NSString *workflowID;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
