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
	
	NSMutableArray *branches = [NSMutableArray arrayWithCapacity:0];
	NSString *defaultBranch = [repo.defaultBranchName lowercaseString];
	
	[json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSDictionary *itemJson = (NSDictionary *)obj;
		
		NSString *sha = (NSString *)[itemJson valueForKeyPath:@"commit.sha"];
		NSString *name = itemJson[@"name"];
		if (!sha || !name) return;
		
		BRGHBranch *branch = (BRGHBranch *)[self findOrCreateBranchForRepository:repo
																		withName:name
																		 withSha:sha
																	inContext:context];
		
		[branch setIsDefault:@([defaultBranch isEqualToString:[branch.name lowercaseString]])];
		
		[branches addObject:branch];
	}];
	
	NSPredicate *pred = (branches.count > 0)
	? [NSPredicate predicateWithFormat:@"repository = %@ AND NOT (SELF IN %@)", repo, branches]
	: nil;
	if (![apiService deletePredicate:pred withKey:key ofKind:kind inContext:context error:&inError]) {
		
		*error = inError;
		return NO;
	}
	
	return [context save:error];
}

- (BRGHBranch *)findOrCreateBranchForRepository:(BRGHRepository *)repo
									   withName:(NSString *)name
										withSha:(NSString *)sha
									  inContext:(NSManagedObjectContext *)context {

	NSString *entityName = NSStringFromClass([BRGHBranch class]);
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"repository == %@ AND name == %@ AND sha == %@",repo, name.lowercaseString, sha];
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
	
	BRGHBranch *newOne = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
	[newOne setName:name];
	[newOne setSha:sha];
	[newOne setRepository:repo];
	
	return newOne;
}


@end

