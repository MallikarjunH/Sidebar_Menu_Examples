//
//  GHWalkThroughCell.h
//  GHWalkThrough
//  emSigner
//
//  Created by EMUDHRA on 12/12/18.
//  Copyright © 2018 Emudhra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHWalkThroughPageCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *titleImage;
@property (nonatomic, assign) CGFloat imgPositionY;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) CGFloat titlePositionY;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) UIFont *descFont;
@property (nonatomic, strong) UIColor *descColor;
@property (nonatomic, assign) CGFloat descPositionY;

//updated

@end
