//
//  BRBranchService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BRBranchService : NSObject

- (BOOL)saveBranchesForRepository:(BRGHRepository *)repo withLogin:(BRLogin *)login error:(NSError **)error;

- (void)beginSaveBranchesForRepository:(BRGHRepository *)repo
							 withLogin:(BRLogin *)login
						withCompletion:(void (^)(BOOL saved, NSError *error))completion;
@end
