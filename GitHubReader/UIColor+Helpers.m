//
//  UIColor+Helpers.m
//
//  Created by Daniel Norton on 6/23/10.
//  Copyright 2010 LeanKit, Inc. All rights reserved.
//

#import "UIColor+Helpers.h"


@implementation UIColor(Helpers)

static float max = 255.0f;

+(UIColor *)colorFrom255Red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
	return [UIColor colorFrom255Red:red green:green blue:blue alpha:max];
}

+(UIColor *)colorFrom255Red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(NSInteger)alpha {
	
	return [UIColor colorWithRed:red/max green:green/max blue:blue/max alpha:alpha/max];
}


+ (UIColor *)colorFromWebRGB:(NSString *)rgb {
	return [UIColor colorFromWebRGB:rgb alpha:1.0f];
}

+ (UIColor *)colorFromWebRGB:(NSString *)rgb alpha:(float)alpha {
	
	NSString *fixed = [@"0x" stringByAppendingString:[rgb stringByReplacingOccurrencesOfString:@"#" withString:[NSString string]]];

	uint value;
	NSScanner *scanner = [NSScanner scannerWithString:fixed];
	[scanner scanHexInt:&value];
	
	float r = ((float)((value & 0xFF0000) >> 16))/max;
	float g = ((float)((value & 0xFF00) >> 8))/max;
	float b = ((float)(value & 0xFF))/max;
	
	return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}


@end

