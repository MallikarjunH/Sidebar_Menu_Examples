//
//  NSString+DateAsAppleTime.h
//  emSigner
//
//  Created by Emudhra on 28/12/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (DateAsAppleTime)

- (NSString*)transformedValue:(NSDate *)date;
- (NSAttributedString*)refreshForDate;

@end
