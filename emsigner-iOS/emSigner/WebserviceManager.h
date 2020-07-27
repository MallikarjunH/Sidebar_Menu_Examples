

#import <Foundation/Foundation.h>

typedef enum {
    SAServiceReqestHTTPMethodPOST,
    SAServiceReqestHTTPMethodPUT,
    SAServiceReqestHTTPMethodGET
} SAServiceReqestHTTPMethod;

typedef void (^SAServiceCompletionBlock)(BOOL iSucceeded, id iResponseObject);
typedef void (^SAAsyncRequestCompletionBlock)(NSURLResponse *iResponse, NSData *iData, NSError *iError);

@interface WebserviceManager : NSObject



+(void)sendSyncRequestWithURL:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSString *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock;

+(void)sendSyncRequestWithURLGet:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSString *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock;

+(void)sendSyncRequestWithURLForgotPassword:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSString *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock;

+(void)sendSyncRequestWithURLLogin:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSString *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock;

+(void)sendSyncRequestWithURLDocument:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSMutableArray *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock;
//+(void)sendSyncRequestWithURLForSignatureImage:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod WorkFlowId:(NSString *)iWorkFlowId signatureImage:(NSString *)iSignatureImage  completionBlock:(SAServiceCompletionBlock)iCompletionBlock;

@end
