//
//  BRBasicAuthenticationService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/17/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


@interface BRBasicAuthenticationService : NSObject

+ (NSDictionary *)headerDictionaryForUser:(NSString *)userName withPassword:(NSString *)password;

@end
