//
//  BRGitHubApiService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRGitHubApiService.h"
#import "BRLoginService.h"
#import "BRBasicAuthenticationService.h"
#import "NSDictionary+valueOrDefault.h"

#define kModelGitHubId @"gitHubId"


NSString *const BRGitHubIdKey = @"gitHubId";
NSString *const BRShaKey = @"sha";


@implementation BRGitHubApiService


static NSURL *gitHubApiRoot;
static NSDateFormatter *gitDateFormatter;

#pragma mark -
#pragma mark NSObject
+ (void)initialize {
	
	gitHubApiRoot = [NSURL URLWithString:@"https://api.github.com"];

	gitDateFormatter = [[NSDateFormatter alloc] init];
	[gitDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	[gitDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
}


#pragma mark -
#pragma mark BRRemoteService
#pragma mark Public Messages
+ (NSURL *)gitHubApiRootPath {

	return gitHubApiRoot;
}

- (NSMutableURLRequest *)requestFor:(BRLogin *)login
							  atURL:(NSURL *)url
					 withHTTPMethod:(NSString *)httpMethod
						withHeaders:(NSDictionary *)headers {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringCacheData
															timeoutInterval:30.0f];
	[request setHTTPMethod:httpMethod];
	
	NSMutableDictionary *allHeaders = [NSMutableDictionary dictionaryWithDictionary:headers ? headers : @{}];
	
	if ([BRLoginService hasPasswordForLogin:login]) {

		BRLoginService *loginService = [[BRLoginService alloc] initWithLogin:login];
		NSString *password = [loginService getPassword];
		
		NSDictionary *authHeaders = [BRBasicAuthenticationService headerDictionaryForUser:login.name withPassword:password];
		[allHeaders addEntriesFromDictionary:authHeaders];
	}
	
	[allHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if (![obj isKindOfClass:[NSString class]]) return;
		
		NSString *value = (NSString *)obj;
		[request setValue:value forHTTPHeaderField:key];
	}];
	
	return request;
}

- (NSDate *)dateFromJson:(NSDictionary *)json key:(NSString *)key {

	NSString *raw = [json objectForKey:key orDefault:nil];
	return raw
	? [gitDateFormatter dateFromString:raw]
	: nil;
}

- (NSString *)stripToken:(NSString *)token inPathFromJson:(NSDictionary *)json atKey:(NSString *)key {

	NSString *start = [json objectForKey:key orDefault:nil];
	return start
	? [self stripTokens:@[token] inPath:start]
	: nil;
}

- (NSString *)stripTokens:(NSArray *)tokens inPath:(NSString *)path {

	NSMutableDictionary *nulls = [NSMutableDictionary dictionaryWithCapacity:0];
	[tokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		[nulls setObject:[NSNull null] forKey:(NSString *)obj];
	}];
	
	return [self replaceTokens:nulls inPath:path];
}

- (NSString *)replaceTokens:(NSDictionary *)tokens inPath:(NSString *)path {
	
	__block NSString *replace = path;
	[tokens enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		NSString *token = (NSString *)key;
		if (![token isKindOfClass:[NSString class]]) return;
		
		NSString *value = [obj isKindOfClass:[NSString class]]
		? (NSString *)obj
		: [NSString string];
		replace = [replace stringByReplacingOccurrencesOfString:token withString:value];
	}];
	
	return replace;
}

- (NSManagedObject *)findOrCreateObjectById:(id)objectId
									withKey:(NSString *)key
									 ofKind:(Class)kind
								  inContext:(NSManagedObjectContext *)context {
	
	NSString *entityName = NSStringFromClass(kind);
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",key, objectId];
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *desc = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[fetch setReturnsDistinctResults:YES];
	[fetch setEntity:desc];
	[fetch setPredicate:pred];
	[fetch setFetchBatchSize:5];
	
	NSError *error = nil;
	NSArray *matches = [context executeFetchRequest:fetch error:&error];
	if (error) return nil;
	
	if (matches && matches.count > 0) {
		
		return [matches lastObject];
	}
	
	NSManagedObject *newOne = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
	[newOne setValue:objectId forKey:key];
	return newOne;
}

- (NSArray *)findObjectsByIds:(NSArray *)objectIds
					  withKey:(NSString *)key
					   ofKind:(Class)kind
		  withSortDescriptors:(NSArray *)sortDescriptors
					inContext:(NSManagedObjectContext *)context {

	NSString *entityName = NSStringFromClass(kind);
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(%K IN %@)",key, objectIds];
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *desc = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[fetch setReturnsDistinctResults:YES];
	[fetch setEntity:desc];
	[fetch setPredicate:pred];
	[fetch setSortDescriptors:sortDescriptors];
	[fetch setFetchBatchSize:10];
	
	NSError *error = nil;
	NSArray *matches = [context executeFetchRequest:fetch error:&error];
	if (error) return nil;
	
	return matches;
}

- (BOOL)deletePredicate:(NSPredicate *)predicate
				withKey:(NSString *)key
				 ofKind:(Class)kind
			  inContext:(NSManagedObjectContext *)context
				  error:(NSError **)error {
	
	NSError* inError = nil;
	
	NSSortDescriptor *gitHubId = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(kind)
											  inManagedObjectContext:context];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:@[gitHubId]];
	[fetchRequest setPredicate:predicate];
	
	NSArray *all = [context executeFetchRequest:fetchRequest error:&inError];
	if (!all || inError)   {
		
		*error = inError;
		return NO;
	}
	
	
	[all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSManagedObject *one = (NSManagedObject *)obj;
		[context deleteObject:one];
	}];
	
	return YES;
}


@end
