//
//  BRUserService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/12/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//



@interface BRUserService : NSObject

- (BOOL)generateOAuthTokenForUser:(NSString *)userName withPassword:(NSString *)password error:(NSError **)error;

@end
