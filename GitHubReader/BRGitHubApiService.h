//
//  BRGitHubApiService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"

extern NSString *const BRGitHubIdKey;
extern NSString *const BRShaKey;
extern NSString *const BRIfModifiedSinceHeader;
extern NSString *const BRLastModifiedHeader;
extern int const BRHTTPNotModified;

@interface BRGitHubApiService : NSObject

+ (NSURL *)gitHubApiRootPath;

- (NSMutableURLRequest *)requestFor:(BRLogin *)login
							  atURL:(NSURL *)url
					 withHTTPMethod:(NSString *)httpMethod
						withHeaders:(NSDictionary *)headers;

- (NSMutableURLRequest *)requestFor:(BRLogin *)login
							  atURL:(NSURL *)url
					 withHTTPMethod:(NSString *)httpMethod
						cachePolicy:(NSURLRequestCachePolicy)cachePolicy
						withHeaders:(NSDictionary *)headers;

- (NSDate *)dateFromJson:(NSDictionary *)json key:(NSString *)key;

- (NSString *)stripToken:(NSString *)token inPathFromJson:(NSDictionary *)json atKey:(NSString *)key;
- (NSString *)stripTokens:(NSArray *)tokens inPath:(NSString *)path;
- (NSString *)replaceTokens:(NSDictionary *)tokens inPath:(NSString *)path;

- (NSManagedObject *)findOrCreateObjectById:(id)objectId
									withKey:(NSString *)key
									 ofKind:(Class)kind
								  inContext:(NSManagedObjectContext *)context;

- (NSArray *)findObjectsByIds:(NSArray *)objectIds
					  withKey:(NSString *)key
					   ofKind:(Class)kind
		  withSortDescriptors:(NSArray *)sortDescriptors
					inContext:(NSManagedObjectContext *)context;

- (BOOL)deletePredicate:(NSPredicate *)predicate
				withKey:(NSString *)key
				 ofKind:(Class)kind
			  inContext:(NSManagedObjectContext *)context
				  error:(NSError **)error;

@end
