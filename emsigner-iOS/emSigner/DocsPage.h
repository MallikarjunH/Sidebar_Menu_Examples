//
//  DocsPage.h
//  emSigner
//
//  Created by Emudhra on 27/07/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocsPage : UIViewController<UITableViewDataSource,UITableViewDelegate,UITabBarDelegate>

@property (nonatomic,strong) NSMutableArray *categoriesArray;
@property (nonatomic,strong) NSMutableArray *docsArray;

@property (weak, nonatomic) IBOutlet UITableView *docsTableView;
@property (nonatomic,strong) NSString *titleName;
@property (strong) NSArray *responseArray;

@property (strong,nonatomic) NSArray *docs;
@property (strong,nonatomic) NSArray *searchResults;
@property (strong ,nonatomic ) NSMutableArray* myArray;
@property (nonatomic,strong) NSDictionary *dataDictionary;
@property (strong, nonatomic) NSArray *DocumentTypeImageview;

@end