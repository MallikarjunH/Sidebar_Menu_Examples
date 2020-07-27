//
//  ReviewerController.m
//  emSigner
//
//  Created by EMUDHRA on 13/09/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "ReviewerController.h"
#import "UITextView+Placeholder.h"
#import "MPBSignatureViewController.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "WebserviceManager.h"
#import "MPBSignatureViewController.h"
#import "HoursConstants.h"
#import "LMNavigationController.h"


@interface ReviewerController ()

@end

@implementation ReviewerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.signersArray = [[NSMutableArray alloc]init];

    _customView.hidden=false;
    _doneBtn.enabled = YES;
    [_doneBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //
    
    /*****************************Card View*********************************/
    //
    //    [self.customView setAlpha:1];
    //    self.customView.layer.masksToBounds = NO;
    //    self.customView.layer.cornerRadius = 5;
    //    self.customView.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
    //    self.customView.layer.shadowRadius = 25;
    //    self.customView.layer.shadowOpacity = 0.5;
    
    _reviewerTextView.layer.borderWidth = 1;
    _reviewerTextView.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    //
    
    _reviewerTextView.delegate = self;
   // _reviewerTextView.placeholder = @"Please share your remarks";
    _reviewerTextView.textColor = [UIColor blackColor];
    
    //
    _customView.layer.cornerRadius = 10;
    _customView.layer.masksToBounds = YES;
    //
    //LeftBorderBtn1
    // at the top of the file with this code, include:
    
    
    CGRect rect = _cancelBtn.frame;
    
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    
    // start at top left corner
    [linePath moveToPoint:CGPointMake(0,0)];
    // draw left vertical side
    [linePath addLineToPoint:CGPointMake(0, rect.size.height)];
    
    // create a layer that uses your defined path
    CAShapeLayer * lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1.0;
    lineLayer.strokeColor = ([UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0].CGColor);
    
    lineLayer.fillColor = nil;
    lineLayer.path = linePath.CGPath;
    
    [_cancelBtn.layer addSublayer:lineLayer];
    
    //Top Border
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, 0.0f, _cancelBtn.frame.size.width, 1.0f);
    TopBorder.backgroundColor = ([UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0].CGColor);
    [_cancelBtn.layer addSublayer:TopBorder];
    
    
    //Top Border
    CALayer *TopBorder1 = [CALayer layer];
    TopBorder1.frame = CGRectMake(0.0f, 0.0f, _doneBtn.frame.size.width, 1.0f);
    TopBorder1.backgroundColor = ([UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0].CGColor);
    [_doneBtn.layer addSublayer:TopBorder1];
    
    
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger length = _reviewerTextView.text.length - range.length + text.length;
    if([text isEqualToString:@"\n"])
    {
        return NO;
    }
    else
    {
        if (range.location == 0 && ([text isEqualToString:@" "]))
        {
            return NO;
        }
       // if (length > 0 && [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
            _doneBtn.enabled = YES;
           // [_doneBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
       // } else {
           // _doneBtn.enabled = YES;
           // [_doneBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
       // }
        
    }
    
    
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self customView];
}
- (BOOL) validateSpecialCharactor: (NSString *) text {
    NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],<>?\\/\"\'";
    NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                           characterSetWithCharactersInString:specialCharacterString];
    
    if ([text.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].length) {
        NSLog(@"contains special characters");
        return  false;
    }
    else{
        return true;
    }
//    NSString *Regex = @"[A-Za-z0-9^]*";
//    NSPredicate *TestResult = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
//    return [TestResult evaluateWithObject:text];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showModal:(UIModalPresentationStyle) style style:(MPBCustomStyleSignatureViewController*) controller
{
    
    MPBCustomStyleSignatureViewController* signatureViewController = [controller initWithConfiguration:[MPBSignatureViewControllerConfiguration configurationWithFormattedAmount:@""]];
    signatureViewController.modalPresentationStyle = style;
    signatureViewController.strExcutedFrom=@"Waiting for Others";
    

    signatureViewController.gotParametersForInitiateWorkFlow = _requestArray;
    signatureViewController.d = self.d;
    signatureViewController.subscriberIdarray = self.subscriberIdarray;
    signatureViewController.preferredContentSize = CGSizeMake(800, 500);
    signatureViewController.configuration.scheme = MPBSignatureViewControllerConfigurationSchemeAmex;
    signatureViewController.signatureWorkFlowType = _workFlowType;
    signatureViewController.reviewerComments = _reviewerTextView.text;
    signatureViewController.signatureWorkFlowID = _workflowID;
    signatureViewController.passwordForPDF = _passwordForPDF;
    signatureViewController.continueBlock = ^(UIImage *signature) {
        //[self showImage: signature];
    };
    signatureViewController.cancelBlock = ^ {
        
    };
    signatureViewController.delegate = self;
    [self presentViewController:signatureViewController animated:YES completion:nil];
    //[self.navigationController pushViewController:signatureViewController animated:true];
    
}
- (IBAction)DoneBtnAction:(id)sender {
    NSString *isValid = self.reviewerTextView.text;
    
    NSUserDefaults *PendingVcYes = [NSUserDefaults standardUserDefaults];
    [PendingVcYes setObject:self.reviewerTextView.text forKey:@"reviewerTextView"];
    [PendingVcYes synchronize];
    
    BOOL valid = [self validateSpecialCharactor:isValid];
    [self.reviewerTextView resignFirstResponder];
    if (valid){

        //[self.pendingvc isEqualToString:@"PendingVcYes"] &&
        if (_isReviewer == true && _isSignatory == true) {
            NSUserDefaults *PendingVcYes = [NSUserDefaults standardUserDefaults];
            [PendingVcYes setBool:YES forKey:@"PendingVcYes"];
            [PendingVcYes synchronize];
            [self showModal:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc]];
            return;
        }
       
     
        if (_requestArray.count != 0) {
            NSString* WorkflowType = [[NSUserDefaults standardUserDefaults]valueForKey:@"WorkflowType"];
            
            
           // NSString *base64image=[initWorkFlowImage base64EncodedStringWithOptions:0];
            NSLog(@"%@",_subscriberIdarray);
            NSLog(@"%@",_d);
            
            for (int i = 0; i<_requestArray.count; i++) {
                int insertPosition = 0;

                NSMutableDictionary* sendingvalues = [[NSMutableDictionary alloc]init];
                _signersArray = [NSMutableArray new];
                NSArray * signatories = [_requestArray[i]valueForKey:@"Signatories"];
                
                [sendingvalues setObject:[_requestArray[i]valueForKey:@"CategoryId"] forKey:@"CategoryId"];
                [sendingvalues setObject:[_requestArray[i]valueForKey:@"CategoryName"] forKey:@"CategoryName"];
                [sendingvalues setObject:[_requestArray[i]valueForKey:@"DocumentName"] forKey:@"DocumentName"];
                [sendingvalues setObject:[_requestArray[i]valueForKey:@"ConfigId"] forKey:@"ConfigId"];
                [sendingvalues setValue:[_requestArray[i]valueForKey:@"DocumentId"] forKey:@"DocumentId"];
                [sendingvalues setValue:WorkflowType forKey:@"WorkflowType"];
                
                
               if ([_subscriberIdarray[i]isEqualToString:@"Signer"]) {
                    
                    [sendingvalues setObject:@"true" forKey:@"IsSign"];
                    [sendingvalues setObject:@"false" forKey:@"IsReviewer"];
                }
                else if ([_subscriberIdarray[i]isEqualToString:@"Reviewer"]){
                    [sendingvalues setObject:@"false" forKey:@"IsSign"];
                    [sendingvalues setObject:@"true" forKey:@"IsReviewer"];
                }
                else if ([_subscriberIdarray[i]isEqualToString:@"Internal"]){
                    [sendingvalues setObject:@"false" forKey:@"IsSign"];
                    [sendingvalues setObject:@"false" forKey:@"IsReviewer"];
                }
                
                
                for (int j= 0; j<signatories.count; j++) {
                    NSMutableDictionary * signatoriesDict = [[NSMutableDictionary alloc]init];
                    [_signersArray addObject:signatoriesDict];
                    if ([[_d[i] objectAtIndex:j]isEqualToString:@"ME"]&&[_subscriberIdarray[i]isEqualToString:@"Signer"]) {
                        
                        [signatoriesDict setObject:@"" forKey:@"ReviewerComment"];
                        [signatoriesDict setObject:[signatories[j]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
                        [signatoriesDict setObject:@"" forKey:@"SignatureImage"];
                        [signatoriesDict setObject:[signatories[j]valueForKey:@"pageId"] forKey:@"pageId"];
                        insertPosition = j;
                        [_signersArray replaceObjectAtIndex:j withObject:signatoriesDict];
                    }
                    else if([[_d[i] objectAtIndex:j]isEqualToString:@"ME"]&&[_subscriberIdarray[i]isEqualToString:@"Reviewer"]){
                        [signatoriesDict setObject:_reviewerTextView.text forKey:@"ReviewerComment"];
                        [signatoriesDict setObject:[signatories[j]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
                        [signatoriesDict setObject:@"" forKey:@"SignatureImage"];
                        [signatoriesDict setObject:[signatories[j]valueForKey:@"pageId"] forKey:@"pageId"];
                        if (![_subscriberIdarray containsObject:@"Signer"]) {
                             insertPosition = j;
                        }
                        [_signersArray replaceObjectAtIndex:j withObject:signatoriesDict];
                    }
                    else
                    {
                        [signatoriesDict setObject:@"" forKey:@"ReviewerComment"];
                        [signatoriesDict setObject:[signatories[j]valueForKey:@"SubscriberId"] forKey:@"SubscriberId"];
                        [signatoriesDict setObject:@"" forKey:@"SignatureImage"];
                        [signatoriesDict setObject:[signatories[j]valueForKey:@"pageId"] forKey:@"pageId"];
                        
                        [_signersArray replaceObjectAtIndex:j withObject:signatoriesDict];
                        
                    }
                    // [_subscriberidarray replaceObjectAtIndex:j withObject:signatoriesDict];
                    //move ME position to first
                    
                }
                _signersArray = [self InsertIndex:_signersArray Index:insertPosition];
                [sendingvalues setObject:_signersArray  forKey:@"Signatories"];
                [_requestArray replaceObjectAtIndex:i withObject:sendingvalues];
                
            }
            if ([_subscriberIdarray containsObject:@"Signer"] && [_subscriberIdarray containsObject:@"Reviewer"]) {
                 [self showModal:UIModalPresentationFullScreen style:[MPBDefaultStyleSignatureViewController alloc]];
            }
            else if([_subscriberIdarray containsObject:@"Reviewer"]){
            [self callinitWorkFlowApi:_requestArray];
            }
        }
        
        else
        {
                [self dismissViewControllerAnimated:true completion:nil];
                //   if ([self signature] != nil) {
                [self startActivity:@"Reviewing"];
            
            NSString *checkPassword  = @"111111";
                
                NSString *post = [NSString stringWithFormat:@"WorkflowId=%@&SignatureImage=%@&Password=%@&workflowType=%@&ReviewerComment=%@",_workflowID,@"",checkPassword,_workFlowType,self.reviewerTextView.text];
                post = [[post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                        stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                [WebserviceManager sendSyncRequestWithURL:kSignatureImage method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
                    
                    if (status) {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Password"];
                        
                        //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:checkPassword];
                        NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                        if([isSuccessNumber boolValue] == YES)
                        {
                            dispatch_async(dispatch_get_main_queue(),
                                           ^{
                                               [self stopActivity];
                                               UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"] objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                               [alert15 show];
                                               
                                               UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                               LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                               [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                               
                                           });
                            
                        }
                    }
                    [self stopActivity];
                    
                }];
            
        }
    }
    else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Special Characters are not allowed.";//[NSString stringWithFormat:@"Page %@ of %lu", self.view.currentPage.label, (unsigned long)self.pdfDocument.pageCount];
        hud.margin = 10.f;
        hud.yOffset = 170;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:2];
        
    }
}

- (NSMutableArray *)InsertIndex:(NSMutableArray *)signatoryArray Index:(int)indexvalue{
    
    NSMutableArray *insertedArray  = [[NSMutableArray alloc]init];
    [insertedArray addObjectsFromArray:signatoryArray];
    [insertedArray removeObjectAtIndex:indexvalue];
    [insertedArray insertObject:signatoryArray[indexvalue] atIndex:0];
    
    return insertedArray;
}

-(void)callinitWorkFlowApi:(NSMutableArray*)post
{
    
    [self startActivity:@"Loading"];
    
    // [WebserviceManager sendSyncRequestWithURLDocument:@"https://sandboxapi.emsigner.com/api/InitiateWorkflow" method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
    
    [WebserviceManager sendSyncRequestWithURLDocument:kInitiateWorkflow method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue){
        
        if (status) {
            int issucess = [[responseValue valueForKey:@"IsSuccess"]intValue];
            
            if (issucess != 0) {
                
                NSNumber * isSuccessNumber = (NSNumber *)[responseValue valueForKey:@"IsSuccess"];
                if([isSuccessNumber boolValue] == YES)
                {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
//                                       UIAlertController * alert = [UIAlertController
//                                                                    alertControllerWithTitle:@""
//                                                                    message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
//                                                                    preferredStyle:UIAlertControllerStyleAlert];
//
//                                       //Add Buttons
//
//                                       UIAlertAction* yesButton = [UIAlertAction
//                                                                   actionWithTitle:@"OK"
//                                                                   style:UIAlertActionStyleDefault
//                                                                   handler:^(UIAlertAction * action) {
//                                                                       //Handle your yes please button action here
//                                                                       //                                                                       [self.navigationController popToRootViewControllerAnimated:true];
//
//
//                                                                   }];
//
//                                       //Add your buttons to alert controller
//
//                                       [alert addAction:yesButton];
//                                       [self presentViewController:alert animated:YES completion:nil];
                                       
                                       
                                       
                                       [self stopActivity];
                                       
                                       UIAlertView * alert15 =[[UIAlertView alloc ] initWithTitle:@"" message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                       [alert15 show];
                                       
                                       UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                       LMNavigationController *objTrackOrderVC= [sb  instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                       [[[[UIApplication sharedApplication] delegate] window] setRootViewController:objTrackOrderVC];
                                     //  [self.navigationController popToRootViewControllerAnimated:true]
                                       ;
                                   });
                    
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       UIAlertController * alert = [UIAlertController
                                                                    alertControllerWithTitle:@""
                                                                    message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
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
                                                                message:[[responseValue valueForKey:@"Messages"]objectAtIndex:0]
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
        else{
            [self stopActivity];
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               UIAlertController * alert = [UIAlertController
                                                            alertControllerWithTitle:@""
                                                            message:@"WorkFlow initiating Failed."
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
- (IBAction)CancelClicked:(id)sender {
     [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
