//
//  EsignWebView.m
//  emSigner
//
//  Created by Emudhra on 26/06/19.
//  Copyright © 2019 Emudhra. All rights reserved.
//

#import "EsignWebView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface EsignWebView ()

@end

@implementation EsignWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webViewEsign.delegate=  self;
   
    NSURL *websiteUrl = [NSURL URLWithString:_urlForWebViewEsign];
    
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:websiteUrl];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
       // [self doSomeWork];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webViewEsign loadRequest:nsrequest];
        });
    });
}



//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
//        [[UIApplication sharedApplication] openURL:[request URL]];
//        return NO;
//    }
//
 //   return YES;
//}
//<a class="yourButton" href="inapp://capture">Button Text</a>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"inapp"]) {
        if ([request.URL.host isEqualToString:@"capture"]) {
            // do capture action
        }
        return NO;
    }
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //stop the activity indicator when done loading
   // [hud hideAnimated:YES];
    
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
