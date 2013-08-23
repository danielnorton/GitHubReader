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


@interface BROrganizationService()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end


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

- (void)beginSaveOrganizationsForGitLogin:(BRGHUser *)gitHubUser withLogin:(BRLogin *)login withCompletion:(void (^)(BOOL saved, NSError *error))completion {
	
	dispatch_queue_t serviceQueue = dispatch_queue_create("BROrganizationService queue", NULL);
	dispatch_async(serviceQueue, ^{
		
		NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:[[BRModelManager sharedInstance] persistentStoreCoordinator]];
		
		BROrganizationService *service = [[BROrganizationService alloc] init];
		[service setContext:context];
		
		BRGHUser *thisUser = (BRGHUser *)[context objectWithID:gitHubUser.objectID];
		
		NSError *error = nil;
		BOOL answer = [service saveOrganizationsForGitLogin:thisUser withLogin:login error:&error];
		
		if (completion) {
			
			dispatch_async(dispatch_get_main_queue(), ^{

				if (answer && !error) {
					
					NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
					[context reset];
				}
				
				completion(answer, error);
			});
		}
	});
}

#pragma mark Private Messages
- (NSArray *)getRemoteDataForGitLogin:(BRGHUser *)gitHubUser withLogin:(BRLogin *)login error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *api = [[BRGitHubApiService alloc] init];
	
	NSURL *url = [NSURL URLWithString:gitHubUser.organizationsPath];
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

- (BOOL)saveOrganizationsData:(NSArray *)json forGitLogin:(BRGHUser *)gitHubUser error:(NSError **)error {
	
	if (!_context) {
		
		NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
		[self setContext:context];
	}
	
	NSError* inError = nil;
	BRGitHubApiService *apiService = [[BRGitHubApiService alloc] init];
	
	Class kind = [BRGHOrganization class];
	NSString *key = BRGitHubIdKey;
	
	NSMutableArray *gitHubIds = [NSMutableArray arrayWithCapacity:0];
	
	[json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
	
		NSDictionary *itemJson = (NSDictionary *)obj;
		
		NSNumber *gitHubId = itemJson[@"id"];
		[gitHubIds addObject:gitHubId];
		
		BRGHOrganization *org = (BRGHOrganization *)[apiService findOrCreateObjectById:gitHubId
																			   withKey:key
																				ofKind:kind
																			 inContext:_context];
		
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
		[org setSortIndex:				@(1)];
		[org setIsAuthenticated:		gitHubUser.isAuthenticated];
		[org setUser:					gitHubUser];
	}];
	
	NSPredicate *pred = (gitHubIds.count > 0)
	? [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", key, gitHubIds]
	: nil;
	if (![apiService deletePredicate:pred withKey:key ofKind:kind inContext:_context error:&inError]) {
		
		*error = inError;
		return NO;
	}

	return [_context save:error];
}


@end
