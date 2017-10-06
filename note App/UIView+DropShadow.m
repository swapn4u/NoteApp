//
//  UIView+DropShadow.m
//  note App
//
//  Created by webwerks on 06/10/17.
//  Copyright © 2017 webwerks. All rights reserved.
//

#import "UIView+DropShadow.h"

@implementation UIView (DropShadow)
- (void)addDropShadow:(UIColor *)color
           withOffset:(CGSize)offset
               radius:(CGFloat)radius
              opacity:(CGFloat)opacity
{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
}
-(void)DefaultShadow
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(1, 5);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 1.0;
}
@end
