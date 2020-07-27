//
//  SignatoriesListForFlexiforms.h
//  emSigner
//
//  Created by Emudhra on 27/02/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol senddattaProtocol <NSObject>
//-(void)sendDataTosigners:(NSMutableArray *)array :(NSMutableDictionary*)subscriberdict;
-(void)sendDataTosigners:(NSMutableArray *) array;
@end

@interface SignatoriesListForFlexiforms : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *signatoriesList;
@property (assign) NSInteger expandedSectionHeaderNumber;
@property (assign) NSInteger SectionNumber;
@property (assign) UITableViewHeaderFooterView *expandedSectionHeader;
@property(nonatomic,assign)id delegate;

@property (strong,nonatomic) NSMutableArray* ShowSignersList;
@property (strong,nonatomic) NSMutableArray* holdSignersList;
@property (nonatomic, assign) NSInteger signersCount;
@property (nonatomic,strong) NSMutableArray *sectionArray;
@property (nonatomic,strong) NSMutableArray *subscriberIdArray;

@end

NS_ASSUME_NONNULL_END
