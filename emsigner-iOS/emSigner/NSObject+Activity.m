//
//  NSObject+Activity.m
//  Greencard
//
//  Created by Ghadeer Joma on 3/22/14.
//  Copyright (c) 2014 Ahmad Tareq. All rights reserved.
//

#import "NSObject+Activity.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@implementation NSObject (Activity)

-(void)startActivity:(NSString *)status
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    progress.labelText =status;
    });
    
}

-(void)stopActivity
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if ([[UIApplication sharedApplication]isIgnoringInteractionEvents] == YES) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                   });
}
//-(void)startActivity_DetailPage
//{
//    
//    [self startActivity];
//}
//-(void)stopActivity_DetailPage
//{
//    
//    [self stopActivity];
//}
-(void)didFailWithTimeOut
{
  UIAlertView  *alert = [[UIAlertView alloc]initWithTitle:@"Sorry"  message:@"Please Try Again"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    //NSLog(@"UIViewController (Activity) - didFailWithTimeOut");
    [self stopActivity];
}


@end