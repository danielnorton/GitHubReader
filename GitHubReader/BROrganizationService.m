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
	
	NSError* inError = nil;
	NSArray *json = [self getRemoteDataForGitLogin:gitHubUser withLogin:login error:error];
	if (!json || inError) {
		
		*error = inError;
		return NO;
	}
	
	return [self saveOrganizationsData:json forGitLogin:gitHubUser error:error];
}


#pragma mark Private Messages
- (NSArray *)getRemoteDataForGitLogin:(BRGHUser *)gitHubUser withLogin:(BRLogin *)login error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *api = [[BRGitHubApiService alloc] init];
	
	NSURL *url = [NSURL URLWithString:gitHubUser.organizationsPath];
	NSMutableURLRequest *request = [api requestFor:login atURL:url withHTTPMethod:BRHTTPMethodGet withHeaders:nil];
	
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
	if (inError || !data) {
		
		*error = inError;
		return nil;
	}
	
	// Parse out the json response data
	NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
	if (inError || !json) {
		
		*error = inError;
		return nil;
	}
	
	return json;
}

- (BOOL)saveOrganizationsData:(NSArray *)json forGitLogin:(BRGHUser *)gitHubUser error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *apiService = [[BRGitHubApiService alloc] init];
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	NSString *entityName = NSStringFromClass([BRGHOrganization class]);
	
	NSMutableArray *gitHubIds = [NSMutableArray arrayWithCapacity:0];
	
	[json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
	
		NSDictionary *itemJson = (NSDictionary *)obj;
		BRGHOrganization *org = (BRGHOrganization *)[apiService findOrCreateObjectByIdConventionFrom:itemJson
																							  ofType:entityName
																						   inContext:context];
		
		[gitHubIds addObject:itemJson[@"id"]];
		
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
	
	if (![self deleteExcept:gitHubIds error:&inError])  {
		
		*error = inError;
		return NO;
	}

	
	return [context save:error];
}

- (BOOL)deleteExcept:(NSArray *)gitHubIds error:(NSError **)error {
	
	NSError* inError = nil;
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	
	NSSortDescriptor *gitHubId = [NSSortDescriptor sortDescriptorWithKey:@"gitHubId" ascending:YES];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([BRGHOrganization class])
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
