//
//  BRGitHubApiService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BRGitHubApiService : NSObject

+ (NSURL *)gitHubApiRootPath;

- (NSMutableURLRequest *)requestFor:(BRLogin *)login
							  atURL:(NSURL *)url
					 withHTTPMethod:(NSString *)httpMethod
						withHeaders:(NSDictionary *)headers;

- (NSDate *)dateFromJson:(NSDictionary *)json key:(NSString *)key;

- (NSManagedObject *)findOrCreateObjectByIdConventionFrom:(NSDictionary *)json
												   ofType:(NSString *)entityName
												inContext:(NSManagedObjectContext *)context;

@end
