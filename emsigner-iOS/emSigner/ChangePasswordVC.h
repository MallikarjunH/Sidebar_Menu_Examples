//
//  ChangePasswordVC.h
//  emSigner
//
//  Created by Administrator on 7/26/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordVC : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIButton *secureEntryNewPass;
@property (weak, nonatomic) IBOutlet UIButton *secureEntryCurrentPass;
@property (weak, nonatomic) IBOutlet UIButton *secureEntryConfirmPass;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordText;
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordText;
@property (weak, nonatomic) IBOutlet UITextField * pass;

@property (strong, nonatomic) NSDictionary *changePasswordDictionary;
@property (weak, nonatomic) IBOutlet UIButton *saveBtnClicked;
@property (weak, nonatomic) IBOutlet UIButton *clearBtnClicked;
 




- (IBAction)saveBtnClicked:(id)sender;
- (IBAction)clearBtnClicked:(id)sender;
- (IBAction)secureEntryCurrentPass:(id)sender;
- (IBAction)secureEntryNewPass:(id)sender;
- (IBAction)secureEntryConfirmPass:(id)sender;


@end
