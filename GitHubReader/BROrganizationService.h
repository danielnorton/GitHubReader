//
//  BROrganizationService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BROrganizationService : NSObject

- (BOOL)saveOrganizationsForGitLogin:(BRGHUser *)gitHubUser withLogin:(BRLogin *)login error:(NSError **)error;
- (void)beginSaveOrganizationsForGitLogin:(BRGHUser *)gitHubUser withLogin:(BRLogin *)login withCompletion:(void (^)(BOOL saved, NSError *error))completion;
@end
