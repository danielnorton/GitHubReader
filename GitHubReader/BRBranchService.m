//
//  BRBranchService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRBranchService.h"
#import "BRGitHubApiService.h"
#import "BRRemoteService.h"
#import "NSDictionary+valueOrDefault.h"


@implementation BRBranchService


#pragma mark -
#pragma mark BRBranchService
- (BOOL)saveBranchesForRepository:(BRGHRepository *)repo withLogin:(BRLogin *)login error:(NSError **)error {
	
	NSError* inError = nil;
	NSArray *json = [self getRemoteDataForBranchesForRepository:repo withLogin:login error:&inError];
	if (!json || inError) {
		
		*error = inError;
		return NO;
	}
	
	return [self saveBranchesData:json forForRepository:repo error:error];
}


#pragma mark Private Messages
- (NSArray *)getRemoteDataForBranchesForRepository:(BRGHRepository *)repo withLogin:(BRLogin *)login error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *api = [[BRGitHubApiService alloc] init];
	
	NSURL *url = [NSURL URLWithString:repo.branchesPath];
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

- (BOOL)saveBranchesData:(NSArray *)json forForRepository:(BRGHRepository *)repo error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *apiService = [[BRGitHubApiService alloc] init];
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	Class kind = [BRGHBranch class];
	NSString *key = BRShaKey;
	
	NSMutableArray *shas = [NSMutableArray arrayWithCapacity:0];
	NSString *defaultBranch = [repo.defaultBranchName lowercaseString];
	
	[json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSDictionary *itemJson = (NSDictionary *)obj;
		
		NSString *sha = (NSString *)[itemJson valueForKeyPath:@"commit.sha"];
		[shas addObject:sha];
		
		BRGHBranch *branch = (BRGHBranch *)[apiService findOrCreateObjectById:sha
																	  withKey:key
																	   ofKind:kind
																	inContext:context];
		
		[branch setName:[itemJson objectForKey:@"name" orDefault:nil]];
		[branch setIsDefault:@([defaultBranch isEqualToString:[branch.name lowercaseString]])];
		[branch setRepository:repo];
	}];
	
	NSPredicate *pred = (shas.count > 0)
	? [NSPredicate predicateWithFormat:@"repository = %@ AND NOT (%K IN %@)", repo, key, shas]
	: nil;
	if (![apiService deletePredicate:pred withKey:key ofKind:kind inContext:context error:&inError]) {
		
		*error = inError;
		return NO;
	}
	
	return [context save:error];
}


@end

