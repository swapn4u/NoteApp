//
//  UIView+DropShadow.h
//  note App
//
//  Created by webwerks on 06/10/17.
//  Copyright © 2017 webwerks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DropShadow)
- (void)addDropShadow:(UIColor *)color
           withOffset:(CGSize)offset
               radius:(CGFloat)radius
              opacity:(CGFloat)opacity;
-(void)DefaultShadow;
@end
