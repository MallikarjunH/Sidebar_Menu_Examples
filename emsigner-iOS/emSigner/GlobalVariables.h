//
//  GlobalVariables.h
//  emSigner
//
//  Created by Mallikarjun on 28/07/20.
//  Copyright © 2020 Emudhra. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalVariables : NSObject

@property (strong, nonatomic) NSString *mySignatureCount;
@property (strong, nonatomic) NSString *waitingOthersCount;
@property (strong, nonatomic) NSString *declinedCount;
@property (strong, nonatomic) NSString *recalledCount;
@property (strong, nonatomic) NSString *completedCount;
@property (strong, nonatomic) NSString *documentId;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
