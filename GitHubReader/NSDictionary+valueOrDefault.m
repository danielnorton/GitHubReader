//
//  NSDictionary+valueOrDefault.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "NSDictionary+valueOrDefault.h"

@implementation NSDictionary(valueOrDefault)

- (id)objectForKey:(NSString *)key orDefault:(id)aDefault {
	
	id value = [self valueForKeyPath:key];
	if ([value isEqual:[NSNull null]] || value == nil) {
		
		return aDefault;
	}
	
	return value;
}

@end
