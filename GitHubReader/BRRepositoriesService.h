//
//  BRRepositoriesService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BRRepositoriesService : NSObject

- (BOOL)saveRepositoriesForGitLogin:(BRGHLogin *)gitHubLogin withLogin:(BRLogin *)login error:(NSError **)error;

@end
