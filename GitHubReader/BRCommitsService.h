//
//  BRCommitsService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BRCommitsService : NSObject

- (BOOL)saveCommitsForRepository:(BRGHRepository *)repo
						   atSha:(NSString *)sha
						  atPage:(int)page
					withPageSize:(int)pageSize
					   withLogin:(BRLogin *)login
						   error:(NSError **)error;

@end
