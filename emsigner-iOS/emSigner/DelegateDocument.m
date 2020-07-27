//
//  DelegateDocument.m
//  emSigner
//
//  Created by Emudhra on 12/02/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "DelegateDocument.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "SingletonAPI.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "DocumentLogVC.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "LMNavigationController.h"


@interface DelegateDocument ()
{
    NSMutableArray * listArray;
}
@end

@implementation DelegateDocument

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSLog(@"%@",_matchSignersList);
    
    [self.emailText setDelegate:self];
   // [self.nameText setDelegate:self];
    
    // Do any additional setup after loading the view from its nib.
    _commentsText.layer.borderWidth = 1;
    //  _MMessage.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor lightGrayColor]);
    _commentsText.layer.borderColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1.0].CGColor;
    
    _commentsText.delegate = self;
    _commentsText.textColor = [UIColor blackColor];
    
//    _emailText.delegate = self;
//    _nameText.delegate = self;
    _holdSignersList = [[NSMutableArray alloc]init];
    listArray = [[NSMutableArray alloc]init];
    [self getSignersListToDisplay];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                          action:@selector(dismissKeyboard)];
//
//    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_emailText endEditing:YES];
    [_nameText endEditing:YES];

    [_commentsText endEditing:YES];

}

-(void)emailIdPresent
{
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains[cd] %@",self.emailText.text];
    BOOL searchredString = [listArray filteredArrayUsingPredicate:bPredicate];
    NSLog(@"HERE %@",searchredString);
    
//    for (int i = 0; i<listArray.count; i++) {
//        if (self.emailText.text == [listArray[i] valueForKey:@"EmailId"]) {
//            NSLog(@"1");
//            return;
//        }
//        else
//        {
//            NSLog(@"123");
//            return;
//        }
//    }
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

- (IBAction)delegateBtn:(id)sender {
    
    BOOL validEmail = [self IsValidEmail:self.emailText.text];
    
    //[self emailIdPresent];
    
    if ([self.nameText text].length == 0 )
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please enter name"
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
    
    if ([self.commentsText text].length == 0) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Please enter remarks"
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
    
    if ([self.emailText text].length > 1 && validEmail)
    {
        NSMutableArray * sArray = [NSMutableArray array];
        
        for (NSDictionary * dict in listArray) {
            [sArray addObject:[dict valueForKey:@"EmailId"]];
            
        }
        BOOL isTheObjectThere = [sArray containsObject:self.emailText.text];
        if (isTheObjectThere == false) {
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@""
                                         message:@"Entered EmailId is not linked with your account."
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
        else{
            
            [self delegateWorkflowApi];
        }
        
    }
    else
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
    }
    
}


-(void)delegateWorkflowApi
{
    
    [self startActivity:@"Loading"];

    
    NSString *post = [NSString stringWithFormat:@"WorkflowId=%@&EmailId=%@&Name=%@&Reason=%@",_workflowID,self.emailText.text,self.nameText.text,_commentsText.text];
        [WebserviceManager sendSyncRequestWithURL:kDelegateWorkflows method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue)
         {
             
            // if(status)
                 if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

             {
                 dispatch_async(dispatch_get_main_queue(),
                                ^{
                                    
                                  //  [_holdSignersList addObjectsFromArray:[responseValue valueForKey:@"IsSuccess"]];
                                    
//                                    if (_holdSignersList != (id)[NSNull null])
//                                    {
                                    
                                        NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                                        if([isSuccessNumber boolValue] == YES)
                                        {
                                            
                                            UIAlertController * alert = [UIAlertController
                                                                         alertControllerWithTitle:@""
                                                                         message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            //Add Buttons
                                            
                                            UIAlertAction* yesButton = [UIAlertAction
                                                                        actionWithTitle:@"Ok"
                                                                        style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action)
                                            {
                                                                            
                                                    UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                            
                                                    LMNavigationController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                                    [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                                                            
                                            }];
                                            
                                            //Add your buttons to alert controller
                                            
                                            [alert addAction:yesButton];
                                            [self presentViewController:alert animated:YES completion:nil];
                                            [self stopActivity];
                                        }
                                        else
                                        {
                                            
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
                                                                                
                                                                                [[self navigationController] popViewControllerAnimated:YES];
                                                                                
                                                                            }];
                                                
                                                //Add your buttons to alert controller
                                                
                                                [alert addAction:yesButton];
                                                
                                                [self presentViewController:alert animated:YES completion:nil];
                                                
                                                [self stopActivity];
                                            }
                                            
                                        }
                                        
                                        
                                   // }
//                                    else{
//
//
//                                    }
                                    
                                    
                                });
                 
             }
             else{
                 // if ([responseValue isKindOfClass:[NSString class]]) {
                 // if ([responseValue isEqualToString:@"Invalid token Please Contact Adminstrator"]) {
                 
                 [self stopActivity];
                 UIAlertController * alert = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:@"Failed to delegate the Document.Please try again!"
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
                  [self stopActivity];
                 return;
             }
             
         }];
}


- (IBAction)cancelBtn:(id)sender {
       [[self navigationController] popViewControllerAnimated:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

//textfield delegates

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self animateTextView: YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self animateTextView:NO];
}

- (void) animateTextView:(BOOL) up
{
    const int movementDistance = 100; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    NSLog(@"%d",movement);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)getSignersListToDisplay
{
    //NSString *requestURL = [NSString stringWithFormat:@"https://sandboxapi.emsigner.com/api/GetAllSigners"];
    
    [WebserviceManager sendSyncRequestWithURLGet:kGetAllSigners method:SAServiceReqestHTTPMethodGET body:kGetAllSigners completionBlock:^(BOOL status, id responseValue) {
       // if(status)
            if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])

        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               
                               _holdSignersList = [responseValue valueForKey:@"Response"];
                               
                               NSMutableArray * sArray = [NSMutableArray array];
                               
                               for (NSDictionary * dict in _matchSignersList) {
                                   [sArray addObject:[dict valueForKey:@"EmailID"]];
                                   
                               }
                               
                               for (int i = 0; i<_holdSignersList.count; i++) {
                                   NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:[_holdSignersList[i] valueForKey:@"EmailId"],@"EmailId",
                                                      [_holdSignersList[i] valueForKey:@"Name"],@"Name",nil];
                                   
                                   BOOL isTheObjectThere = [sArray containsObject:[d valueForKey:@"EmailId"]];
                                   if (isTheObjectThere == false) {
                                       [listArray addObject:d];
                                   }
                                   
                               }
                               
                           }
);
        }
        else{
            
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:nil
                                         message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Ok"
                                        style:UIAlertActionStyleDefault
                                        handler:nil ];
            
            [alert addAction:yesButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        
    }];
    
}


#pragma mark MPGTextField Delegate Methods

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    if ([textField isEqual:self.emailText]) {
        return listArray;
    }
//    else if ([textField isEqual:self.companyName]){
//        return companyData;
//    }
    else{
        return nil;
    }
   // return ;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_emailText resignFirstResponder];
    [_nameText resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return YES;
}

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    //A selection was made - either by the user or by the textfield. Check if its a selection from the data provided or a NEW entry.
    if ([[result objectForKey:@"CustomObject"] isKindOfClass:[NSString class]] && [[result objectForKey:@"CustomObject"] isEqualToString:@"NEW"]) {
        //New Entry
       // [self.nameStatus setHidden:NO];
    }
    else{
        //Selection from provided data
        if ([textField isEqual:self.emailText]) {
           // [self.nameStatus setHidden:YES];
//            [self.web setText:[[result objectForKey:@"CustomObject"] objectForKey:@"web"]];
              [self.nameText setText:[result objectForKey:@"Name"]];
//            [self.phone1 setText:[[result objectForKey:@"CustomObject"] objectForKey:@"phone1"]];
//            [self.phone2 setText:[[result objectForKey:@"CustomObject"] objectForKey:@"phone2"]];
        }
//        [self.address setText:[[result objectForKey:@"CustomObject"] objectForKey:@"address"]];
//        [self.state setText:[[result objectForKey:@"CustomObject"] objectForKey:@"state"]];
//        [self.zip setText:[[result objectForKey:@"CustomObject"] objectForKey:@"zip"]];
//        [self.companyName setText:[[result objectForKey:@"CustomObject"] objectForKey:@"company_name"]];
    }
}

@end
