//
//  AppDelegate.h
//  emSigner
//
//  Created by Administrator on 7/12/16.
//  Copyright © 2016 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagesForPageViewController.h"
#import <PDFKit/PDFKit.h>
#import <Intents/Intents.h>

@import Firebase;

@interface AppDelegate : UIResponder <UIApplicationDelegate,FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property(nonatomic,strong)NSString *popUP;
@property(nonatomic,assign) BOOL isLoggedIn;

@property(nonatomic,strong)NSMutableArray *checkNullArray, *arr, *coordinatesArray, *pdfImageArray;
@property (strong, nonatomic) PDFDocument *pdfDocument;

-(NSString *)strCheckNull:(NSString *)myStrting;
+(AppDelegate *)AppDelegateInstance;


@end

