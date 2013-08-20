//
//  BRGravatarService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/19/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


@interface BRGravatarService : NSObject

+ (NSURL *)urlForGravatarWithHash:(NSString *)hash ofSize:(int)size;
+ (UIImage *)imageForGravatarWithHash:(NSString *)hash ofSize:(int)size;

@end