//
//  MyAnnotation.m
//  PDFKit_Sample
//
//  Created by Sandeepan Swain on 10/03/19.
//  Copyright © 2019 emudhra. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

-(instancetype)initWithImage:(UIImage*)image withBounds:(CGRect)bounds withProperties:(nullable NSDictionary*)properties
{
    self = [super initWithBounds:bounds forType:PDFAnnotationSubtypeStamp withProperties:nil];
    if (self) {
        // perform initialization
        self.image= image;
    }
    return self;
}

- (void)drawWithBox:(PDFDisplayBox)box inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0.0, 2 * self.bounds.origin.y + self.bounds.size.height));
   
    [self.image drawInRect:self.bounds];
}

@end
