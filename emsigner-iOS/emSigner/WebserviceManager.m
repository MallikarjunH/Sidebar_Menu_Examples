

#import "WebserviceManager.h"
#import "Connection.h"
#import "HoursConstants.h"


@interface WebserviceManager()
@property (nonatomic, strong) void(^requestCompletionBlock)(BOOL iSucceeded, id iResponseObject);
@property (nonatomic, strong) NSData *body;
@property (nonatomic, assign) SAServiceReqestHTTPMethod aHTTPMethod;
@property (nonatomic, copy) NSString *aURL;
@property (nonatomic, strong) NSString *signatureImageData;

@end
@implementation WebserviceManager

+(void)sendSyncRequestWithURL:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSString *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock {
  
    WebserviceManager *webService = [[self alloc] init];
    webService.requestCompletionBlock = iCompletionBlock;
    webService.aHTTPMethod = iHTTPMethod;
    webService.aURL = iRequestURL;
    webService.body = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [webService sendSyncRequestWithURL:iRequestURL method:iHTTPMethod];
}

+(void)sendSyncRequestWithURLLogin:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSString *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock{
    WebserviceManager *webService = [[self alloc] init];
    webService.requestCompletionBlock = iCompletionBlock;
    webService.aHTTPMethod = iHTTPMethod;
    webService.aURL = iRequestURL;
   webService.body = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [webService sendSyncRequestWithURLLogin:iRequestURL method:iHTTPMethod];
}
+(void)sendSyncRequestWithURLDocument:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSMutableArray *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock{
    WebserviceManager *webService = [[self alloc] init];
    webService.requestCompletionBlock = iCompletionBlock;
    webService.aHTTPMethod = iHTTPMethod;
    webService.aURL = iRequestURL;
    NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
    webService.body = [jsonString  dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [webService sendSyncRequestDocument:iRequestURL method:iHTTPMethod];
}


+(void)sendSyncRequestWithURLGet:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSString *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock
{
    
    WebserviceManager *webService = [[self alloc] init];
    webService.requestCompletionBlock = iCompletionBlock;
    webService.aHTTPMethod = iHTTPMethod;
    webService.aURL = iRequestURL;
    webService.body = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [webService sendSyncRequestWithURLGet:iRequestURL method:iHTTPMethod];
    
}

+(void)sendSyncRequestWithURLForgotPassword:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod body:(NSString *)body completionBlock:(SAServiceCompletionBlock)iCompletionBlock
{
    
    WebserviceManager *webService = [[self alloc] init];
    webService.requestCompletionBlock = iCompletionBlock;
    webService.aHTTPMethod = iHTTPMethod;
    webService.aURL = iRequestURL;
    webService.body = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [webService sendSyncRequestWithURLForgotPassword:iRequestURL method:iHTTPMethod];
    
}

//  +(void)sendSyncRequestWithURLForSignatureImage:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod WorkFlowId:(NSString *)iWorkFlowId signatureImage:(NSString *)iSignatureImage  completionBlock:(SAServiceCompletionBlock)iCompletionBlock
//{
//    WebserviceManager *webService =[[self alloc] init];
//    webService.requestCompletionBlock = iCompletionBlock;
//    webService.aHTTPMethod = iHTTPMethod;
//    webService.aURL = iRequestURL;
//    webService.signatureImageData = iSignatureImage;
//    //[[webService getConnection] sendRequest:[webService generateMutableRequestForChangeprofilePic:iSignatureImage name:iUserId profilePic:iSignatureImage andURL:iRequestURL]];
//    [[webService getConnection] sendRequest:[webService generateMutableRequestForSignatureImage:iSignatureImage WorkFlowId:iWorkFlowId ImageData:iSignatureImage andURL:iRequestURL]];
//}

- (void)requestDidSucceedWithResponse:(id)iResponse {
    if (self.requestCompletionBlock) {
        self.requestCompletionBlock(YES, iResponse);
    }
} 

- (void)requestDidFailWithResponse:(id)iResponse {
    if (self.requestCompletionBlock) {
        self.requestCompletionBlock(NO, iResponse);
    }
}

-(NSMutableURLRequest *)generateMutableRequestLogin:(NSData *)body andURL:(NSString *)url
{
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *fcmToken = [[NSUserDefaults standardUserDefaults]valueForKey:@"FcmToken"];
    
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:[self requestHTTPMethodStringWithType:self.aHTTPMethod]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
//                            stringForKey:@"Token"];
    [request setValue:[[@"Basic" stringByAppendingString:@" "] stringByAppendingString:@"4767e127b1a2493d9796eee3f6830c0d"] forHTTPHeaderField:@"Authorization"];
    [request setValue:fcmToken forHTTPHeaderField:@"DeviceId"];
    [request setHTTPBody:body];
    return request;
}

-(NSMutableURLRequest *)generateMutableRequestDocument:(NSData *)body andURL:(NSString *)url
{
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:[self requestHTTPMethodStringWithType:self.aHTTPMethod]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                               stringForKey:@"Token"];
    //    //[request setValue:@"Basic" @"JVrPinpqCswfsGO1io6yCq1j0eeMwUZ8MyGzdg1Oi17FJj6mL2+3cLY4Wqjh6mb4" forHTTPHeaderField:@"Authorization"];
        [request setValue:[[@"Basic" stringByAppendingString:@" "] stringByAppendingString:savedValue] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:body];
    return request;
}

-(NSMutableURLRequest *)generateMutableRequest:(NSData *)body andURL:(NSString *)url {
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:[self requestHTTPMethodStringWithType:self.aHTTPMethod]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"Token"];
    //[request setValue:@"Basic" @"JVrPinpqCswfsGO1io6yCq1j0eeMwUZ8MyGzdg1Oi17FJj6mL2+3cLY4Wqjh6mb4" forHTTPHeaderField:@"Authorization"];
    [request setValue:[[@"Basic" stringByAppendingString:@" "] stringByAppendingString:savedValue] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:body];
    return request;
}

-(NSMutableURLRequest *)generateMutableRequestGet:(NSData *)body andURL:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"Token"];
    [request setValue:[[@"Basic" stringByAppendingString:@" "] stringByAppendingString:savedValue] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:[self requestHTTPMethodStringWithType:self.aHTTPMethod]];
    return request;
}

-(NSMutableURLRequest *)generateMutableRequestForgotPassword:(NSData *)body andURL:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:[[@"Basic" stringByAppendingString:@" "] stringByAppendingString:@"4767e127b1a2493d9796eee3f6830c0d"] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:[self requestHTTPMethodStringWithType:self.aHTTPMethod]];
    return request;
}



//-(NSMutableURLRequest *)generateMutableRequestForSignatureImage:(NSString *)imageData WorkFlowId:(NSString *)iWorkFlowId ImageData:(NSString *)iImageData andURL:(NSString *)url
//{
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:[NSURL URLWithString:url]];
//    NSString *savedValue = [[NSUserDefaults standardUserDefaults]
//                            stringForKey:@"Token"];
//    [request setValue:[[@"Basic" stringByAppendingString:@" "] stringByAppendingString:savedValue] forHTTPHeaderField:@"Authorization"];
//    [request setHTTPMethod:@"post"];
//    NSString *boundary = @"---------------------------14737809831466499882746641449";
//    NSString *contentType = [NSString stringWithFormat:@"%@", boundary];
//    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
//    
//    NSMutableData *postBody = [NSMutableData data];
//    //----------------------------------WorkFlowId--------------------------------------
//    
//    
//    
//    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"WorkflowId\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [postBody appendData:[[NSString stringWithString:iWorkFlowId] dataUsingEncoding:NSUTF8StringEncoding]];
//    [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    
//    //----------------------------------ImageData-----------------------
//    
//    
//    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [postBody appendData:[@"Content-Disposition: attachment; name=\"SignatureImage\"; filename=\".png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [postBody appendData:[[NSString stringWithString:iImageData] dataUsingEncoding:NSUTF8StringEncoding]];
//    //[postBody appendData:[NSData dataWithData:iImageData]];
//    [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [request setHTTPBody:postBody];
//    
//    
//    
//    return request;
//
//}


- (NSString *)requestHTTPMethodStringWithType:(SAServiceReqestHTTPMethod)iHTTPMethod {
    NSString *aRequestHTTPMethodString = nil;
    
    switch (iHTTPMethod) {
        case SAServiceReqestHTTPMethodPOST: {
            aRequestHTTPMethodString = kServiceRequestHTTPMethodPOST;
            break;
        }
            
        case SAServiceReqestHTTPMethodGET: {
            aRequestHTTPMethodString = kServiceRequestHTTPMethodGET;
            break;
        }
            
        case SAServiceReqestHTTPMethodPUT: {
            aRequestHTTPMethodString = kServiceRequestHTTPMethodPUT;
            break;
        }
            
        default:
            break;
    }
    
    return aRequestHTTPMethodString;
}

- (Connection *)getConnection {
    Connection *aServiceRequest = [[Connection alloc] init];
    aServiceRequest.delegate = (id)self;
    return aServiceRequest;
}

- (void)sendSyncRequestWithURL:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod {
    
    Connection *aServiceRequest = [[Connection alloc] init];
    aServiceRequest.delegate = (id)self;
    [aServiceRequest sendRequest:[self generateMutableRequest:self.body andURL:self.aURL]];
    
}

- (void)sendSyncRequestWithURLLogin:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod {
    
    Connection *aServiceRequest = [[Connection alloc] init];
    aServiceRequest.delegate = (id)self;
    [aServiceRequest sendRequest:[self generateMutableRequestLogin:self.body andURL:self.aURL]];
    
}
- (void)sendSyncRequestDocument:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod {
    
    Connection *aServiceRequest = [[Connection alloc] init];
    aServiceRequest.delegate = (id)self;
    [aServiceRequest sendRequest:[self generateMutableRequestDocument:self.body andURL:self.aURL]];
    
}

-(void)sendSyncRequestWithURLGet:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod{
    
    Connection *aServiceRequest = [[Connection alloc] init];
    aServiceRequest.delegate = (id)self;
    [aServiceRequest sendRequest:[self generateMutableRequestGet:self.body andURL:self.aURL]];
    
}
-(void)sendSyncRequestWithURLForgotPassword:(NSString *)iRequestURL method:(SAServiceReqestHTTPMethod)iHTTPMethod{
    
    Connection *aServiceRequest = [[Connection alloc] init];
    aServiceRequest.delegate = (id)self;
    [aServiceRequest sendRequest:[self generateMutableRequestForgotPassword:self.body andURL:self.aURL]];
    
}

@end
