//
//  NSDictionary+valueOrDefault.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


@interface NSDictionary(valueOrDefault)
- (id)objectForKey:(NSString *)key orDefault:(id)aDefault;
@end
