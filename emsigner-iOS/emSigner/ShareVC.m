//
//  ShareVC.m
//  emSigner
//
//  Created by Administrator on 11/18/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "ShareVC.h"
#import "UITextView+Placeholder.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "NSObject+Activity.h"
#import "MBProgressHUD.h"
#import "LMNavigationController.h"
#import "CoSignPendingVC.h"
#import "PendingVC.h"
#import "BaseViewController.h"
#import "CompletedNextVC.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface ShareVC ()
{
    NSMutableArray * listArray;
    NSMutableArray * totalDocNames;
}


@property (nonatomic, assign) UITextView *currentField;

@end

@implementation ShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // self.mShare.layer.cornerRadius = 10;
  //  self.mCancel.layer.cornerRadius = 10;
    self.navigationController.navigationBar.topItem.title = @" ";
    self.pdfLable.text = self.documentName;
    
    self.title = @"Share Document";
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

    //flag
    _flagStr = @"false";

    NSLog(@"%@",_workflowID);
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    visualEffectView.frame = _imageView.bounds;
    [_imageView addSubview:visualEffectView];
    
 //   ****************************Card View********************************
    
   // TextField Down Border
//    CALayer *border = [CALayer layer];
//    CGFloat borderWidth = 2;
//    border.borderColor = ([UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor);
//    border.frame = CGRectMake(0, _sharelable.frame.size.height - borderWidth, _sharelable.frame.size.width, _sharelable.frame.size.height);
//    border.borderWidth = borderWidth;
//    [_sharelable.layer addSublayer:border];
//    _sharelable.layer.masksToBounds = YES;
    
//    [self.customView setAlpha:1];
//    self.customView.layer.masksToBounds = NO;
//    self.customView.layer.cornerRadius = 10;
//    self.customView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
//    self.customView.layer.shadowRadius = 25;
//    self.customView.layer.shadowOpacity = 0.5;
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.customView.bounds];
//    self.customView.layer.shadowPath = path.CGPath;
//
  //  _mEmail.delegate = self;
    _mEmail.textColor = [UIColor blackColor];
    
    _MMessage.layer.borderWidth = 1;
    _MMessage.layer.borderColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0].CGColor;
    
    _MMessage.delegate = self;
   // _MMessage.placeholder = @"Message";
    _MMessage.textColor = [UIColor blackColor];
   
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
   // [tapRecognizer setNumberOfTapsRequired:1];
    [self.customView addGestureRecognizer:tapRecognizer];
    
    
    
    listArray = [[NSMutableArray alloc]init];
    totalDocNames = [[NSMutableArray alloc]init];
    
    CGRect frame = self.mEmail.frame;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, frame.origin.y)];
    self.scrollView.frame = CGRectMake(0.0f, self.view.frame.origin.y + 40.0, self.view.frame.size.width, self.view.frame.size.height - 105.0f);
    [self.view addSubview:self.scrollView];
    
    [self getDocumentNames];
}

-(void) getDocumentNames
{
    //    /*************************Web Service*******************************/
    [self startActivity:@"Refreshing"];
    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentidsByWorkflowid?WorkflowID=%@",kMultipleDoc,_workflowID];
    
    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
        
      //  if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               listArray=[responseValue valueForKey:@"Response"];
                               if (listArray != (id)[NSNull null])
                               {
                                   for (int i = 0; listArray.count>i; i++) {
                                       NSDictionary * dict = listArray[i];

                                       [totalDocNames addObject:[dict valueForKey:@"DocumentName"]];
                                       
                                   }
                                   NSString * DocNames =   [totalDocNames componentsJoinedByString:@","];

                                   self.pdfLable.text = DocNames;
                                [self stopActivity];
                               }
                               else{
                                   
                               }
                               
                               [self stopActivity];
                               
                           });
        }
        else{
            [self stopActivity];
        }
        
    }];
  
    /*******************************************************************************/
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect themeFieldRect = self.mEmail.frame;
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, themeFieldRect.origin.y + themeFieldRect.size.height+ 200)];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGRect frame = self.mEmail.frame;
    
    CGPoint offset;
    if (frame.origin.y > _scrollView.frame.size.height)
    {
        offset = CGPointMake(0.0, (frame.origin.y + frame.size.height + 20) - _scrollView.frame.size.height);
    }
    else
    {
        offset = CGPointMake(0.0f, 0.0f);
    }
    [_scrollView setContentOffset:offset animated:YES];
    
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

- (void)textViewDidEndEditing:(UITextView *)textView;
{
    _currentField = textView;
    //DEBUGLOG(@"textFieldShouldBeginEditing _currentField = %@", _currentField);
    
    CGPoint scrollPoint;
    CGRect inputFieldBounds = [textView bounds];
    inputFieldBounds = [textView convertRect:inputFieldBounds toView:_scrollView];
    scrollPoint = inputFieldBounds.origin;
    scrollPoint.x = 0;
    scrollPoint.y -= 70; // you can customize this value
    if (scrollPoint.y < 0 ) scrollPoint.y = 0;
    [_scrollView setContentOffset:scrollPoint animated:YES];
    
   // return YES;
}

- (void)textFieldDidEndEditing:(UITextView *)textField
{
    if (textField == _currentField)
        _currentField = nil;
    //DEBUGLOG(@"textFieldDidEndEditing _currentField = %@", _currentField);
}


//- (BOOL)textFieldShouldReturn:(UITextView *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.customView endEditing:YES];// this will do the trick
}

-(void)handleTap:(id)sender //Show Menu
{
    [self.customView endEditing:YES];// this will do the trick

}
//Email Validation
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
/*****************************************************************/


- (IBAction)mShare:(id)sender
{
    
    if ([self.mEmail text].length > 1)
    {
        
        
        NSString *email=self.mEmail.text;  //is your str
        
        NSArray *items = [email componentsSeparatedByString:@","];
        
        BOOL IsValidate =true;
        for(NSString *currentNumberString in items) {
            NSLog(@"Number: %@", currentNumberString);
            
            NSString *rawString = currentNumberString;
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
            
                if (![self IsValidEmail:trimmed]) {
                    IsValidate = false;
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@""
                                                 message:@"Please enter Valid Email Id"
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
                    return;

                }
                
            
        }
        
        /***************************Calling Share Api*******************************/
        
            if (IsValidate ) {
                
                //Check Null Date
                NSString *descriptionStr3;
                descriptionStr3=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",_documentID]];
                
                //Check Null Date
                NSString *descriptionStr;
                descriptionStr=[[AppDelegate AppDelegateInstance] strCheckNull:[NSString stringWithFormat:@"%@",_workflowID]];
                
            [self startActivity:@"Document Sharing"];
            
            NSString *post = [NSString stringWithFormat:@"WorkflowId=%@&Email=%@&MessageContent=%@&IsAttached=%@",_workflowID,self.mEmail.text,self.MMessage.text,_flagStr];
            [WebserviceManager sendSyncRequestWithURL:kShare method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue)
             {
                 
               //  if(status)
                 if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

                 {
                     dispatch_async(dispatch_get_main_queue(),
                                    ^{
                                        
                                        _shareArray = [responseValue valueForKey:@"Response"];
                                        
                                        if (_shareArray != (id)[NSNull null])
                                        {
                                            
                                            NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                                            if([isSuccessNumber boolValue] == YES)
                                            {
                                                
                                                UIAlertController * alert = [UIAlertController
                                                                             alertControllerWithTitle:@""
                                                                             message:@"Document Shared Successfully"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                                
                                                //Add Buttons
                                                
                                                UIAlertAction* yesButton = [UIAlertAction
                                                                            actionWithTitle:@"Ok"
                                                                            style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                                                                                //Handle your yes please button action here
                                                                                
                                                                                //[self dismissViewControllerAnimated:YES completion:nil];
                                                                                [[self navigationController] popViewControllerAnimated:YES];

                                                                            }];
                                                
                                                
                                                //Add your buttons to alert controller
                                                
                                                [alert addAction:yesButton];
                                                //[alert addAction:noButton];
                                                
                                                [self presentViewController:alert animated:YES completion:nil];
                                                [self stopActivity];
                                                //[self dismissViewControllerAnimated:YES completion:nil];
                                            }
                                           else{
                                               
                                               NSArray * messagearray = [responseValue valueForKey:@"Messages"];
                                               if (messagearray.count != 0) {
                                               
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
                                                                          
                                                                              // [self dismissViewControllerAnimated:YES completion:Nil];
                                                                               [[self navigationController] popViewControllerAnimated:YES];

                                                                           }];
                                               
                                               //Add your buttons to alert controller
                                               
                                               [alert addAction:yesButton];
                                               
                                               [self presentViewController:alert animated:YES completion:nil];
                                               
                                               [self stopActivity];
                                            
                                            }
                                               else
                                               {
                                                   UIAlertController * alert = [UIAlertController
                                                                                alertControllerWithTitle:@""
                                                                                message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                                                   
                                                   //Add Buttons
                                                   
                                                   UIAlertAction* yesButton = [UIAlertAction
                                                                               actionWithTitle:@"Ok"
                                                                               style:UIAlertActionStyleDefault
                                                                               handler:^(UIAlertAction * action) {
                                                                                   //Handle your yes please button action here
                                                                                   
                                                                                   // [self dismissViewControllerAnimated:YES completion:Nil];
                                                                                   [[self navigationController] popViewControllerAnimated:YES];
                                                                                   
                                                                               }];
                                                   
                                                   //Add your buttons to alert controller
                                                   
                                                   [alert addAction:yesButton];
                                                   
                                                   [self presentViewController:alert animated:YES completion:nil];
                                                   
                                                   [self stopActivity];
                                               }
                                               
                                           }
                                          

                                        }
                                        else{
                                            
                                           
                                            
                                        }
                                        
                                    
                                    });
                     
                 }
                 else{
                   
                     [self stopActivity];
                     UIAlertController * alert = [UIAlertController
                                                  alertControllerWithTitle:nil
                                                  message:@"Failed to share the Document. Please try again!"
                                                  preferredStyle:UIAlertControllerStyleAlert];
                     
                     //Add Buttons
                     
                     UIAlertAction* yesButton = [UIAlertAction
                                                 actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     //Handle your yes please button action here
                                                     //Logout
                                                     AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                                                     theDelegate.isLoggedIn = NO;
                                                     [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
                                                     [NSUserDefaults resetStandardUserDefaults];
                                                     [NSUserDefaults standardUserDefaults];
                                                     UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                     ViewController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"ViewController"];
                                                     [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                                 }];
                     
                     [alert addAction:yesButton];
                     
                     [self presentViewController:alert animated:YES completion:nil];
                     
                     return;
                 }
                 
             }];

        }
        
        
        
    }
                    else
                    {

                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@""
                                                     message:@"Please enter Email Id"
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


- (IBAction)mCancel:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}


//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
//
//}
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
//
//    [self.view endEditing:YES];
//
//}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
   
}
//
//-(void)keyboardWillShow:(NSNotification*)aNotification {
//    // Animate the current view out of the way
//    if (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
//    else if (self.view.frame.origin.y < 0)
//    {
//        [self setViewMovedUp:NO];
//    }
//}
//
//-(void)keyboardWillHide:(NSNotification*)aNotification {
//    if (self.view.frame.origin.y >= 0)
//    {
//        [self setViewMovedUp:YES];
//    }
//    else if (self.view.frame.origin.y < 0)
//    {
//        [self setViewMovedUp:NO];
//    }
//}
//
//-(void)textFieldDidBeginEditing:(UITextField *)sender
//{
//
//        //move the main view, so that the keyboard does not hide it.
//        if  (self.view.frame.origin.y >= 0)
//        {
//            [self setViewMovedUp:YES];
//        }
//
//}
//
////method to move the view up/down whenever the keyboard is shown/dismissed
//-(void)setViewMovedUp:(BOOL)movedUp
//{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
//
//    CGRect rect = self.view.frame;
//    if (movedUp)
//    {
//        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
//        // 2. increase the size of the view so that the area behind the keyboard is covered up.
//        rect.origin.y -= 30;
//        rect.size.height += 30;
//    }
//    else
//    {
//        // revert back to the normal state.
//        rect.origin.y += 30;
//        rect.size.height -= 30;
//    }
//    self.view.frame = rect;
//
//    [UIView commitAnimations];
//}

- (IBAction)shareSwitch:(id)sender
{
   //BOOL flag = TRUE;
    if([sender isOn]){
        // Execute any code when the switch is ON
        _flagStr = @"true";
        NSLog(@"Switch is ON");
    } else{
        // Execute any code when the switch is OFF
        _flagStr = @"false";
        NSLog(@"Switch is OFF");
    }
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
