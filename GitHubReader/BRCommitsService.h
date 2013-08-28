//
//  BRCommitsService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BRCommitsService : NSObject

- (void)beginSaveCommitsForRepository:(BRGHRepository *)repo
					   atHeadOfBranch:(BRGHBranch *)branch
						 withPageSize:(int)pageSize
							withLogin:(BRLogin *)login
					   withCompletion:(void (^)(BOOL saved, NSError *error))completion;

- (void)beginSaveCommitsForRepository:(BRGHRepository *)repo
							 atCommit:(BRGHCommit *)commit
						 withPageSize:(int)pageSize
							withLogin:(BRLogin *)login
					   withCompletion:(void (^)(BOOL saved, NSError *error))completion;

@end
