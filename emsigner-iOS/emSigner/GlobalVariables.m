//
//  GlobalVariables.m
//  emSigner
//
//  Created by Mallikarjun on 28/07/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

#import "GlobalVariables.h"

@implementation GlobalVariables

+ (instancetype)sharedInstance
{
    static GlobalVariables *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GlobalVariables alloc] init];
        NSLog(@"SingleTon-GlobalVariables");
    });
    return sharedInstance;
}

@end
