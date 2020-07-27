//
//  FeedbackVC.m
//  emSigner
//
//  Created by Administrator on 5/23/17.
//  Copyright © 2017 Emudhra. All rights reserved.
//

#import "FeedbackVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
@interface FeedbackVC ()

@end

@implementation FeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cancelBtnPressed.layer.cornerRadius = 10;
    self.sendBtnClicked.layer.cornerRadius = 10;
    self.messageTextView.layer.cornerRadius = 10;
    
    //TextField Down Border
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 2;
    border.borderColor = ([UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor);
    border.frame = CGRectMake(0, _feedbackLable.frame.size.height - borderWidth, _feedbackLable.frame.size.width, _feedbackLable.frame.size.height);
    border.borderWidth = borderWidth;
    [_feedbackLable.layer addSublayer:border];
    _feedbackLable.layer.masksToBounds = YES;
    
    
    _messageTextView.layer.borderWidth = 0.2;
    _messageTextView.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor;
   
    /*****************************Card View*********************************/
    [self.customView setAlpha:1];
    self.customView.layer.masksToBounds = NO;
    self.customView.layer.cornerRadius = 10;
    self.customView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.customView.layer.shadowRadius = 25;
    self.customView.layer.shadowOpacity = 0.5;
    
    //Firstname Down Border
    CALayer *border1 = [CALayer layer];
    CGFloat borderWidth1 = 1;
    border1.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border1.frame = CGRectMake(0, _firstNameText.frame.size.height - borderWidth1, _firstNameText.frame.size.width, _firstNameText.frame.size.height);
    border1.borderWidth = borderWidth1;
    [_firstNameText.layer addSublayer:border1];
    _firstNameText.layer.masksToBounds = YES;
    //
    
    //Lastname Down Border
    CALayer *border2 = [CALayer layer];
    CGFloat borderWidth2 = 1;
    border2.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border2.frame = CGRectMake(0, _lastNameText.frame.size.height - borderWidth2, _lastNameText.frame.size.width, _lastNameText.frame.size.height);
    border2.borderWidth = borderWidth2;
    [_lastNameText.layer addSublayer:border2];
    _lastNameText.layer.masksToBounds = YES;
    //
    
    //Email Down Border
    CALayer *border3 = [CALayer layer];
    CGFloat borderWidth3 = 1;
    border3.borderColor = ([UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor);
    border3.frame = CGRectMake(0, _emailText.frame.size.height - borderWidth3, _emailText.frame.size.width, _emailText.frame.size.height);
    border3.borderWidth = borderWidth3;
    [_emailText.layer addSublayer:border3];
    _emailText.layer.masksToBounds = YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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


- (IBAction)sendBtnClicked:(id)sender
{
    
    //Check blank String FirstName
    NSString *rawString = [self.firstNameText text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    
    if ([trimmed length] == 0)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter FirstName"
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
    //Check  FirstName Validation
    
    if (![self validate:[self.firstNameText text]])
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"First Name Should be alphabet"
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

    
    //Check blank String LastName
    
    NSString *rawString1 = [self.lastNameText text];
    NSCharacterSet *whitespace1 = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed1 = [rawString1 stringByTrimmingCharactersInSet:whitespace1];
    
    if ([trimmed1 length] == 0)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter LastName"
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
    
    //Check  LastName Validation
    
    if (![self validate:[self.lastNameText text]])
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Last Name Should be alphabet"
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
    if ([self.emailText text].length == 0)
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
        return;
    }
    
    
    //Check  Email Validation
    
    if (![self IsValidEmail:[self.emailText text]])
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Correct Email"
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
    
    //Check blank String Message

    if ([self.messageTextView.text length]==0)
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please Enter Message"
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
    
    [self startActivity:@"Feedback Sharing"];
    
    NSString *post = [NSString stringWithFormat:@"FirstName=%@&LastName=%@&EmailId=%@&Description=%@",[self.firstNameText text],[self.lastNameText text],[self.emailText text],[self.messageTextView text]];
    [WebserviceManager sendSyncRequestWithURL:kFeedback method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue)
     {
         
         //if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

         {
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                
                                _feedbackArray = responseValue;
                                UIAlertController * alert = [UIAlertController
                                                             alertControllerWithTitle:@"Info"
                                                             message:@"Feedback Sent Successfully"
                                                             preferredStyle:UIAlertControllerStyleAlert];
                                
                                //Add Buttons
                                
                                UIAlertAction* yesButton = [UIAlertAction
                                                            actionWithTitle:@"Ok"
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                                //Handle your yes please button action here
                                                                [self dismissViewControllerAnimated:YES completion:Nil];
                                                            }];
                                
                                
                                //Add your buttons to alert controller
                                
                                [alert addAction:yesButton];
                                //[alert addAction:noButton];
                                
                                [self presentViewController:alert animated:YES completion:nil];
                                [self stopActivity];
                               // [self dismissViewControllerAnimated:YES completion:Nil];
                                
                            });
             
         }
         else{
             
             UIAlertController * alert = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Try Again"
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
         
     }];
}

-(BOOL)validate:(NSString *)string
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z ]" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
    return numberOfMatches == string.length;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange spaceRange = [string rangeOfString:@" "];
    if (spaceRange.location != NSNotFound)
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have entered wrong input" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [error show];
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)cancelbtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}



-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.backgroundColor = [UIColor colorWithRed:216.0f/255.0f green:244.0f/255.0f blue:255.0f/255.0f alpha:1];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    textField.backgroundColor = [UIColor whiteColor];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.customView endEditing:YES];// this will do the trick
}


-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // [self reload_captcha];
    //[_customCaptchaText becomeFirstResponder];
    
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height+150;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}



- (void)didReceiveMemoryWarning {
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
