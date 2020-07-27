
//
//  ViewController.m
//  emSigner
//
//  Created by Administrator on 7/12/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "Connection.h"
#import "RPFloatingPlaceholderTextField.h"
#import "RPFloatingPlaceholderTextView.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <MSAL/MSAL.h>
#import "HomeNewDashBoardVC.h"
//#import "emSigner-Bridging-Header.h"
#import "emSigner-Swift.h"
#import "LMNavigationController.h"

@interface ViewController ()
{
    UIPageControl *pageControl;
    UIScrollView *scroll;
    MBProgressHUD *HUD;
    BOOL hasPresentedAlert;
    int i;
    ViewController* view;
    
}
//@property (weak, nonatomic) IBOutlet UITabBar *scanTabBar;

@property (nonatomic, strong) UITextView *forgotPasswordTextView;
@property(strong,nonatomic) swiftController *cntroller;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    _captchaView.hidden = YES;
    self.loginBtnTop.constant = 0;
   
    self.captchaViewHeight.constant = 0;

    /**************Hide IntialView****************/
    self.initialView.hidden = YES;
    
    /********************************Disable keyboard**********************************/
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
   
}
    

    
- (void)viewWillLayoutSubviews
{
    //TextField Down Border
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border.frame = CGRectMake(0, _mEmail.frame.size.height - borderWidth, _mEmail.frame.size.width, _mEmail.frame.size.height);
    border.borderWidth = borderWidth;
    [_mEmail.layer addSublayer:border];
    _mEmail.layer.masksToBounds = YES;
    //
    CALayer *border1 = [CALayer layer];
    CGFloat borderWidth1 = 1;
    border1.borderColor =  ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border1.frame = CGRectMake(0, _mPassword.frame.size.height - borderWidth1, _mPassword.frame.size.width, _mPassword.frame.size.height);
    border1.borderWidth = borderWidth1;
    [_mPassword.layer addSublayer:border1];
    _mPassword.layer.masksToBounds = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.parentView endEditing:YES];// this will do the trick
}


-(void)reload_captcha{
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
            CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
            CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
            UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
            _customCaptchalable.backgroundColor = color;
    
    uint8_t randomBytes[16];
    int result = SecRandomCopyBytes(kSecRandomDefault, 16, randomBytes);
    if(result == 0) {
        NSMutableString *uuidStringReplacement = [[NSMutableString alloc] initWithCapacity:16*2];
        for(NSInteger index = 0; index < 2; index++)
        {
            [uuidStringReplacement appendFormat: @"%x", randomBytes[index]];
            
            _customCaptchalable.text = uuidStringReplacement;

        }
        NSLog(@"uuidStringReplacement is %@", uuidStringReplacement);
    } else {
        NSLog(@"SecRandomCopyBytes failed for some reason");
    }
    
}


-(void)dismissKeyboard
{
    [_mEmail resignFirstResponder];
    [_mPassword resignFirstResponder];
    [_customCaptchaText resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Network Connection Checks
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[textField bs_hideError];
    svos = _loginScrollView.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:_loginScrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 90;
    [_loginScrollView setContentOffset:pt animated:YES];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_loginScrollView setContentOffset:svos animated:YES];
    [_mPassword addTarget:self action:@selector(textFieldDidReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
    //[textField resignFirstResponder];
    return YES;
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

- (IBAction)loginOffice365:(id)sender {
    
   // [self startActivity:@""];
    UIViewController *theRootVC;

   NSOperatingSystemVersion ios13 = (NSOperatingSystemVersion){13, 0, 1};
     if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios13]) {
        // iOS 13 and above logic
         _cntroller = [[swiftController alloc]init];
         _cntroller.view.backgroundColor = [UIColor whiteColor];
         _cntroller.modalPresentationStyle = UIModalPresentationFullScreen;
         [self presentViewController:_cntroller animated:YES completion:nil];

     } else {
        // below logic
         _cntroller = [[swiftController alloc]init];
         _cntroller.view.backgroundColor = [UIColor whiteColor];
         _cntroller.initForGraph;
     }
    
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
        //NSLog(@"email not in proper format");
    }
    return isvalidate;
}


- (IBAction)mLoginBtn:(id)sender
{
    [self loginWithLoginBtn:@""];
}

-(void)loginWithLoginBtn:(NSString*)email
{
    // mPassword
    
    NSLog(@"%@",_mPassword.text);
    [[NSUserDefaults standardUserDefaults] setObject:_mPassword.text forKey:@"changePass"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissKeyboard];
    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            
            // not connected to network
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"No internet connection!"
                                         message:@"Check internet connection!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Okay"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            
                                        }];
            
            
            //Add your buttons to alert controller
            
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            hasPresentedAlert = true;
            
        }
    }
    
    /*******************Check blank email**********************************/
    if ([self.mEmail.text length]==0)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Email"
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
        
        
        self.captchaViewHeight.constant = 0;
        self.loginBtnTop.constant = 0;
        return;
    }
    
    /*******************Check blank password**********************************/
    if ([self.mPassword.text length]==0)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Password"
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
        
        self.captchaViewHeight.constant = 0;
        self.loginBtnTop.constant = 0;
        return;
    }

    /***********************************************************************/
    else
    {
        
        if (i >= 2)
        {
            self.captchaViewHeight.constant = 64;
            self.loginBtnTop.constant = 64
            ;
            _captchaView.hidden = NO;
            NSLog(@"%@ = %@",_customCaptchalable.text,_customCaptchaText.text);
            if(![_customCaptchalable.text isEqualToString: _customCaptchaText.text])
            {
                /************************Refreshing Captcha*****************************/
                
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@""
                                             message:@"Invalid Captcha"
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
                [self reload_captcha];
            }
            else{
                [self reload_captcha];
                
                [self startActivity:@""];
                
                // Login
                NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",self.mEmail.text,self.mPassword.text];
                
                
                [WebserviceManager sendSyncRequestWithURLLogin:kLoginUrl method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
                    
                    if (status) {
                        NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                        if([isSuccessNumber boolValue] == YES)
                        {
                            _responseDictionary = [responseValue valueForKey:@"Response"];
                            NSNumber * isUpdatedPassword = (NSNumber *)[_responseDictionary valueForKey:@"IsPasswordUpdated"];
                            if ([isUpdatedPassword boolValue] == YES)
                            {
                                dispatch_async(dispatch_get_main_queue(),
                                               ^{
                                                   [self dismissKeyboard];

                                                   if ((_checkBoxBtn.isOn) == YES) {
                                                       //Saving Email
                                                       NSString *email = self.mEmail.text;
                                                       [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                       
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       //
                                                       AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                       theDelegate.isLoggedIn = YES;
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                       [self loadDashBoard];
                                                   }
                                                   
                                                   //Saving token
                                                   else{
                                                       //Saving token
                                                       
                                                       NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                                       
                                                       [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkBox"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       //
                                                       NSString *email = self.mEmail.text;
                                                       [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       //
                                                       AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                       theDelegate.isLoggedIn = YES;
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                      //[self performSegueWithIdentifier:@"Login" sender:self];
                                                       
                                                       UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                       LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                                       [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                                       [self stopActivity];
                                                   }
                                               });
                            }
                              else
                                                     {
                                                         dispatch_async(dispatch_get_main_queue(),
                                                                        ^{
                                                                           // [self ];
                                                                            //Saving token
                                                                            NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                                                            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                                                            //
                                                                            
                                                                            [self performSegueWithIdentifier:@"Change Password" sender:self];
                                                                            
                                                                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                            LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"ChangePasswordVC"];
                                                                            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                                                            [self stopActivity];
                                                                        });
                                                     }
                                                     
                                                     
                                                 }
                        
                        else{
                           
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               
                                               UIAlertController * alert = [UIAlertController
                                                                            alertControllerWithTitle:@""
                                                                            message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                               
                                               //Add Buttons
                                               
                                               UIAlertAction* yesButton = [UIAlertAction
                                                                           actionWithTitle:@"Ok"
                                                                           style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action) {
                                                                               
                                                                           }];
                                               
                                               //Add your buttons to alert controller
                                               
                                               [alert addAction:yesButton];
                                               [self presentViewController:alert animated:YES completion:nil];
                                               [self stopActivity];
                                           });
                        }
                        
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           
                                           UIAlertController * alert = [UIAlertController
                                                                        alertControllerWithTitle:@""
                                                                        message:@"Login unsuccessful"
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
                                           
                                           [self stopActivity];
                                           
                                       });
                    }
                }];
            }
        }
        
        /*************************Without Captca**********************************/
        else
        {
            
            [self startActivity:@""];
            
            // Login
            NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",self.mEmail.text,self.mPassword.text];
            [WebserviceManager sendSyncRequestWithURLLogin:kLoginUrl method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
                
                if (status) {
                    int   issucess = [[responseValue valueForKey:@"IsSuccess"]intValue];
                    
                    if (issucess != 0) {
                        
                        NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                        if([isSuccessNumber boolValue] == YES)
                        {
                            
                            _responseDictionary = [responseValue valueForKey:@"Response"];
                            NSNumber * isUpdatedPassword = (NSNumber *)[_responseDictionary valueForKey:@"IsPasswordUpdated"];
                            if ([isUpdatedPassword boolValue] == YES)
                            {
                                dispatch_async(dispatch_get_main_queue(),
                                               ^{
                                                   if ((_checkBoxBtn.isOn) == YES) {
                                                       
                                                       [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"checkBox"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       
                                                       //Saving Email
                                                       NSString *email = self.mEmail.text;
                                                       [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       
                                                       [self loadDashBoard];
                                                   }
                                                   //
                                                   else{
                                                       //Saving token
                                                       
                                                       NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                                       [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                                       
                                                       [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkBox"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       //
                                                       NSString *email = self.mEmail.text;
                                                       [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       //
                                                       AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                       theDelegate.isLoggedIn = YES;
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                       
                                                       UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                       LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                                       [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                                   }
                                               });
                            }
                            
                            else
                            {
                                           dispatch_async(dispatch_get_main_queue(),
                                                          ^{
                                                          NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                                                                                                                         [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                                                                                                                         [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                                                                         //
                                                                                                                                         
                                                                                                                                         [self performSegueWithIdentifier:@"Change Password" sender:self];
                                                                                                                                         
                                                                                                                                         UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                                                                                         LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"ChangePasswordVC"];
                                                                                                                                         [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                                                                                                                         [self stopActivity];

                                                              [self stopActivity];
                                                              
                                                          });
                                           
                                       }
                                   }
                        
                        else{
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               i++;
                                               
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
                                               [self presentViewController:alert animated:YES completion:nil];
                                               [self stopActivity];
                                           });
                        }
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           i++;
                                           UIAlertController * alert = [UIAlertController
                                                                        alertControllerWithTitle:@""
                                                                        message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                                           
                                           //Add Buttons
                                           
                                           UIAlertAction* yesButton = [UIAlertAction
                                                                       actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           //Handle your yes please button action here
                                                                           
                                                                       }];
                                           
                                           //Add your buttons to alert controller
                                           
                                           [alert addAction:yesButton];
                                           [self presentViewController:alert animated:YES completion:nil];
                                           [self stopActivity];
                                       });
                        
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       UIAlertController * alert = [UIAlertController
                                                                    alertControllerWithTitle:@""
                                                                    message:@"Login Failed"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                       
                                       //Add Buttons
                                       
                                       UIAlertAction* yesButton = [UIAlertAction
                                                                   actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       //Handle your yes please button action here
                                                                       
                                                                   }];
                                       
                                       //Add your buttons to alert controller
                                       
                                       [alert addAction:yesButton];
                                       
                                       [self presentViewController:alert animated:YES completion:nil];
                                       
                                       [self stopActivity];
                                   });
                    
                }
                
            }];
            
        }
        
    }
}


-(void)loginWithOffice365:(NSString*)email
{
    
    [self startActivity:@""];
    
    // Login
    NSString *post = [NSString stringWithFormat:@"UserName=%@&Password=%@",email,@"office365~emudhra"];
    [WebserviceManager sendSyncRequestWithURLLogin:kLoginUrl method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
        
        if (status) {
            int   issucess = [[responseValue valueForKey:@"IsSuccess"]intValue];
            
            if (issucess != 0) {
                NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                if([isSuccessNumber boolValue] == YES)
                {
                    
                    _responseDictionary = [responseValue valueForKey:@"Response"];
                    NSNumber * isUpdatedPassword = (NSNumber *)[_responseDictionary valueForKey:@"IsPasswordUpdated"];
                    if ([isUpdatedPassword boolValue] == YES)
                    {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{

                                           if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"checkBox"]  isEqual: @"YES"]) {

                                               [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"checkBox"];
                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                               
                                               //Saving Email
                                               [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                               
                                               [self loadDashBoard];
                                           }
                                           //
                                           else{
                                               //Saving token
                                               
                                               NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                               [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                               
                                               [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkBox"];
                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                               //
                                               [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                               [[NSUserDefaults standardUserDefaults] synchronize];
                                               //
                                               AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                               theDelegate.isLoggedIn = YES;
                                               [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];

                                               UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                               [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];

                                           }
                                       });
                    }
                    else
                    {
                      dispatch_async(dispatch_get_main_queue(),
                                                           ^{

                                                               if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"checkBox"]  isEqual: @"YES"]) {

                                                                   [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"checkBox"];
                                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                                   
                                                                   //Saving Email
                                                                   [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                                   
                                                                   [self loadDashBoard];
                                                               }
                                                               //
                                                               else{
                                                                   //Saving token
                                                                   
                                                                   NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                                                   [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                                                   
                                                                   [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkBox"];
                                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                                   //
                                                                   [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                                   //
                                                                   AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                                   theDelegate.isLoggedIn = YES;
                                                                   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];

                                                                   UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                    LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                                                   [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];

                                                               }
                                                           });
                         
                                       }
                                   }
                
                else{
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       i++;
                        
                                       UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                             handler:^(UIAlertAction * action) {
                                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                             }];
                                       [alert addAction:defaultAction];
                                      [[[[UIApplication sharedApplication] keyWindow] rootViewController ] presentViewController:alert animated:true completion:nil];
                                        
                                       [self stopActivity];
                                   });
                     
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(),
                               ^{
                                   i++;
                                   [self stopActivity];
                                   UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] preferredStyle:UIAlertControllerStyleAlert];
                                   UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                         handler:^(UIAlertAction * action) {
                                                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                         }];
                                   [alert addAction:defaultAction];
                                  [[[[UIApplication sharedApplication] keyWindow] rootViewController ] presentViewController:alert animated:true completion:nil];

                               });
                
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               UIAlertController * alert = [UIAlertController
                                                            alertControllerWithTitle:@""
                                                            message:@"Login Failed"
                                                            preferredStyle:UIAlertControllerStyleAlert];
                               
                               //Add Buttons
                               
                               UIAlertAction* yesButton = [UIAlertAction
                                                           actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               //Handle your yes please button action here
                                                               
                                                           }];
                               
                               //Add your buttons to alert controller
                               
                               [alert addAction:yesButton];
                             [[[[UIApplication sharedApplication] keyWindow] rootViewController ] presentViewController:alert animated:true completion:nil];
                               
                               [self stopActivity];
                           });
             
        }
        
    }];
    
}

-(void)loadDashBoard
{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Please use secure Biometric for Authentication";

    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    _isFingerPrintDone = YES;
                                    
                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_isFingerPrintDone] forKey:@"FingerPrintDone"];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //Saving token
                                        NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                        //
                                        AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                        theDelegate.isLoggedIn = YES;
                                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                        
                                        //[self performSegueWithIdentifier:@"Login" sender:self];
                                        
                                        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                        LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                        
                                        [self stopActivity];
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authentication Error"
                                                                                            message:authError.localizedDescription
                                                                                           delegate:self
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil, nil];
                                        [alertView show];
                                    });
                                }
                            }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{

            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:authError.localizedDescription
                                         message:@"If you want to use Touch ID & Passcode feature,please go to settings and do enable."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            //Logout
                                            
                                            //Saving token
//                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                //Saving token
                                                NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                                [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                //
                                                [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkBox"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                theDelegate.isLoggedIn = NO;
                                                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                [self stopActivity];
                                            
                                        }];
            
            [alert addAction:yesButton];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController ] presentViewController:alert animated:true completion:nil];
             [self stopActivity];
            
            // Rather than show a UIAlert here, use the error to determine if you should push to a keypad for PIN entry.
        });
    }
    
}


- (void)textFieldDidReturn:(UITextField *)textField
{
    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            
            // not connected to network
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"No internet connection!"
                                         message:@"Check internet connection!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Okay"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            
                                        }];
            
            
            //Add your buttons to alert controller
            
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            hasPresentedAlert = true;
            
        }
    }
    
    /*******************Check blank email**********************************/
    if ([self.mEmail.text length]==0)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Email"
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
        
        
        self.captchaViewHeight.constant = 0;
        self.loginBtnTop.constant = 0;
        return;
    }
    
    /*******************Check blank password**********************************/
    if ([self.mPassword.text length]==0)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Password"
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
        
        self.captchaViewHeight.constant = 0;
        self.loginBtnTop.constant = 0;
        return;
    }
    
    
    
    /***********************************************************************/
    else
    {
        
        if (i >= 2)
        {
            self.captchaViewHeight.constant = 64;
            self.loginBtnTop.constant = 64
            ;
            _captchaView.hidden = NO;
            NSLog(@"%@ = %@",_customCaptchalable.text,_customCaptchaText.text);
            if(![_customCaptchalable.text isEqualToString: _customCaptchaText.text])
            {
                /************************Refreshing Captcha*****************************/
                
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@""
                                             message:@"Invalid Captcha"
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
                [self reload_captcha];
            }
            else{
                [self reload_captcha];
                
                [self startActivity:@""];
                
                // Login
                NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",self.mEmail.text,self.mPassword.text];
                [WebserviceManager sendSyncRequestWithURLLogin:kLoginUrl method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
                    
                    if (status) {
                        NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                        if([isSuccessNumber boolValue] == YES)
                        {
                            _responseDictionary = [responseValue valueForKey:@"Response"];
                            NSNumber * isUpdatedPassword = (NSNumber *)[_responseDictionary valueForKey:@"IsPasswordUpdated"];
                            if ([isUpdatedPassword boolValue] == YES)
                            {
                                dispatch_async(dispatch_get_main_queue(),
                                               ^{
                                                   if ((_checkBoxBtn.isOn) == YES) {
                                                       //Saving Email
                                                       NSString *email = self.mEmail.text;
                                                       [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                       //
                                                       AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                       theDelegate.isLoggedIn = YES;
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                       //
                                                       [self loadDashBoard];
                                                   }
                                                   
                                                   if ([[[responseValue valueForKey:@"Messages"] objectAtIndex:0] isEqualToString:@"Please Enter Valid EmailID And Password"]) {
                                                       //Logout
                                                       AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                       theDelegate.isLoggedIn = NO;
                                                       [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                       [NSUserDefaults resetStandardUserDefaults];
                                                       [NSUserDefaults standardUserDefaults];
                                                       UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                       ViewController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ViewController"];
                                                       [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                                       
                                                   }
                                                   
                                                   //Saving token
                                                   NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                                   [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   
                                                   
                                                 //  [self performSegueWithIdentifier:@"Login" sender:self];
                                                   [self stopActivity];
                                               });
                            }
                            else
                           {
                                           dispatch_async(dispatch_get_main_queue(),
                                                          ^{
                                                              i++;
                                                              
                                                              UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] preferredStyle:UIAlertControllerStyleAlert];
                                                              UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                                                    handler:^(UIAlertAction * action) {
                                                                                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                    }];
                                                              [alert addAction:defaultAction];
                                                              UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                              alertWindow.rootViewController = [[UIViewController alloc] init];
                                                              alertWindow.windowLevel = UIWindowLevelAlert + 1;
                                                              [alertWindow makeKeyAndVisible];
                                                              [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];

                                                              [self stopActivity];
                                                              
                                                          });
                                           
                                       }
                                   }
                        
                        else{
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               
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
                                               [self presentViewController:alert animated:YES completion:nil];
                                               [self stopActivity];
                                           });
                        }
                        
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           
                                           UIAlertController * alert = [UIAlertController
                                                                        alertControllerWithTitle:@""
                                                                        message:@"Login unsuccessful"
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
                                           
                                           [self stopActivity];
                                       });
                        
                    }
                    
                }];
                
            }
            
            
        }
        
        
        
        
        
        /***********************************************************/
        else
        {
            
            [self startActivity:@""];
            
            // Login
            NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",self.mEmail.text,self.mPassword.text];
            [WebserviceManager sendSyncRequestWithURLLogin:kLoginUrl method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
                
                if (status) {
                    NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                    if([isSuccessNumber boolValue] == YES)
                    {
                        
                        _responseDictionary = [responseValue valueForKey:@"Response"];
                        NSNumber * isUpdatedPassword = (NSNumber *)[_responseDictionary valueForKey:@"IsPasswordUpdated"];
                        if ([isUpdatedPassword boolValue] == YES)
                        {
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                              

                                               if ((_checkBoxBtn.isOn) == YES) {
                                                   //Saving Email
                                                   NSString *email = self.mEmail.text;
                                                   [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   //
                                                   AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                   theDelegate.isLoggedIn = YES;
                                                   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                   //
                                                   [self loadDashBoard];
                                               }
                                               else
                                               {
                                                   NSString *token = [_responseDictionary valueForKey:@"AuthToken"];
                                                   [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"Token"];
                                                   
                                                   [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkBox"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   //
                                                   NSString *email = self.mEmail.text;
                                                   [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"Email"];
                                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                                   //
                                                   AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                   theDelegate.isLoggedIn = YES;
                                                   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                  // [self performSegueWithIdentifier:@"Login" sender:self];
                                                   
                                                   UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                   LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                                   [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                                   [self stopActivity];

                                               }
                                           
                                           });
                        }
                        
                        
                        else
                        {
                                       dispatch_async(dispatch_get_main_queue(),
                                                      ^{
                                                        
                                                          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] preferredStyle:UIAlertControllerStyleAlert];
                                                          UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                                                handler:^(UIAlertAction * action) {
                                                                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                }];
                                                          [alert addAction:defaultAction];
                                                          UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                          alertWindow.rootViewController = [[UIViewController alloc] init];
                                                          alertWindow.windowLevel = UIWindowLevelAlert + 1;
                                                          [alertWindow makeKeyAndVisible];
                                                          [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];

                                                          [self stopActivity];
                                                          
                                                      });
                                       
                                   }
                               }
                    
                    
                    else{
                        dispatch_async(dispatch_get_main_queue(),
                                       ^{
                                           i++;
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
                                           [self presentViewController:alert animated:YES completion:nil];
                                           [self stopActivity];
                                       });
                    }
                    
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                       theDelegate.isLoggedIn = NO;

                                       UIAlertController * alert = [UIAlertController
                                                                    alertControllerWithTitle:@""
                                                                    message:@"Login Failed"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                                       
                                       //Add Buttons
                                       
                                       UIAlertAction* yesButton = [UIAlertAction
                                                                   actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {
                                                                       //Handle your yes please button action here
                                                                       
                                                                   }];
                                       
                                       //Add your buttons to alert controller
                                       
                                       [alert addAction:yesButton];
                                       
                                       [self presentViewController:alert animated:YES completion:nil];
                                       
                                       [self stopActivity];
                                   });
                    
                }
                
            }];
            
        }
        
    }
    
    
}


- (IBAction)checkBoxBtn:(id)sender
{
    if (self.checkBoxBtn.isOn) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"checkBox"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkBox"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (IBAction)forgotPassword:(id)sender
{
   
    //Network Check
    if (![self connected])
    {
        if(hasPresentedAlert == false){
            
            // not connected to network
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"No internet connection!"
                                         message:@"Check internet connection!"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Okay"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //Handle your yes please button action here
                                            
                                        }];
            
            
            //Add your buttons to alert controller
            
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            hasPresentedAlert = true;
            
        }
        return;
    }
    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ForgotPasswordVC *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ForgotPasswordVC"];
    self.definesPresentationContext = YES; //self is presenting view controller
    objTrackOrderVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:objTrackOrderVC animated:YES completion:nil];
}

- (IBAction)captchaRefreshBtn:(id)sender
{
    [self reload_captcha];
}

- (IBAction)secureEntryBtn:(id)sender {
    if (_secureEntryBtn.selected)
    {
        UIImage *btnImage = [UIImage imageNamed:@"hide-18.png"];
        [_secureEntryBtn setImage:btnImage forState:UIControlStateNormal];
        _secureEntryBtn.selected = NO;
        
        _mPassword.secureTextEntry = YES;
        
        
        if (_mPassword.isFirstResponder) {
            [_mPassword resignFirstResponder];
            [_mPassword becomeFirstResponder];
        }
    }
    else
    {
        UIImage *btnImage = [UIImage imageNamed:@"show-18.png"];
        [_secureEntryBtn setImage:btnImage forState:UIControlStateNormal];
        _secureEntryBtn.selected = YES;
        
        _mPassword.secureTextEntry = NO;
        
        if (_mPassword.isFirstResponder) {
            [_mPassword resignFirstResponder];
            [_mPassword becomeFirstResponder];
        }
}
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Email"]) {
        textView.text = @"";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    
    [textView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}


@end
