//
//  AppDelegate.m
//  emSigner
//
//  Created by Administrator on 7/12/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "iRate.h"
#import "HomeNewDashBoardVC.h"
#import "Reachability.h"
#import "PendingListVC.h"

#import "WebserviceManager.h"
#import "HoursConstants.h"
#import "MBProgressHUD.h"
#import "NSObject+Activity.h"
#import "SignatoriesPage.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "ImagesForPageViewController.h"
#import "HomeNewDashBoardVC.h"

#import "MSALPublicClientApplication.h"
//#import "MSIDAutomationMainViewController.h"
#import <MSAL/MSAL.h>

//#import <MSAL/MSAL.h>
@import UserNotifications;

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate
{
    UIViewController *theRootVC;
    NSString *letters;
    NSMutableString * mstrXMLString;
    BOOL isdelegate;
    NSInteger* statusId;
    NSString* statusForPlaceholders;
    NSDictionary *userInfo ;
   

}
NSString *const kGCMMessageIDKey = @"1:851743474169:ios:dc46cc6243f9cfa352fd28";


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //MSAL
    [MSALGlobalConfig.loggerConfig setLogCallback:^(__unused MSALLogLevel level, NSString * _Nullable message, __unused BOOL containsPII) {
        //[MSIDAutomationMainViewController forwardIdentitySDKLog:message];
        if (!containsPII) {
            NSLog(@"%@",message);
        }
    }];
    
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Key"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"indexvalue"];
    
    //Push Notifications
    // [START configure_firebase]
    [FIRApp configure];
    // [END configure_firebase]
    
    // [START set_messaging_delegate]
    [FIRMessaging messaging].delegate = self;
    // [END set_messaging_delegate]
    
    // Register for remote notifications. This shows a permission dialog on first run, to
    // show the dialog at a more appropriate time move this registration accordingly.
    // [START register_for_notifications]
    if ([UNUserNotificationCenter class] != nil) {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
             // ...
         }];
    } else {
        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    [application registerForRemoteNotifications];
    // [END register_for_notifications]

    //Set default navigation bar title
   
    
    
    // [self startActivity:@"Loading"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths firstObject];
    NSLog(@"applicationSupportDirectory: '%@'", applicationSupportDirectory);
    
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [NSThread sleepForTimeInterval:2.0];
    
    //Session
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window =[[UIWindow alloc] initWithFrame:frame];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSNumber *number  = [[NSUserDefaults standardUserDefaults] valueForKey:@"isLogin"];
    _isLoggedIn = [number boolValue];
    NSString * CHECK = [[NSUserDefaults standardUserDefaults] valueForKey:@"checkBox"];
    
    if (_isLoggedIn && [CHECK isEqualToString:@"YES"]) {
        
        theRootVC = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
        LAContext *myContext = [[LAContext alloc] init];
        NSError *authError = nil;
        NSString *myLocalizedReasonString = @"Please use secure Biometric for Authentication";
        
        if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&authError]) {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication
                      localizedReason:myLocalizedReasonString
                                reply:^(BOOL success, NSError *error) {
                                    if (success) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            theRootVC = [storyBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
                                            self.window.rootViewController = theRootVC;
                                        });
                                        
                                    } else {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            
                                            
                                            UIAlertController * alert = [UIAlertController
                                                                         alertControllerWithTitle:@"Authentication Error"
                                                                         message:authError.localizedDescription
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                                            
                                            //Add Buttons
                                            
                                            UIAlertAction* yesButton = [UIAlertAction
                                                                        actionWithTitle:@"Ok"
                                                                        style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                                                                            //Handle your yes please button action here
                                                                            //Logout
                                                                            theRootVC  = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
                                                                            self.window.rootViewController = theRootVC;
                                                                        }];
                                            
                                            [alert addAction:yesButton];
                                            
                                            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
                                            // Rather than show a UIAlert here, use the error to determine if you should push to a keypad for PIN entry.
                                        });
                                    }
                                }];
        self.window.rootViewController = theRootVC;

        } else {
            
            
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"checkBox"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            AppDelegate *theDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            theDelegate.isLoggedIn = NO;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:theDelegate.isLoggedIn] forKey:@"isLogin"];
            theRootVC  = [storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
            self.window.rootViewController = theRootVC;

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
                                                
                                                
                                            }];
                
                [alert addAction:yesButton];
                [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
                //[self presentViewController:alert animated:YES completion:nil];
            });
        }
        
    }
    else if (_isLoggedIn) {
        theRootVC = [storyBoard instantiateViewControllerWithIdentifier:@"HomeNavController"];
        self.window.rootViewController = theRootVC;

    }
    else{
       // theRootVC  = [storyBoard instantiateViewControllerWithIdentifier:@"ImagesForPageViewController"];
        ImagesForPageViewController *loginController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ImagesForPageViewController"]; //or the homeController
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:loginController];
        self.window.rootViewController = navController;
    }
    //self.window.rootViewController = theRootVC;

    return YES;
    
}

//
- (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler {

   // PendingListVC *signPad = (PendingListVC*)self.window.rootViewController;
   // PendingListVC *signPad = [[PendingListVC alloc]init];
   // [signPad showPopForSign];
    [[NSNotificationCenter defaultCenter]
                                            postNotificationName:@"SiriContent"
                                            object:userActivity.userInfo[@"searchTerm"]];
   // if ([userActivity.activityType isEqualToString:@"INSearchForPhotosIntent"]) {
        //ViewController *rootViewController = (ViewController*)self.window.rootViewController;
        //[rootViewController showPhotoForSearchTerm:userActivity.userInfo[@"searchTerm"]];
    //}

    return YES;
}

//MSAL
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [MSALPublicClientApplication handleMSALResponse:url
                                         sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
}



#pragma mark -
#pragma mark - AppDelegate Single Instance

+(AppDelegate *)AppDelegateInstance
{
    return (AppDelegate *)[[UIApplication sharedApplication]delegate];
}
- (NSString *)strCheckNull:(NSString *)myStrting
{
    NSString *string = [NSString stringWithFormat:@"%@",myStrting];
    
    if([string isEqual:[NSNull null]] || string==nil || [string isEqualToString:@""] || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"] || [string length]==0)
        return @"";
    else
        return string;
}
    
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self startActivity:@""];
    NetworkStatus networkStatus =[[Reachability reachabilityForInternetConnection]currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Network Unavailable"
                              message:@"emSigner requires an Internet connection"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
    
    NSURL *myUrl=[NSURL URLWithString:@"https://emsigner.com/downloads/version.json"];
    NSURLRequest *myRequest=[NSURLRequest requestWithURL:myUrl];
    
    NSURLSessionConfiguration *mySessionConfiguration=[NSURLSessionConfiguration defaultSessionConfiguration];
    mySessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSURLSession *mySession=[NSURLSession sessionWithConfiguration:mySessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *myDataTask=[mySession dataTaskWithRequest:myRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
        {
                        NSDictionary *myDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                          
                        NSLog(@"the value is dictionary is %@",myDict);
                                          
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                        NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
                        NSString* currentVersion = infoDictionary[@"CFBundleShortVersionString"];
                        NSString *version = [myDict valueForKey:@"IOSappversion"];
                            
                        float  currentVers = [currentVersion floatValue];
                        float vers = [version floatValue];
                            
                        NSString *forceUpgrade = [myDict valueForKey:@"forceUpgrade"];
                        NSString *recommendUpgrade = [myDict valueForKey:@"recommendUpgrade"];
                            
                        UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                        topWindow.rootViewController = [UIViewController new];
                        topWindow.windowLevel = UIWindowLevelAlert + 1;
                            
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"emSigner" message:[NSString stringWithFormat: @"%@ ", @"New update is available. Please update the application. "]preferredStyle:UIAlertControllerStyleAlert];
                            
                        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Update"
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                        {
                                            
                                        NSLog(@"you pressed Yes, please button");
                                        NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id1246670687?mt=8";
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                        
                                        }];
                            
                       if ((currentVers < vers) && [forceUpgrade isEqualToString:@"true"]) {
                                          
                           [alert addAction:yesButton];
                           [topWindow makeKeyAndVisible];
                           [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                        }
                       else if ((currentVers < vers) && [recommendUpgrade isEqualToString:@"true"])
                       {
                                          
                            UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No Thanks"
                                                                   style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action)
                                                      {
                                                            NSLog(@"ok thanks");
                                                      }];
                                          
                            [alert addAction:yesButton];
                            [alert addAction:noButton];
                                          
                            [topWindow makeKeyAndVisible];
                            [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                                          
                        }
                            
                    [self stopActivity];
                });
                                          
    }];
    
    [myDataTask resume];
    [self stopActivity];
        
    }
    [self stopActivity];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // [self saveContext];
}

#pragma mark - Delegates For Push Notifications

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    HomeNewDashBoardVC *push = [[HomeNewDashBoardVC alloc]init];
    [push getWorkflowsForPush:userInfo];
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionAlert);
}


// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    
    userInfo = [[NSDictionary alloc]init];
    userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    HomeNewDashBoardVC *push = [[HomeNewDashBoardVC alloc]init];

    [push getWorkflowsForPush:userInfo];

    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//
//    theRootVC  = [storyBoard instantiateViewControllerWithIdentifier:@"HomeNewDashBoardVC"];
//    self.window.rootViewController = theRootVC;
    
//    UINavigationController *navVC = (UINavigationController *)self.window.rootViewController;
//    UIViewController *topVC = navVC.topViewController;
//    NSLog(@"topVC: %@", topVC);
//    //Here BaseViewController is the root view, this will initiate on App launch also.
//   // if ([topVC isKindOfClass:[hom class]]) {
//        BaseViewController *baseVC = (BaseViewController *)topVC;
//        if ([baseVC isKindOfClass:[YourHomeVC class]]) {
//            YourHomeVC *homeVC = (YourHomeVC *)baseVC;
//            homeVC.notificationUserInfo = userInfo;
//        }
    //}
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler();
}

// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    
    //[[NSUserDefaults standardUserDefaults]valueForKey:@"FcmToken"]
    
//
//    "body" : "Welcome to Paperless Office",
//      "title": "emSigner Notification",
//      "WorkflowID" : "1234",
//     "workflowtype":1,
//    "DocumentName":"Appraisalletter.pdf",
//     "sentby":"Mark"
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:@"Welcome to Paperless Office" forKey:@"body"];
    [dict setValue:@"emSigner Notification" forKey:@"title"];
    [dict setValue:@"1234" forKey:@"WorkflowID"];
    [dict setValue:@"1" forKey:@"WorkflowType"];
    [dict setValue:@"Appraisalletter.pdf" forKey:@"DocumentName"];
    [dict setValue:@"Mark" forKey:@"SentBy"];

    
    NSUserDefaults *savePathForPdf = [NSUserDefaults standardUserDefaults];
    [savePathForPdf setValue:fcmToken forKey:@"FcmToken"];
    [savePathForPdf synchronize];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    
    
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
}
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"The generated device token string is : %@",deviceTokenString);
    [FIRMessaging messaging].APNSToken = deviceToken;
    
    // With swizzling disabled you must set the APNs device token here.
    // [FIRMessaging messaging].APNSToken = deviceToken;
}

#pragma mark - Push notifications

//
//-(void)getWorkflowsForPush:(NSDictionary*)userInfo{
//
//    _checkNullArray = [[NSMutableArray alloc]init];
//    _arr = [[NSMutableArray alloc]init];
//    _coordinatesArray = [[NSMutableArray alloc]init];
//    _pdfImageArray = [[NSMutableArray alloc]init];
//
//    NSString *requestURL = [NSString stringWithFormat:@"%@GetDocumentDetailsById?workFlowId=%@&workflowType=%@",kOpenPDFImage,[userInfo valueForKey:@"WorkflowID"],[userInfo valueForKey:@"workflowtype"]];
//
//    [WebserviceManager sendSyncRequestWithURLGet:requestURL method:SAServiceReqestHTTPMethodGET body:requestURL completionBlock:^(BOOL status, id responseValue) {
//
//        if(status && ![[responseValue valueForKey:@"Response"] isKindOfClass:[NSNull class]])
//        {
//            int issucess = [[responseValue valueForKey:@"IsSuccess"]intValue];
//
//            if (issucess != 0) {
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//
//                    _checkNullArray = [responseValue valueForKey:@"Response"];
//
//                    if (_checkNullArray == (id)[NSNull null])
//                    {
//                        UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//                        topWindow.rootViewController = [UIViewController new];
//                        topWindow.windowLevel = UIWindowLevelAlert + 1;
//
//                        UIAlertController * alert = [UIAlertController
//                                                     alertControllerWithTitle:@""
//                                                     message:@"This file has been corrupted."
//                                                     preferredStyle:UIAlertControllerStyleAlert];
//
//                        //Add Buttons
//
//                        UIAlertAction* yesButton = [UIAlertAction
//                                                    actionWithTitle:@"Ok"
//                                                    style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action) {
//                                                        //Handle your yes please button action here
//
//                                                    }];
//
//                        //Add your buttons to alert controller
//
//                        [alert addAction:yesButton];
//                        [topWindow makeKeyAndVisible];
//                        [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//                       // [self presentViewController:alert animated:YES completion:nil];
//                        [self stopActivity];
//
//                        return;
//                    }
//
//
//                    _arr =  [_checkNullArray valueForKey:@"Signatory"];
//
//                    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
//                    // NSData * data = [NSKeyedArchiver archivedDataWithRootObject:arr];
//                    [prefs setObject:_arr forKey:@"Signatory"];
//
//
//                    /////////////////alerts
//
//                    if (_arr.count > 0) {
//                        NSString * ischeck = @"ischeck";
//                        [mstrXMLString appendString:@"Signed By:"];
//
//                        for (int i = 0; _arr.count>i; i++) {
//                            NSDictionary * dict = _arr[i];
//
//                            //status id for parallel signing
//                            if ([dict[@"StatusID"]intValue] == 7) {
//                                // statusId = 1;
//                            }
//
//                            //displaying signatories on top .
//                            if ([dict[@"StatusID"]intValue] == 13) {
//                                NSString* emailid = dict[@"EmailID"];
//                                NSString* name = dict[@"Name"];
//                                NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
//
//                                if ([mstrXMLString containsString:[NSString stringWithFormat:@"%@",totalstring]]) {
//
//                                }
//                                else
//                                {
//                                    [mstrXMLString appendString:[NSString stringWithFormat:@" %@",totalstring]];
//                                }
//
//                                //[mstrXMLString appendString:[NSString stringWithFormat:@"Signed By: %@",totalstring]];
//                                ischeck = @"Signatory";
//                                NSLog(@"%@",mstrXMLString);
//                            }
//                        }
//                        if ([ischeck  isEqual: @"ischeck"])
//                        {
//                            NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"Originatory"];
//                            mstrXMLString = [NSMutableString string];
//
//                            [mstrXMLString appendString:@"Originated By:"];
//                            for (int i = 0; arr1.count > i; i++) {
//                                NSDictionary * dict = arr1[i];
//
//                                NSString* emailid = dict[@"EmailID"];
//                                NSString* name = dict[@"Name"];
//                                NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
//                                [mstrXMLString appendString:[NSString stringWithFormat:@" %@",totalstring]];
//                                NSLog(@"%@",mstrXMLString);
//                            }
//                        }
//                        //}
//                    }
//
//                    else
//                    {
//                        NSArray *arr1 =  [[responseValue valueForKey:@"Response"] valueForKey:@"Originatory"];
//                        [mstrXMLString appendString:@"Originated By:"];
//
//                        for (int i = 0; arr1.count > i; i++) {
//                            NSDictionary * dict = arr1[i];
//
//                            NSString* emailid = dict[@"EmailID"];
//                            NSString* name = dict[@"Name"];
//                            NSString * totalstring = [NSString stringWithFormat:@"%@[%@]",name,emailid];
//                            [mstrXMLString appendString:[NSString stringWithFormat:@"%@",totalstring]];
//                            NSLog(@"%@",mstrXMLString);
//                        }
//                    }
//
//                    // _coordinatesArray = [[NSMutableArray alloc]init];
//                    //Checking for signatorys and multiple PDF
//                    for (int i = 0; i<_arr.count; i++) {
//
//                        if ([[_arr[i]valueForKey:@"EmailID"] caseInsensitiveCompare:[[NSUserDefaults standardUserDefaults]valueForKey:@"Email"]] == NSOrderedSame)
//                        {
//                            // ([[[_checkNullArray valueForKey:@"CurrentStatus"]valueForKey:@"IsOpened"]intValue]== 1)
//                            if (([[_arr[i]valueForKey:@"StatusID"]integerValue] == 53)) {
//                                isdelegate = false;
//                                statusId = 0;
//                            }
//                            else if ([[_arr[i]valueForKey:@"StatusID"]integerValue] == 7){
//                                isdelegate = true;
//                                statusId = 1;
//                            }
//                            if ((([[_arr[i]valueForKey:@"StatusID"]integerValue] == 7)|| ([[_arr[i]valueForKey:@"StatusID"]integerValue] == 53)|| ([[_arr[i]valueForKey:@"StatusID"]integerValue] == 8))) {
//
//                                if ([[_arr[i]valueForKey:@"DocumentId"]integerValue]== [[[_checkNullArray valueForKey:@"DocumentId"]objectAtIndex:0]integerValue]) {
//                                    [_coordinatesArray addObject:_arr[i]];
//                                }
//                            }
//                        }
//                    }
//
//                    statusForPlaceholders = [_coordinatesArray valueForKey:@"StatusID"];
//
//                    //FileDataBytes
//                    _pdfImageArray=[[responseValue valueForKey:@"Response"] valueForKey:@"Document"];
//
//                    if (_pdfImageArray != (id)[NSNull null])
//                    {
//                        NSUserDefaults *statusIdForMultiplePdf = [NSUserDefaults standardUserDefaults];
//                        [statusIdForMultiplePdf setInteger:(long)statusId forKey:@"statusIdForMultiplePdf"];
//                        [statusIdForMultiplePdf synchronize];
//
//                        if ([[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue]==YES) {
//
//                            NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
//
//                            _pdfDocument = [[PDFDocument alloc] initWithData:data];
//
//                            //[userInfo valueForKey:@"WorkflowID"],[userInfo valueForKey:@"workflowtype"]];
//                            //workflow type  == 3
//
//                            if ([[userInfo valueForKey:@"workflowtype"]integerValue] == 3)
//                            {
//                                // [self parallelSigning:indexPath.row];
//
//                            }
//
//                            NSString *checkPassword = [[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"];
//                            [[NSUserDefaults standardUserDefaults] setObject:checkPassword forKey:@"checkPassword"];
//                            [[NSUserDefaults standardUserDefaults] synchronize];
//
//                            data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
//                            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//                            NSString *path = [documentsDirectory stringByAppendingPathComponent:[[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentName"]objectAtIndex:0]];
//                            [data writeToFile:path atomically:YES];
//
//
//                            [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"pathForDoc"];
//                            [[NSUserDefaults standardUserDefaults] synchronize];
//
//                            NSString *displayName = [[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentName"]objectAtIndex:0];
//                            [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:@"displayName"];
//                            [[NSUserDefaults standardUserDefaults] synchronize];
//
//                            NSString *docCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
//                            [[NSUserDefaults standardUserDefaults] setObject:docCount forKey:@"docCount"];
//                            [[NSUserDefaults standardUserDefaults] synchronize];
//
//                            NSString *attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
//                            [[NSUserDefaults standardUserDefaults] setObject:attachmentCount forKey:@"attachmentCount"];
//                            [[NSUserDefaults standardUserDefaults] synchronize];
//
//                            NSString *workflowId = [userInfo valueForKey:@"WorkflowID"];
//                            [[NSUserDefaults standardUserDefaults] setObject:workflowId forKey:@"workflowId"];
//                            [[NSUserDefaults standardUserDefaults] synchronize];
//
//
//
//                            if ([_pdfDocument isLocked]) {
//                                UIAlertView *passwordAlertView = [[UIAlertView alloc]initWithTitle: @"Password Protected"
//                                                                                           message:  [NSString stringWithFormat: @"%@ %@", path.lastPathComponent, @"is password protected"]
//                                                                                          delegate: self
//                                                                                 cancelButtonTitle: @"Cancel"
//                                                                                 otherButtonTitles: @"Done", nil];
//                                passwordAlertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
//                                [passwordAlertView show];
//                                return;
//
//                            }
//
//                            [self stopActivity];
//
//                        }
//                        else
//                        {
//
//                            NSData *data = [[NSData alloc]initWithBase64EncodedString:_pdfImageArray options:0];
//                            // from your converted Base64 string
//                            NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//                            NSString *path = [documentsDirectory stringByAppendingPathComponent:[[[responseValue valueForKey:@"Response"] valueForKey:@"DocumentName"]objectAtIndex:0]];
//                            [data writeToFile:path atomically:YES];
//
//                            CFUUIDRef uuid = CFUUIDCreate(NULL);
//                            CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
//                            CFRelease(uuid);
//
//                            UIImage *image = [UIImage imageNamed:@"signer.png"];
//
//                            if (_coordinatesArray.count != 0) {
//
//                            }
//                            //[self stopActivity];
//                            // return;
//                        }
//
//                        //workflow type  == 3
//                        //parallel signing
//                        if ([[userInfo valueForKey:@"workflowtype"]integerValue] == 3)
//                        {
//                            // [self parallelSigningNoPassword:indexPath.row];
//
//                        }
//
////                        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"data"];
////                        [[NSUserDefaults standardUserDefaults] synchronize];
//
//                        [[NSUserDefaults standardUserDefaults] setObject:_coordinatesArray forKey:@"coordinatesArray"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
//
//                        [[NSUserDefaults standardUserDefaults] setObject:_arr forKey:@"arr"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];
//
//                        if (isdelegate == true)
//                        {
//                            PendingListVC *temp = [[PendingListVC alloc]initWithNibName:@"PendingListVC" bundle:nil];
//
//                            temp.pdfImagedetail = _pdfImageArray;
//                            temp.workFlowID = [userInfo valueForKey:@"WorkFlowId"];
//                            temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
//                            temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
//                            temp.isPasswordProtected = [[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue];
//                            temp.myTitle = [userInfo valueForKey:@"DocumentName"];
//
//                            temp.signatoryString = mstrXMLString;
//                            temp.statusId = statusId;
//                            temp.signatoryHolderArray = _arr;
//                            temp.placeholderArray = _coordinatesArray;
//
//                            temp.workFlowType = [userInfo valueForKey:@"WorkflowType"];
//                            temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"]boolValue];
//                            temp.isReviewer = [[_checkNullArray valueForKey:@"IsReviewer"]boolValue];
//
//                                                        self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
//                                                        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:temp];
//                                                        self.window.rootViewController = nav;
//                                                        [self.window makeKeyAndVisible];
//
////                                                        UINavigationController *nav = (UINavigationController *) self.tabBarController.selectedViewController;
////
////                                                        [nav pushViewController:temp animated:YES];
////
//                            //  [self.navigationController pushViewController:temp animated:YES];
//
//                           // UINavigationController *navigationRootController = [[UINavigationController alloc] initWithRootViewController:temp];
//                         //   [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navigationRootController animated:YES completion:NULL];
//                            [self stopActivity];
//                        }
//                        else if(isdelegate == false){
//                            PendingListVC *temp = [[PendingListVC alloc]init];
//
//                            temp.pdfImagedetail = _pdfImageArray;
//                            temp.workFlowID = [userInfo valueForKey:@"WorkFlowId"];
//                            temp.documentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfDocuments"] stringValue];
//                            temp.attachmentCount = [[[responseValue valueForKey:@"Response"] valueForKey:@"NoOfAttachments"] stringValue];
//                            temp.isPasswordProtected = [[[responseValue valueForKey:@"Response"] valueForKey:@"IsPasswordProtected"] boolValue];
//                            temp.myTitle = [userInfo valueForKey:@"DocumentName"];
//                            temp.signatoryString = mstrXMLString;
//                            temp.statusId = statusId;
//                            temp.signatoryHolderArray = _arr;
//                            temp.placeholderArray = _coordinatesArray;
//                            temp.workFlowType = [userInfo valueForKey:@"WorkflowType"];
//                            temp.isSignatory = [[_checkNullArray valueForKey:@"IsSignatory"]boolValue];
//                            temp.isReviewer = [[_checkNullArray valueForKey:@"IsReviewer"]boolValue];
//
//                            UINavigationController *navigationRootController = [[UINavigationController alloc] initWithRootViewController:temp];
//                            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:navigationRootController animated:YES completion:NULL];
//                           // [self.navigationController pushViewController:temp animated:YES];
//                            [self stopActivity];
//                        }
//
//                    }
//                    else{
//
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message: @"This file was corrupted. Please contact eMudhra for more details." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                        [alert show];
//                        [self stopActivity];
//                    }
//                });
//
//            }
//            else{
//                //Alert at the time of no server connection
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message: @"Try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//                    [alert show];
//                    [self stopActivity];
//
//                });
//
//            }
//        }
//    }];
//}
@end
