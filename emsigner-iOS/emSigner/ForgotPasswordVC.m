//
//  ForgotPasswordVC.m
//  emSigner
//
//  Created by Administrator on 9/22/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "ForgotPasswordVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "Reachability.h"
#import "IQKeyboardManager.h"

#import "RPFloatingPlaceholderTextField.h"
#import "RPFloatingPlaceholderTextView.h"

@interface ForgotPasswordVC ()

@end

@implementation ForgotPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[IQKeyboardManager sharedManager] setEnable:YES];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissViewController)];
    
    self.navigationItem.leftBarButtonItem = customBarButtonItem;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.Captcha_field.layer.cornerRadius = 5;
    self.emailText.layer.cornerRadius = 5;
    self.Captcha_label.layer.cornerRadius = 5;
    self.Status_label.layer.cornerRadius = 5;
    _Captcha_label.clipsToBounds = YES;
    _Status_label.clipsToBounds = YES;
    self.submitBtnPressed.layer.cornerRadius = 5;
    self.cancelBtnPressed.layer.cornerRadius = 5;
    //
    
    [_Captcha_label setFont:[UIFont fontWithName:@"American Typewriter" size:40]];

    
    ar1 = [[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    
    /*****************************Card View*********************************/
    [self.customView setAlpha:1];
    self.customView.layer.masksToBounds = NO;
    self.customView.layer.cornerRadius = 5;
    self.customView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.customView.layer.shadowRadius = 25;
    self.customView.layer.shadowOpacity = 0.5;
   
    
}

- (void)viewWillLayoutSubviews
{
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border.frame = CGRectMake(0, _emailText.frame.size.height - borderWidth, _emailText.frame.size.width, _emailText.frame.size.height);
    border.borderWidth = borderWidth;
    [_emailText.layer addSublayer:border];
    _emailText.layer.masksToBounds = YES;
    //
    CALayer *border1 = [CALayer layer];
    CGFloat borderWidth1 = 1;
    border1.borderColor =  ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border1.frame = CGRectMake(0, _Captcha_field.frame.size.height - borderWidth1, _Captcha_field.frame.size.width, _Captcha_field.frame.size.height);
    border1.borderWidth = borderWidth1;
    [_Captcha_field.layer addSublayer:border1];
    _Captcha_field.layer.masksToBounds = YES;
    
    //TextField Down Border
    CALayer *bborder = [CALayer layer];
    CGFloat bborderWidth = 0.25;
    bborder.borderColor = [UIColor colorWithRed:211.0/255.0 green:211.0/255.0 blue:211.0/255.0 alpha:1.0].CGColor;
    bborder.frame = CGRectMake(0, _forgotPasswordLabel.frame.size.height - bborderWidth, _forgotPasswordLabel.frame.size.width, _forgotPasswordLabel.frame.size.height);
    bborder.borderWidth = bborderWidth;
    [_forgotPasswordLabel.layer addSublayer:bborder];
    _forgotPasswordLabel.layer.masksToBounds = YES;
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    [self reload_captcha];
    [_Captcha_field becomeFirstResponder];
    [_emailText becomeFirstResponder];
    
    [super viewWillAppear:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [_Captcha_field resignFirstResponder];
         [_emailText resignFirstResponder];
    }
}

-(void)reload_captcha{

        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        _Captcha_label.backgroundColor = color;
        
    
    uint8_t randomBytes[16];
    int result = SecRandomCopyBytes(kSecRandomDefault, 16, randomBytes);
    if(result == 0) {
        NSMutableString *uuidStringReplacement = [[NSMutableString alloc] initWithCapacity:16*2];
        for(NSInteger index = 0; index < 2; index++)
        {
            [uuidStringReplacement appendFormat: @"%x", randomBytes[index]];
            _Captcha_label.text = uuidStringReplacement;
        }
        NSLog(@"uuidStringReplacement is %@", uuidStringReplacement);
        
    } else {
        NSLog(@"SecRandomCopyBytes failed for some reason");
    }
    
}

- (IBAction)reloadBtnPressed:(id)sender
{
    [self reload_captcha];
}


-(void)dismissKeyboard
{
    [_emailText resignFirstResponder];
    [_Captcha_field resignFirstResponder];
   // [_customCaptchaText resignFirstResponder];
}

-(BOOL)IsValidEmail:(NSString *)checkString
{
    BOOL isvalidate;
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    //Valid email address
    
    if ([emailTest evaluateWithObject:checkString] == YES)
    {
        isvalidate = YES;
        //Do Something
    }
    else
    {
        isvalidate = NO;
        
    }
    return isvalidate;
}

-(void)dismissViewController{
    [self dismissViewControllerAnimated:true completion:nil];
}



- (IBAction)submitBtnPressed:(id)sender
{
    NSLog(@"%@ = %@",_Captcha_label.text,_Captcha_field.text);
    
    //Check blank String Email
    NSString *rawString1 = [self.emailText text];
    NSCharacterSet *whitespace1 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed1 = [rawString1 stringByTrimmingCharactersInSet:whitespace1];
    
    if ( [trimmed1 length] == 0)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please enter Email"
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

    if (![self IsValidEmail:[self.emailText text]])
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please enter valid Email Id"
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
    
    
    //Check blank String Captcha
    NSString *rawString = [self.Captcha_field text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    
    if ( [trimmed length] == 0)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Captcha"
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
    
    
     if(![_Captcha_label.text isEqualToString: _Captcha_field.text])
     {
         UIAlertController * alert = [UIAlertController
                                                                            alertControllerWithTitle:@""
                                                                               message:@"Captcha invalid,Please try again"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                                      
                                                  //Add Buttons
                                      
                                                  UIAlertAction* yesButton = [UIAlertAction
                                                                              actionWithTitle:@"Ok"
                                                                              style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {
                                                                                  //Handle your yes please button action here
                                                                                  [self reload_captcha];
                                                                              }];
                                                  
                                                  //Add your buttons to alert controller
                                                  
                                                  [alert addAction:yesButton];
                                                  
                                                  [self presentViewController:alert animated:YES completion:nil];
         return;

     }
    [self.view endEditing:YES];
    
    //
                /*************************Web Service Get OTP*******************************/
    
                [self startActivity:@"Processing.."];
                NSString *requestURL = [NSString stringWithFormat:@"%@ForgotPassword?emailId=%@",kForgotPassword,[self.emailText text]];
    
                [WebserviceManager sendSyncRequestWithURLForgotPassword:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
    
                   // if(status)
                        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                    {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           _forgotPasswordArray =responseValue;
    
                                            NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                                           if([isSuccessNumber boolValue] == YES)
                                           {
                                              // [self performSegueWithIdentifier:@"Forgot Password" sender:sender];
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
                                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                                           }];
                                               
                                               //Add your buttons to alert controller
                                               
                                               [alert addAction:yesButton];
                                               //[alert addAction:noButton];
                                               
                                               [self presentViewController:alert animated:YES completion:nil];
                                               [self stopActivity];
                                           }
                                           else{
                                          //     [self performSegueWithIdentifier:@"Forgot Password" sender:sender];
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
                                                                               [self dismissViewControllerAnimated:YES completion:nil];
                                                                           }];
                                               
                                               //Add your buttons to alert controller
                                               
                                               [alert addAction:yesButton];
                                               //[alert addAction:noButton];
                                               
                                               [self presentViewController:alert animated:YES completion:nil];
                                               [self stopActivity];

                                           }
    
                                       });
    
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
                                                        [self dismissViewControllerAnimated:YES completion:nil];
                                                    }];
                        
                        
                        //Add your buttons to alert controller
                        
                        [alert addAction:yesButton];
                        //[alert addAction:noButton];
                        [self stopActivity];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                }];
                /****************************************************************/
    
//
    }
   


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _Captcha_field) {
        NSInteger lengtha = [_Captcha_field.text length];
        if (lengtha >= 5 && ![string isEqualToString:@""]) {
            _Captcha_field.text = [_Captcha_field.text substringToIndex:5];
            return NO;
        }
        return YES;
    } else if (textField == _emailText) {
        NSInteger lengthb = [_emailText.text length];
        if (lengthb >= 50 && ![string isEqualToString:@""]) {
            _emailText.text = [_emailText.text substringToIndex:50];
            return NO;
        }
        return YES;
    }
    return YES;
}

- (IBAction)cancelBtnPressed:(id)sender
{
   // [self performSegueWithIdentifier:@"Forgot Password" sender:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_emailText resignFirstResponder];
    [_Captcha_field resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
