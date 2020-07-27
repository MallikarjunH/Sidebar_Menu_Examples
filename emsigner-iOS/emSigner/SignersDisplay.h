//
//  SignersDisplay.h
//  emSigner
//
//  Created by EMUDHRA on 29/10/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPBSignatureViewController.h"
#import "IQKeyboardManager.h"

NS_ASSUME_NONNULL_BEGIN
//-(void)uploadMorePic:(NSDictionary *)dict muliPics:(NSData *)file
@protocol senddattaProtocol <NSObject>
//-(void)sendDataTosigners:(NSMutableArray *)array :(NSMutableDictionary*)subscriberdict;
-(void) sendDataTosigners:(NSMutableArray *)array SubscriberDict:(NSMutableDictionary *)subscriberdict SignType:(NSMutableArray *)SignType  DataForNameAndEmailID: (NSMutableArray *)dataForNameAndEmailId;

@end

@interface SignersDisplay : UIViewController<UITableViewDelegate,UITableViewDataSource,sendsignatures,UIAlertViewDelegate,UITextFieldDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *signersList;
@property (strong,nonatomic) NSMutableArray* holdSignersList;
@property (strong,nonatomic) NSMutableArray* passsignerArray;
@property (strong,nonatomic)NSMutableArray *docName;
@property (strong,nonatomic)NSMutableArray *subscriberIdarray;
@property (strong,nonatomic)NSMutableArray *pageIdarray;

@property(nonatomic, assign) NSInteger signersCount;
@property(nonatomic,assign)id delegate;
@property (strong,nonatomic) NSString *CategoryId;
@property (strong,nonatomic) NSString *CategoryName;
@property (strong,nonatomic) NSString *Documentname;
@property (nonatomic, assign) NSInteger DocumentID;
@property (nonatomic, assign) NSInteger DocumentIDFromUploadApi;

@property (strong,nonatomic) NSString *ConfigId;
 @property (strong,nonatomic) NSMutableArray * SignerssectionArray;

@property (weak, nonatomic) IBOutlet UITextField *refillName;
@property (weak, nonatomic) IBOutlet UITextField *refillEmailId;
@property (weak, nonatomic) IBOutlet UITextField *refillMobile;

@property (weak, nonatomic) IBOutlet UITextField *refillOrganization;
@property (strong,nonatomic) NSMutableArray *arrayForCollectionViewForTap;
@property (strong,nonatomic) NSMutableDictionary *holdNameandEmailDataForCollectionView;

@property (weak, nonatomic) IBOutlet UIView *customPopUp;
@property (weak, nonatomic) IBOutlet UIButton *submitAdhoc;

@property (nonatomic, strong) NSArray *searchResults;
@property (strong,nonatomic) NSMutableArray* ShowSignersList;


@end

NS_ASSUME_NONNULL_END
