//
//  Connection.h
//  WebServiceCall.1
//
//  Created by Nawin Kumar on 12/23/14.
//  Copyright (c) 2014 Nawin Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConnectionDelegate.h"
#import "WebserviceManager.h"
typedef void (^Callback)(BOOL isSuccess, id object);
@protocol WebServiceDelegate <NSObject>

- (void)requestDidSucceedWithResponse:(id)iResponse;
- (void)requestDidFailWithResponse:(id)iResponse;

@end

@interface Connection : NSObject
{
    
}

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) id <WebServiceDelegate> delegate;

//-(void)getDataByCallingTheService;
-(void)sendRequest:(NSMutableURLRequest *)urlRequest;
@end
