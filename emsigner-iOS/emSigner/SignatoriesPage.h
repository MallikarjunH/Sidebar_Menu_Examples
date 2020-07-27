//
//  SignatoriesPage.h
//  emSigner
//
//  Created by Emudhra on 06/08/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignatoriesPage : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *addSignatureTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dismissBtn;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (strong, nonatomic) NSString *strExcutedFrom;


//@property (weak, nonatomic) IBOutlet UIImageView *imageViewForSign;
//@property(nonatomic, retain) NSIndexPath *lastIndexPath;
@property (weak, nonatomic) IBOutlet UINavigationBar *signBtn;

@end
