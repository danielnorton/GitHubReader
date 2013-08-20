//
//  BRLoginService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/17/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


extern NSString *const BRGitHubReaderSecurityService;


@interface BRLoginService : NSObject

@property (nonatomic, readonly, strong) BRLogin *user;

+ (BOOL)hasPasswordForLogin:(BRLogin *)user;
+ (NSArray *)getLoginNamesForService:(NSString *)serviceName;

- (id)initWithLogin:(BRLogin *)user;
- (NSString *)getPassword;
- (BOOL)setPassword:(NSString *)password;
- (BOOL)deletePassword;


@end
