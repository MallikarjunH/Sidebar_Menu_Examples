//
//  DeclineVC.m
//  emSigner
//
//  Created by Administrator on 8/1/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "DeclineVC.h"
#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "NSObject+Activity.h"
#import "MBProgressHUD.h"
#import "LMNavigationController.h"
#import "UITextView+Placeholder.h"
#import "PendingVC.h"
@interface DeclineVC ()

@end

@implementation DeclineVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.topItem.title = @" ";
    _customView.hidden=false;
    _yesBtn.enabled = NO;
    [_yesBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    //
    
    /*****************************Card View*********************************/
//
//    [self.customView setAlpha:1];
//    self.customView.layer.masksToBounds = NO;
//    self.customView.layer.cornerRadius = 5;
//    self.customView.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
//    self.customView.layer.shadowRadius = 25;
//    self.customView.layer.shadowOpacity = 0.5;

    _remarkText.layer.borderWidth = 1;
    _remarkText.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
//
    
    _remarkText.delegate = self;
   // _remarkText.placeholder = @"Remarks";
    _remarkText.textColor = [UIColor blackColor];
    
    //
    _customView.layer.cornerRadius = 10;
    _customView.layer.masksToBounds = YES;
    //
    //LeftBorderBtn1
    // at the top of the file with this code, include:
    
    
    CGRect rect = _noBtn.frame;
    
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
    
    [_noBtn.layer addSublayer:lineLayer];
    
    //Top Border
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(0.0f, 0.0f, _noBtn.frame.size.width, 1.0f);
    TopBorder.backgroundColor = ([UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0].CGColor);
    [_noBtn.layer addSublayer:TopBorder];
    
    
    //Top Border
    CALayer *TopBorder1 = [CALayer layer];
    TopBorder1.frame = CGRectMake(0.0f, 0.0f, _yesBtn.frame.size.width, 1.0f);
    TopBorder1.backgroundColor = ([UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0].CGColor);
    [_yesBtn.layer addSublayer:TopBorder1];
    
    
   
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger length = _remarkText.text.length - range.length + text.length;
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
        if (length > 0 && [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
            _yesBtn.enabled = YES;
            [_yesBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        } else {
            _yesBtn.enabled = NO;
            [_yesBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
 
    }
    
    
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self customView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) validateSpecialCharactor: (NSString *) text {
//    NSString *Regex = @"[A-Za-z0-9^]*";
//    NSPredicate *TestResult = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
//    return [TestResult evaluateWithObject:text];
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
}



- (IBAction)yesBtn:(id)sender
{
    NSString *isValid = self.remarkText.text;
    BOOL valid = [self validateSpecialCharactor:isValid];
    
    if (valid){
        [self declineAction];
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

-(void)declineAction
{
    [self startActivity:@"Document Declining..."];
    
    NSString *post = [NSString stringWithFormat:@"WorkflowId=%@&Remarks=%@",_workflowID,[self.remarkText text]];
    [WebserviceManager sendSyncRequestWithURL:kDecline method:SAServiceReqestHTTPMethodPOST body:post completionBlock:^(BOOL status, id responseValue)
     {
         
         // if(status)
         if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
             
         {
             dispatch_async(dispatch_get_main_queue(),
                            ^{
                                
                                _declineArray = responseValue;
                                
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
                                                                
                                                                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                
                                                                LMNavigationController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                                                [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                                                
                                                                [self stopActivity];
                                                                
                                                            }];
                                
                                
                                //Add your buttons to alert controller
                                [alert addAction:yesButton];
                                _customView.hidden=true;
                                [self presentViewController:alert animated:YES completion:nil];
                                [self stopActivity];
                                
                                UIStoryboard *newStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                
                                if ([self.strExcutedFrom isEqualToString:@"Pending"]) {
                                    LMNavigationController *objTrackOrderVC= [newStoryBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                    [self presentViewController:objTrackOrderVC animated:YES completion:nil];
                                    [self stopActivity];
                                    
                                }
                                
                                else
                                {
                                    [(UINavigationController *)self.presentingViewController  popViewControllerAnimated:NO];
                                    [self stopActivity];
                                    
                                    //[self dismissViewControllerAnimated:YES completion:nil];
                                }
                                
                                
                                [self stopActivity];
                            });
             
         }
         else{
             
             UIAlertController * alert = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Process Failed."
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
         }
         
     }];
}

- (IBAction)noBtn:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
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
