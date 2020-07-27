//
//  ChangePasswordVC.m
//  emSigner
//
//  Created by Administrator on 7/26/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "ChangePasswordVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "ViewController.h"
#import "RPFloatingPlaceholderTextField.h"
#import "RPFloatingPlaceholderTextView.h"
#import "LMNavigationController.h"
//#import "IQKeyboardManager.h"

@interface ChangePasswordVC ()

@end

@implementation ChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.clearBtnClicked.layer.cornerRadius = 10;
    //
    /*****************************Card View*********************************/
    [self.customView setAlpha:1];
    self.customView.layer.masksToBounds = NO;
    self.customView.layer.cornerRadius = 5;
    self.customView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.customView.layer.shadowRadius = 25;
    self.customView.layer.shadowOpacity = 0.5;
    
  //  [[IQKeyboardManager sharedManager] setEnable:YES];

//
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //
    //TextField Down Border Newpassword
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 2;
    border.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border.frame = CGRectMake(0, _pass.frame.size.height - borderWidth, _pass.frame.size.width, _pass.frame.size.height);
    border.borderWidth = borderWidth;
    [_pass.layer addSublayer:border];
    _pass.layer.masksToBounds = YES;
    //

    //TextField Down Border Current password
    CALayer *border1 = [CALayer layer];
    CGFloat borderWidth1 = 2;
    border1.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border1.frame = CGRectMake(0, _currentPasswordText.frame.size.height - borderWidth1, _currentPasswordText.frame.size.width, _currentPasswordText.frame.size.height);
    border1.borderWidth = borderWidth1;
    [_currentPasswordText.layer addSublayer:border1];
    _currentPasswordText.layer.masksToBounds = YES;
    //

    //TextField Down Border confirm Password
    CALayer *border2 = [CALayer layer];
    CGFloat borderWidth2 = 2;
    border2.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border2.frame = CGRectMake(0, _confirmPasswordText.frame.size.height - borderWidth2, _confirmPasswordText.frame.size.width, _confirmPasswordText.frame.size.height);
    border2.borderWidth = borderWidth2;
    [_confirmPasswordText.layer addSublayer:border2];
    _confirmPasswordText.layer.masksToBounds = YES;
    //


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveBtnClicked:(id)sender
{

    
    //Check blank String Current Password
    NSString *rawString = [self.currentPasswordText text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    
    if ( [trimmed length] == 0)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Current Password"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                    }];
        
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //Check blank String New Password
    NSString *rawString1 = [self.pass text];
    NSCharacterSet *whitespace1 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed1 = [rawString1 stringByTrimmingCharactersInSet:whitespace1];
    
    if ([trimmed1 length] == 0)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter New Password"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                    }];
        
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //Check blank String New Password
    NSString *rawString4 = [self.confirmPasswordText text];
    NSCharacterSet *whitespace4 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed4 = [rawString4 stringByTrimmingCharactersInSet:whitespace4];
    
    if ([trimmed4 length] == 0)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please enter confirm password."
                                     preferredStyle:UIAlertControllerStyleAlert];

        //Add Buttons

        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here

                                    }];


        //Add your buttons to alert controller

        [alert addAction:yesButton];

        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
 
    NSString *passwordRegex = @"^.*(?=.{8,})(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$!&]).*$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    
    if ([passwordTest evaluateWithObject:trimmed4] && [passwordTest evaluateWithObject:trimmed1]) {
        // Password must be at least 6 character, containing lowercase letter, one uppercase letter, digits, and special character (!@#$&)
        NSLog(@"fv");
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please Enter at least 8 characters and ensure that you have at least one lower case letter, one upper case letter, one digit and one special character."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    //Check blank String Confirm New Password
    NSString *rawString2 = [self.confirmPasswordText text];
    NSCharacterSet *whitespace2 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed2 = [rawString2 stringByTrimmingCharactersInSet:whitespace2];
    
    if ([trimmed2 length] == 0)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Confirm Password"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                    }];
        
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    if([self.pass.text isEqualToString: self.confirmPasswordText.text])
    {
        //Login after changing password
        
        [self startActivity:@"Processing.."];
        
        // Execute additional code
        NSString *post = [NSString stringWithFormat:@"CurrentPassword=%@&NewPassword=%@",_currentPasswordText.text,_confirmPasswordText.text];
        [WebserviceManager sendSyncRequestWithURL:kChangePassword method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
            
            if (status)
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   _changePasswordDictionary = [responseValue valueForKey:@"Response"];
                                   NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                                   if([isSuccessNumber boolValue] == YES)
                                   {
                                       NSNumber * ischangePassword = (NSNumber *)[responseValue valueForKey:@"Response"];
                                       if([ischangePassword boolValue] == YES)
                                       {
                                           
                                           [self stopActivity];

                                           UIAlertController * alert = [UIAlertController
                                                                        alertControllerWithTitle:@""
                                                                        message:@"Password changed successfully ."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                           //[[responseValue valueForKey:@"Messages"] objectAtIndex:0]
                                           //Add Buttons
                                           
                                           UIAlertAction* yesButton = [UIAlertAction
                                                                       actionWithTitle:@"Ok"
                                                                       style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           //Handle your yes please button action here
                                                                           
                                                                           //[self performSegueWithIdentifier:@"ChangePasswordLogin" sender:self];
                                                                           UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                           LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                                                           [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                                                       }];
                                           
                                           
                                           //Add your buttons to alert controller
                                           [alert addAction:yesButton];
                                           [self presentViewController:alert animated:YES completion:nil];
                                           
                                      }
                                       else
                                       {
                                           
                                       }
                                       
                                   }
                                   else{

                                       UIAlertController * alert = [UIAlertController
                                                                    alertControllerWithTitle:@""
                                                                    message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                       
                                       //Add Buttons
                                       
                                       UIAlertAction* yesButton = [UIAlertAction
                                                                   actionWithTitle:@"Ok"
                                                                   style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       //Handle your yes please button action here
                                                                       
                                                                   }];
                                       
                                       
                                       //Add your buttons to alert controller
                                       
                                       [alert addAction:yesButton];
                                       //[alert addAction:noButton];
                                       
                                       [self presentViewController:alert animated:YES completion:nil];
                                       [self stopActivity];
                                   }
                               });
            }
        }];
    }
    else
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Info"
                                     message:@"Confirm new password doesn't match with new password"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        //Add Buttons
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Handle your yes please button action here
                                        
                                    }];
        
        
        //Add your buttons to alert controller
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    

}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location > 0 && range.length == 1 && string.length == 0)
    {
        // Stores cursor position
        UITextPosition *beginning = textField.beginningOfDocument;
        UITextPosition *start = [textField positionFromPosition:beginning offset:range.location];
        NSInteger cursorOffset = [textField offsetFromPosition:beginning toPosition:start] + string.length;
        
        // Save the current text, in case iOS deletes the whole text
        NSString *text = textField.text;
        
        
        // Trigger deletion
        [textField deleteBackward];
        
        
        // iOS deleted the entire string
        if (textField.text.length != text.length - 1)
        {
            textField.text = [text stringByReplacingCharactersInRange:range withString:string];
            
            // Update cursor position
            UITextPosition *newCursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
            UITextRange *newSelectedRange = [textField textRangeFromPosition:newCursorPosition toPosition:newCursorPosition];
            [textField setSelectedTextRange:newSelectedRange];
        }
        
        return NO;
    }
    
    return YES;
}


- (IBAction)clearBtnClicked:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:Nil]; 
}

- (IBAction)secureEntryCurrentPass:(id)sender {
    if (_secureEntryCurrentPass.selected)
    {
        UIImage *btnImage = [UIImage imageNamed:@"hide-18.png"];
        [_secureEntryCurrentPass setImage:btnImage forState:UIControlStateNormal];
        _secureEntryCurrentPass.selected = NO;
        
        _currentPasswordText.secureTextEntry = YES;
        
        
        if (_currentPasswordText.isFirstResponder) {
            [_currentPasswordText resignFirstResponder];
            [_currentPasswordText becomeFirstResponder];
        }
    }
    else
    {
        UIImage *btnImage = [UIImage imageNamed:@"show-18.png"];
        [_secureEntryCurrentPass setImage:btnImage forState:UIControlStateNormal];
        _secureEntryCurrentPass.selected = YES;
        
        _currentPasswordText.secureTextEntry = NO;
        
        if (_currentPasswordText.isFirstResponder) {
            [_currentPasswordText resignFirstResponder];
            [_currentPasswordText becomeFirstResponder];
        }
        
    }

}

- (IBAction)secureEntryNewPass:(id)sender {
    if (_secureEntryNewPass.selected)
    {
        UIImage *btnImage = [UIImage imageNamed:@"hide-18.png"];
        [_secureEntryNewPass setImage:btnImage forState:UIControlStateNormal];
        _secureEntryNewPass.selected = NO;
        
        _pass.secureTextEntry = YES;
        
        
        if (_pass.isFirstResponder) {
            [_pass resignFirstResponder];
            [_pass becomeFirstResponder];
        }
    }
    else
    {
        UIImage *btnImage = [UIImage imageNamed:@"show-18.png"];
        [_secureEntryNewPass setImage:btnImage forState:UIControlStateNormal];
        _secureEntryNewPass.selected = YES;
        
        _pass.secureTextEntry = NO;
        
        if (_pass.isFirstResponder) {
            [_pass resignFirstResponder];
            [_pass becomeFirstResponder];
        }
        
    }

}

- (IBAction)secureEntryConfirmPass:(id)sender {
    if (_secureEntryConfirmPass.selected)
    {
        UIImage *btnImage = [UIImage imageNamed:@"hide-18.png"];
        [_secureEntryConfirmPass setImage:btnImage forState:UIControlStateNormal];
        _secureEntryConfirmPass.selected = NO;
        
        _confirmPasswordText.secureTextEntry = YES;
        
        
        if (_confirmPasswordText.isFirstResponder) {
            [_confirmPasswordText resignFirstResponder];
            [_confirmPasswordText becomeFirstResponder];
        }
    }
    else
    {
        UIImage *btnImage = [UIImage imageNamed:@"show-18.png"];
        [_secureEntryConfirmPass setImage:btnImage forState:UIControlStateNormal];
        _secureEntryConfirmPass.selected = YES;
        
        _confirmPasswordText.secureTextEntry = NO;
        
        if (_confirmPasswordText.isFirstResponder) {
            [_confirmPasswordText resignFirstResponder];
            [_confirmPasswordText becomeFirstResponder];
        }
        
    }

}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
