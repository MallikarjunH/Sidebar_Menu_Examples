//
//  ForgotPasswordVC.h
//  emSigner
//
//  Created by Administrator on 9/22/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordVC : UIViewController<UITextFieldDelegate>
{
    NSArray *ar1;
    NSString *Captcha_string;
    NSUInteger i1,i2,i3,i4,i5;
    UIAlertView *Captcha_alert;
}
@property (weak, nonatomic) IBOutlet UILabel *forgotPasswordLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtnPressed;
@property (weak, nonatomic) IBOutlet UIButton *submitBtnPressed;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UILabel *Captcha_label;
@property (weak, nonatomic) IBOutlet UITextField *Captcha_field;
@property (weak, nonatomic) IBOutlet UILabel *Status_label;
@property (nonatomic, strong) NSArray *forgotPasswordArray;

- (IBAction)reloadBtnPressed:(id)sender;
- (IBAction)submitBtnPressed:(id)sender;
- (IBAction)cancelBtnPressed:(id)sender;

@end
