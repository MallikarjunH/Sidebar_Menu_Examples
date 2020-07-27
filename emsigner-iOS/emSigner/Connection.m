//
//  Connection.m
//  WebServiceCall.1
//
//  Created by Nawin Kumar on 12/23/14.
//  Copyright (c) 2014 Nawin Kumar. All rights reserved.
//

#import "Connection.h"

static  NSString *kAccessToken = @"AccessToken";
@implementation Connection




-(void)sendRequest:(NSMutableURLRequest *)urlRequest {
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFailWithResponse:)]) {
                [self.delegate requestDidFailWithResponse:error];
            }
        }
        
        else {
            
            self.responseData = [data mutableCopy];
            [self parseResponse];
        }
    }] resume];
    // memory management issues
    [session finishTasksAndInvalidate];
}

- (void)parseResponse
{
    if (self.responseData)
    {
        
        NSError *anError = nil;
        id aResponseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:&anError];
        
        if (anError != nil) {
            // If the parsing of the data fails, read the data in the NSISOLatin1StringEncoding and reconvert it to NSUTF8StringEncoding.
            anError = nil;
            NSString *aJsonString = [[NSString alloc] initWithData:self.responseData encoding:NSISOLatin1StringEncoding];
            aResponseDictionary = [NSJSONSerialization JSONObjectWithData:[aJsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&anError];
            
            if (anError != nil) {
                NSLog(@"Parsing the response failed : Error : %@", [anError localizedDescription]);
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFailWithResponse:)]) {
                    [self.delegate requestDidFailWithResponse:anError];
                }

                [self purgeRequest];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidSucceedWithResponse:)]) {
                    [self.delegate requestDidSucceedWithResponse:aResponseDictionary];
                }
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidSucceedWithResponse:)]) {
                [self.delegate requestDidSucceedWithResponse:aResponseDictionary];
            }
        }
    }
}

- (void)purgeRequest {
    // Clear the response data.
    self.responseData = [NSMutableData dataWithLength:0];
}

@end
