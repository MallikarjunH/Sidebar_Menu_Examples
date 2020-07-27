/*
 * Payment Signature View: http://www.payworks.com
 *
 * Copyright (c) 2015 Payworks GmbH
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>
#import "MPBSignatureViewControllerConfiguration.h"
#import "HomeNewDashBoardVC.h"
#import <QuickLook/QuickLook.h>

typedef void (^MPBCustomStyleSignatureViewControllerContinue)(UIImage *signature);
typedef void (^MPBCustomStyleSignatureViewControllerCancel)();

@protocol sendsignatures <NSObject>
-(void)sendsign:(NSMutableDictionary*)signdict;
@end

//@protocol SendDataDelegate <NSObject>
//
//@required
//- (void)dataFromSignPageController:(NSString *)data;
//
//@end

@interface MPBCustomStyleSignatureViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,QLPreviewControllerDataSource,QLPreviewControllerDelegate,QLPreviewControllerDelegate>

//@property (nonatomic, weak) id<SendDataDelegate> dataDelegate;


@property (nonatomic, strong) MPBSignatureViewControllerConfiguration *configuration;

@property (nonatomic, copy) MPBCustomStyleSignatureViewControllerContinue continueBlock;
@property (nonatomic, copy) MPBCustomStyleSignatureViewControllerCancel cancelBlock;

@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic, strong) IBOutlet UIView *signatureView;
//@property (nonatomic, strong) IBOutlet UIImageView *schemeImageView;
//@property (nonatomic, strong) IBOutlet UILabel *merchantNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *formattedAmountLabel;
//@property (nonatomic, strong) IBOutlet UIImageView *merchantImageView;

@property (nonatomic, strong) IBOutlet UILabel *legalTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imgCapture;

@property (nonatomic, strong) IBOutlet UIButton *continueButton;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton *clearButton;
@property (nonatomic, strong) IBOutlet UIButton *showSignaturePadButton;
@property (nonatomic,strong) IBOutlet UIButton *moreButton;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionOfSignatures;
@property (nonatomic,strong) IBOutlet UIButton *saveButton;
@property (nonatomic, assign) NSInteger counter;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewForSignature;
@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong,nonatomic) NSMutableArray *imageArrayForSignature;
@property (strong,nonatomic) NSMutableArray *BigimageArrayForSignature;
@property (nonatomic, strong) NSString *signatureWorkFlowID;
@property (nonatomic, strong) NSString *signatureWorkFlowType;
@property (nonatomic, strong) NSString *reviewerComments;
@property (nonatomic, assign) const char *passwordForPDF;
@property (nonatomic, strong) NSString *LotId;

@property (nonatomic, strong) NSString *signBtnTitle;
@property (strong, nonatomic) NSString *strExcutedFrom;
@property (nonatomic,strong) NSMutableArray *gotParametersForInitiateWorkFlow;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) NSString *CategoryId;
@property (strong,nonatomic) NSString *CategoryName;
@property (strong,nonatomic) NSString *Documentname;
@property (nonatomic, assign) NSInteger DocumentID;
@property (strong,nonatomic) NSString *ConfigId;
@property (strong,nonatomic) NSMutableArray* subscriberIdarray;
@property (strong,nonatomic) NSMutableArray* d;
@property (strong,nonatomic) NSMutableArray* signersArray;
@property (nonatomic, assign) BOOL isReviewer;
@property (weak,nonatomic) id delegate;
@property (strong, nonatomic) UIWindow *window;
@property (assign)BOOL isFromSignerView;
@property (assign)BOOL isBulk;

- (instancetype)initWithConfiguration:(MPBSignatureViewControllerConfiguration *)configuration;
+ (instancetype)controllerWithConfiguration:(MPBSignatureViewControllerConfiguration *)configuration;

- (void)continueWithSignature;
- (void)cancelSignature;
- (void)clearSignature;

- (void)disableContinueAndClearButtonsAnimated:(BOOL)animated;
- (void)enableContinueAndClearButtons;
- (void)handleSingleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer;

- (NSBundle *)resourceBundle;
- (NSString *)localizedString:(NSString *)token;
- (UIImage *)imageWithName:(NSString *)name;

@end


