//
//  CustomSignVC.h
//  emSigner
//
//  Created by Administrator on 7/27/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSignVC : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *parentView;
@property (weak, nonatomic) IBOutlet UITextField *otpText;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UIButton *customSignBtn;
@property (weak, nonatomic) IBOutlet UIButton *customCancelBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *resendOtpBtn;

@property (nonatomic,strong) NSMutableArray *signArray;
@property (nonatomic,strong) NSString *aadhaarString;
@property (nonatomic,strong) NSMutableArray *otpArray;
@property (nonatomic,strong) NSString *esignString;

- (IBAction)customSignBtn:(id)sender;
- (IBAction)customCancelBtn:(id)sender;
- (IBAction)resendOTPBtn:(id)sender;
@end
