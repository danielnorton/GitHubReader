//
//  UIColor+Helpers.h
//
//  Created by Daniel Norton on 6/23/10.
//  Copyright 2010 LeanKit, Inc. All rights reserved.
//


@interface UIColor(Helpers)

+ (UIColor *)colorFrom255Red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
+ (UIColor *)colorFrom255Red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(NSInteger)alpha;

+ (UIColor *)colorFromWebRGB:(NSString *)rgb;
+ (UIColor *)colorFromWebRGB:(NSString *)rgb alpha:(float)alpha;


@end
