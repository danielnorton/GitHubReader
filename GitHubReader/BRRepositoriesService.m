//
//  BRRepositoriesService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRRepositoriesService.h"
#import "BRGitHubApiService.h"
#import "BRRemoteService.h"
#import "NSDictionary+valueOrDefault.h"


@implementation BRRepositoriesService


#pragma mark -
#pragma mark BRRepositoriesService
- (BOOL)saveRepositoriesForGitLogin:(BRGHLogin *)gitHubLogin withLogin:(BRLogin *)login error:(NSError **)error {
	
	NSError* inError = nil;
	NSArray *json = [self getRemoteDataForGitLogin:gitHubLogin withLogin:login error:error];
	if (!json || inError) {
		
		*error = inError;
		return NO;
	}
	
	return [self saveRepositoriesData:json forGitLogin:gitHubLogin error:error];
}


#pragma mark Private Messages
- (NSArray *)getRemoteDataForGitLogin:(BRGHLogin *)gitHubLogin withLogin:(BRLogin *)login error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *api = [[BRGitHubApiService alloc] init];
	
	NSURL *url = [NSURL URLWithString:gitHubLogin.repositoriesPath];
	NSMutableURLRequest *request = [api requestFor:login atURL:url withHTTPMethod:BRHTTPMethodGet withHeaders:nil];
	
	NSURLResponse *response = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if (inError || !data) {
		
		*error = inError;
		return nil;
	}
	
	// Parse out the json response data
	NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
	if (inError || !json || [json isKindOfClass:[NSDictionary class]]) {
		
		*error = inError;
		return nil;
	}

	
	return json;
}

- (BOOL)saveRepositoriesData:(NSArray *)json forGitLogin:(BRGHLogin *)gitHubLogin error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *apiService = [[BRGitHubApiService alloc] init];
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	Class kind = [BRGHRepository class];
	NSString *key = BRGitHubIdKey;
	
	NSMutableArray *gitHubIds = [NSMutableArray arrayWithCapacity:0];
	
	[json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSDictionary *itemJson = (NSDictionary *)obj;

		NSNumber *gitHubId = itemJson[@"id"];
		[gitHubIds addObject:gitHubId];
		
		BRGHRepository *repo = (BRGHRepository *)[apiService findOrCreateObjectById:gitHubId
																			withKey:key
																			 ofKind:kind
																		  inContext:context];
		
		NSDate *created = [apiService dateFromJson:itemJson key:@"created_at"];
		NSDate *updated = [apiService dateFromJson:itemJson key:@"pushed_at"];

		NSString *branches = [apiService stripToken:@"{/branch}" inPathFromJson:itemJson atKey:@"branches_url"];
		NSString *commits = [apiService stripToken:@"{/sha}" inPathFromJson:itemJson atKey:@"commits_url"];
		NSString *trees = [apiService stripToken:@"{/sha}" inPathFromJson:itemJson atKey:@"trees_url"];
		
		[repo setBranchesPath:			branches];
		[repo setCommitsPath:			commits];
		[repo setCreated:				created];
		[repo setDefaultBranchName:		[itemJson objectForKey:@"default_branch" orDefault:nil]];
		[repo setFullName:				[itemJson objectForKey:@"full_name" orDefault:nil]];
		[repo setGitHubDescription:		[itemJson objectForKey:@"description" orDefault:nil]];
		[repo setName:					[itemJson objectForKey:@"name" orDefault:nil]];
		[repo setTreesPath:				trees];
		[repo setUpdated:				updated];

		[repo setOwner:gitHubLogin];
		[gitHubLogin addRepositoriesObject:repo];
	}];
	
	NSPredicate *pred = (gitHubIds.count > 0)
	? [NSPredicate predicateWithFormat:@"owner = %@ AND NOT (%K IN %@)", gitHubLogin, key, gitHubIds]
	: nil;
	if (![apiService deletePredicate:pred withKey:key ofKind:kind inContext:context error:&inError]) {
		
		*error = inError;
		return NO;
	}
		
	return [context save:error];
}


@end
