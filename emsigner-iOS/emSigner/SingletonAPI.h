

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SingletonAPI : NSObject
{

}

@property (nonatomic, strong) NSString *name;
+ (SingletonAPI*)sharedInstance;
@property (nonatomic, strong) NSMutableDictionary *changePasswordDict;
@property (nonatomic, strong) NSMutableArray *pdfImageArray;

@end
