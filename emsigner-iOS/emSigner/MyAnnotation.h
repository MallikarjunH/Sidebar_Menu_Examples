//
//  MyAnnotation.h
//  PDFKit_Sample
//
//  Created by Sandeepan Swain on 10/03/19.
//  Copyright © 2019 rajubd49. All rights reserved.
//

#import <PDFKit/PDFKit.h>
#import <UIKit/UIKit.h>
#import "Foundation/Foundation.h"


NS_ASSUME_NONNULL_BEGIN

@interface MyAnnotation : PDFAnnotation


//@property (nonatomic, assign) CGRect rect;
@property (strong,nonatomic) UIImage*image;

-(instancetype)initWithImage:(UIImage*)image withBounds:(CGRect)bounds withProperties:(nullable NSDictionary*)properties;

@end

NS_ASSUME_NONNULL_END
