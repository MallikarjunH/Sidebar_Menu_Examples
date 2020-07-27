

#import "SingletonAPI.h"

@implementation SingletonAPI
+ (SingletonAPI*)sharedInstance
{
    // 1
    static SingletonAPI *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SingletonAPI alloc] init];
        _sharedInstance.changePasswordDict = [[NSMutableDictionary alloc] init];
        _sharedInstance.pdfImageArray = [[NSMutableArray alloc] init];
    });
    return _sharedInstance;
}

@end
