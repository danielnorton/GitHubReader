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

- (NSManagedObject *)findOrCreateObjectByIdConventionFrom:(NSDictionary *)json
												   ofType:(NSString *)entityName
												inContext:(NSManagedObjectContext *)context {
	
	NSNumber *gitHubId = json[@"id"];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",kModelGitHubId, gitHubId];
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *desc = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[fetch setReturnsDistinctResults:YES];
	[fetch setEntity:desc];
	[fetch setPredicate:pred];
	
	NSError *error = nil;
	NSArray *matches = [context executeFetchRequest:fetch error:&error];
	if (error) return nil;
	
	if (matches && matches.count > 0) {
		
		return [matches lastObject];
	}
	
	NSManagedObject *newOne = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
	[newOne setValue:gitHubId forKey:kModelGitHubId];
	return newOne;
}

- (BOOL)deleteExcept:(NSArray *)gitHubIds ofKind:(Class)kind error:(NSError **)error {
	
	NSError* inError = nil;
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	
	NSSortDescriptor *gitHubId = [NSSortDescriptor sortDescriptorWithKey:@"gitHubId" ascending:YES];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass(kind)
											  inManagedObjectContext:context];
	
	
	NSPredicate *pred = (gitHubIds && gitHubIds.count > 0)
	? [NSPredicate predicateWithFormat:@"NOT (gitHubId IN %@)", gitHubIds]
	: nil;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:@[gitHubId]];
	[fetchRequest setPredicate:pred];
	
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
