//
//  BRGravatarService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/19/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


@interface BRGravatarService : NSObject

@property (readonly, nonatomic) NSCache *thumbnailCache;

+ (NSURL *)urlForGravatarWithHash:(NSString *)hash ofSize:(int)size;
- (void)saveGravatarsForLogin:(BRGHLogin *)login ofSize:(int)size;
- (UIImage *)cachedImageForLogin:(BRGHLogin *)login;

@end
