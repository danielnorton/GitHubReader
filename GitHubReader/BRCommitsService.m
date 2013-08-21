//
//  BRCommitsService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRCommitsService.h"
#import "BRGitHubApiService.h"
#import "BRRemoteService.h"
#import "NSDictionary+valueOrDefault.h"


@implementation BRCommitsService


#pragma mark -
#pragma mark BRBranchService
- (BOOL)saveCommitsForRepository:(BRGHRepository *)repo
						   atSha:(NSString *)sha
						  atPage:(int)page
					withPageSize:(int)pageSize
					   withLogin:(BRLogin *)login
						   error:(NSError **)error{
	
	NSError* inError = nil;
	NSArray *json = [self getRemoteDataForCommitsInRepository:repo atSha:sha atPage:page withPageSize:pageSize withLogin:login error:&inError];
	if (!json || inError) {
		
		*error = inError;
		return NO;
	}
	
	return [self saveCommitsData:json atPage:page forForRepository:repo error:error];
}


#pragma mark Private Messages
- (NSArray *)getRemoteDataForCommitsInRepository:(BRGHRepository *)repo
										   atSha:(NSString *)sha
										  atPage:(int)page
									withPageSize:(int)pageSize
									   withLogin:(BRLogin *)login
										   error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *api = [[BRGitHubApiService alloc] init];
	
	NSDictionary *params = @{
							 @"sha": sha,
							 @"per_page": @(pageSize),
							 @"page": @(page)
							 };

	BRRemoteService *service = [[BRRemoteService alloc] init];
	NSString *path = [service pathFromURLPath:repo.commitsPath withQueryStringParams:params];
	NSURL *url = [NSURL URLWithString:path];
	NSMutableURLRequest *request = [api requestFor:login atURL:url withHTTPMethod:BRHTTPMethodGet withHeaders:nil];
	
	
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
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

- (BOOL)saveCommitsData:(NSArray *)json atPage:(int)page forForRepository:(BRGHRepository *)repo error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *apiService = [[BRGitHubApiService alloc] init];
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];

	Class kind = [BRGHCommit class];
	NSString *key = BRShaKey;
	
	Class committerKind = [BRGHUser class];
	NSString *committerKey = BRGitHubIdKey;
	
	NSMutableArray *shas = [NSMutableArray arrayWithCapacity:0];
	NSMutableArray *committerIds = [NSMutableArray arrayWithCapacity:0];
	
	[json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSDictionary *itemJson = (NSDictionary *)obj;
		
		NSString *sha = (NSString *)[itemJson valueForKeyPath:@"sha"];
		[shas addObject:sha];
		
		BRGHCommit *commit = (BRGHCommit *)[apiService findOrCreateObjectById:sha
																	  withKey:key
																	   ofKind:kind
																	inContext:context];
		
		NSDate *date = [apiService dateFromJson:itemJson key:@"commit.committer.date"];
		
		[commit setDate:				date];
		[commit setMessage:				[itemJson objectForKey:@"commit.message" orDefault:nil]];
		[commit setParentSha:			[itemJson objectForKey:@"parents.@max.sha" orDefault:nil]];
		[commit setPath:				[itemJson objectForKey:@"url" orDefault:nil]];
		[commit setSha:					[itemJson objectForKey:@"sha" orDefault:nil]];
		[commit setRepository:repo];
		
		
		NSNumber *gitHubId = [itemJson objectForKey:@"committer.id" orDefault:nil];
		if (!gitHubId) return;
		
		[committerIds addObject:gitHubId];
		BRGHUser *committer = (BRGHUser *)[apiService findOrCreateObjectById:gitHubId
																	 withKey:committerKey
																	  ofKind:committerKind
																   inContext:context];
		
		[committer setLongName:				[itemJson objectForKey:@"committer.name" orDefault:nil]];
		[committer setGravatarId:			[itemJson objectForKey:@"committer.gravatar_id" orDefault:nil]];
		[committer setName:					[itemJson objectForKey:@"committer.login" orDefault:nil]];
		[commit setCommitter:committer];
	}];
	
	if (page <= 1) {

		NSPredicate *pred = (shas.count > 0)
		? [NSPredicate predicateWithFormat:@"repository = %@ AND NOT (%K IN %@)", repo, key, shas]
		: nil;
		if (![apiService deletePredicate:pred withKey:key ofKind:kind inContext:context error:&inError]) {
			
			*error = inError;
			return NO;
		}
	}
	
	return [context save:error];
}


@end
