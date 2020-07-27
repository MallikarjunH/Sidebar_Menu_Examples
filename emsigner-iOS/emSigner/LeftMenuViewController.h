//
//  LeftMenuViewController.h
//  DrawerMenuApp
//
//  Created by Valtech MacMini on 13/05/15.
//  Copyright (c) 2015 Valtech MacMini. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol mytablecellCliclked<NSObject>
@optional
-(void)tableCellClickedWithIndex:(int)aIndex;
@end
@interface LeftMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    id <mytablecellCliclked> mdelegate;
    //expandable Menu
    NSMutableArray *dataArray;
    NSInteger indentationlevel;
    CGFloat indendationWidth;
   //
}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, assign) int currentSelectedRow;


@property(nonatomic,weak)id mdelegate;

@end
