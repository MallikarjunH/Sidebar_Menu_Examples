//
//  AboutUsVC.m
//  emSigner
//
//  Created by Administrator on 9/29/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "AboutUsVC.h"

@interface AboutUsVC ()<UIWebViewDelegate>

@end

@implementation AboutUsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"About emSigner";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.topItem.title = @" ";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    
}

- (IBAction)supportBtn:(id)sender {
    if ([MFMailComposeViewController canSendMail])
        
    {
        [self sendEmail];
    }
    else
    {

        #define URLEMail @"mailto:sb@sw.com?subject=title&body=content"

        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:@"Please enable mail from your Phone settings."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        NSString *url = [URLEMail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
                                        [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: url]];
                                        
                                    }];
        
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}
- (IBAction)termsOfUse:(id)sender {
    NSString *iTunesLink = @"https://emsigner.com/Areas/Home/termsofservice";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}
- (IBAction)privacyBtn:(id)sender {
    
    NSString *iTunesLink = @"https://emsigner.com/Areas/Home/privacypolicy";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)sendEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        // Email Subject
        NSString *messageBody = @"";
        NSArray *toRecipents =[NSArray arrayWithObjects:@"support@emsigner.com",nil];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
     
        [self presentViewController:mc animated:YES completion:nil];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [self mailSent];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)mailSent
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Mail sent successfully"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
