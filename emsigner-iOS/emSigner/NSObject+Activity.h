//
//  NSObject+Activity.h
//  Greencard
//
//  Created by Ghadeer Joma on 3/22/14.
//  Copyright (c) 2014 Ahmad Tareq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Activity)

-(void)startActivity:(NSString *)status;
-(void)stopActivity;
//-(void)startActivity_DetailPage;
//-(void)stopActivity_DetailPage;
-(void)didFailWithTimeOut;
@end
