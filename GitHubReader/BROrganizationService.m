//
//  BROrganizationService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BROrganizationService.h"
#import "BRGitHubApiService.h"
#import "BRRemoteService.h"
#import "NSDictionary+valueOrDefault.h"


@implementation BROrganizationService


#pragma mark -
#pragma mark BROrganizationService
- (BOOL)saveOrganizationsForGitLogin:(BRGHUser *)gitHubUser withLogin:(BRLogin *)login error:(NSError **)error {
	
	NSArray *json = [self getRemoteDataForGitLogin:gitHubUser withLogin:login error:error];
	if (!json || *error) return NO;
	
	return [self saveOrganizationsData:json forGitLogin:gitHubUser error:error];
}


#pragma mark Private Messages
- (NSArray *)getRemoteDataForGitLogin:(BRGHUser *)gitHubUser withLogin:(BRLogin *)login error:(NSError **)error {
	
	BRGitHubApiService *api = [[BRGitHubApiService alloc] init];
	
	NSURL *url = [NSURL URLWithString:gitHubUser.organizationsPath];
	NSMutableURLRequest *request = [api requestFor:login atURL:url withHTTPMethod:BRHTTPMethodGet withHeaders:nil];
	
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
	if (*error || !data) return nil;
	
	// Parse out the json response data
	NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
	if (*error || !json) return nil;
	
	return json;
}

- (BOOL)saveOrganizationsData:(NSArray *)json forGitLogin:(BRGHUser *)gitHubUser error:(NSError **)error {
	
	BRGitHubApiService *apiService = [[BRGitHubApiService alloc] init];
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	NSString *entityName = NSStringFromClass([BRGHOrganization class]);
	
	[json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
	
		NSDictionary *itemJson = (NSDictionary *)obj;
		BRGHOrganization *org = (BRGHOrganization *)[apiService findOrCreateObjectByIdConventionFrom:itemJson
																							  ofType:entityName
																						   inContext:context];
		
		NSString *avatarPath = [itemJson objectForKey:@"avatar_url" orDefault:nil];
		NSString *gravitarId = nil;
		if (avatarPath) {
			
			NSURL *avatarUrl = [NSURL URLWithString:avatarPath];
			gravitarId = avatarUrl.lastPathComponent;
		}
		
		[org setName:					[itemJson objectForKey:@"login" orDefault:nil]];
		[org setGravatarId:				gravitarId];
		[org setPath:					[itemJson objectForKey:@"url" orDefault:nil]];
		[org setRepositoriesPath:		[itemJson objectForKey:@"repos_url" orDefault:nil]];
		[org setSortIndex:@(1)];
	}];
	
	return [context save:error];
}


@end
