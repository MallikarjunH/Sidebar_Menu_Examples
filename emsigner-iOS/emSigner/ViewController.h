//
//  ViewController.h
//  emSigner
//
//  Created by Administrator on 7/12/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForgotPasswordVC.h"
//#import "QRCodeReaderViewController.h"
//#import "QRCodeReader.h"
//#import "TabBarView.h"
//#import "QRCodeReaderDelegate.h"

// if you want to import above files also add its delegate qrcode amd custom bar delegate


@interface ViewController : UIViewController <UITextFieldDelegate,UIScrollViewDelegate,UITextViewDelegate,UIAlertViewDelegate>
{
    CGPoint svos;
    NSArray *ar1;
    NSString *Captcha_string;
    NSUInteger i1,i2,i3,i4,i5;
 }


@property (nonatomic, assign) int selectedIndex;
@property (weak, nonatomic) IBOutlet UIButton *secureEntryBtn;
    @property (weak, nonatomic) IBOutlet UIButton *loginOffice365;
    
@property (weak, nonatomic) IBOutlet UIView *customViewScroll;
@property (strong, nonatomic) IBOutlet UIView *parentView;
@property (weak, nonatomic) IBOutlet UIView *loginBtnView;

@property (weak, nonatomic) IBOutlet UIView *captchaView;
@property (weak, nonatomic) IBOutlet UIView *credentialView;
@property (weak, nonatomic) IBOutlet UIView *scrollTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *pagerScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *pagerImageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *rememberLable;
@property (weak, nonatomic) IBOutlet UIScrollView *loginScrollView;

@property (weak, nonatomic) IBOutlet UIView *loginCardView;
@property (weak, nonatomic) IBOutlet UIImageView *mEmailImage;

@property (strong, nonatomic) UIWindow *window;

/**********************PageController **************************/
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

/******************ViewController outlet***********************/
@property (weak, nonatomic) IBOutlet UITextField *mEmail;
@property (weak, nonatomic) IBOutlet UITextField *mPassword;
@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UISwitch *checkBoxBtn;

@property (weak, nonatomic) IBOutlet UIView *initialView;

@property (weak, nonatomic) IBOutlet UIImageView *imageLogo;

@property (weak, nonatomic) IBOutlet UIButton *mLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgotPassword;
@property (weak, nonatomic) NSMutableArray *forgotPasswordArray;
@property (strong, nonatomic) NSDictionary *responseDictionary;
@property (strong, nonatomic) NSMutableArray *profileArray;

@property (weak, nonatomic) IBOutlet UILabel *customCaptchalable;
@property (weak, nonatomic) IBOutlet UITextField *customCaptchaText;
@property (weak, nonatomic) IBOutlet UILabel *captchaValidationLable;
@property (weak, nonatomic) IBOutlet UIButton *captchaRefreshBtn;
@property(nonatomic,assign) BOOL isFingerPrintDone;


//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBtnTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captchaViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBtnViewHeight;


//

- (IBAction)mLoginBtn:(id)sender;
- (IBAction)checkBoxBtn:(id)sender;
- (IBAction)forgotPassword:(id)sender;
- (IBAction)captchaRefreshBtn:(id)sender;
- (IBAction)secureEntryBtn:(id)sender;

-(void)loginWithLoginBtn:(NSString*)email;
-(void)loginWithOffice365:(NSString*)email;

@end

