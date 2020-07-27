//
//  ShowActivities.h
//  emSigner
//
//  Created by EMUDHRA on 26/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShowActivities : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *showActivities;
@property(nonatomic,strong)NSMutableArray *showArrayForActivity;
@property(nonatomic,strong)NSArray *TotalArrayForActivity;
@property(nonatomic,strong)NSString *categoryname;
@property (strong) NSArray *responseArray;

@end

NS_ASSUME_NONNULL_END
