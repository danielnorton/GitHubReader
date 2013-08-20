//
//  BRGravatarService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/19/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRGravatarService.h"

@implementation BRGravatarService


#pragma mark -
#pragma mark BRGravatarService
+ (NSURL *)urlForGravatarWithHash:(NSString *)hash ofSize:(int)size {
	
	NSString *gravatarPath = [NSString stringWithFormat:@"https://gravatar.com/avatar/%@?s=%i", hash, size];
	return [NSURL URLWithString:gravatarPath];
}

+ (UIImage *)imageForGravatarWithHash:(NSString *)hash ofSize:(int)size {
	
	NSURL *url = [self urlForGravatarWithHash:hash ofSize:size];
	UIImage *gravatarDownload = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
	return [UIImage imageWithCGImage:[gravatarDownload CGImage] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
}


@end
