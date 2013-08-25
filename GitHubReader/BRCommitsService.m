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


@interface BRCommitsService()

@property (strong, nonatomic) NSManagedObjectContext *context;

@end


@implementation BRCommitsService


#pragma mark -
#pragma mark BRBranchService
- (BOOL)saveCommitsForRepository:(BRGHRepository *)repo
						   atSha:(NSString *)sha
					withPageSize:(int)pageSize
					   withLogin:(BRLogin *)login
			   shouldPurgeOthers:(BOOL)purge
						   error:(NSError **)error {
	
	NSError *inError = nil;
	NSArray *json = [self getRemoteDataForCommitsInRepository:repo atSha:sha withPageSize:pageSize withLogin:login error:&inError];
	if (!json || inError) {
		
		*error = inError;
		return NO;
	}
	
	return [self saveCommitsData:json shouldPurgeOthers:purge forForRepository:repo error:error];
}

- (void)beginSaveCommitsForRepository:(BRGHRepository *)repo
								atSha:(NSString *)sha
						 withPageSize:(int)pageSize
							withLogin:(BRLogin *)login
					shouldPurgeOthers:(BOOL)purge
					   withCompletion:(void (^)(BOOL saved, NSError *error))completion {
	
	dispatch_queue_t serviceQueue = dispatch_queue_create("BRCommitsService queue", NULL);
	dispatch_async(serviceQueue, ^{
		
		NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:[[BRModelManager sharedInstance] persistentStoreCoordinator]];
		
		BRCommitsService *service = [[BRCommitsService alloc] init];
		[service setContext:context];
		
		BRGHRepository *thisRepo = (BRGHRepository *)[context objectWithID:repo.objectID];
		
		NSError *error = nil;
		BOOL answer = [service saveCommitsForRepository:thisRepo atSha:sha withPageSize:pageSize withLogin:login shouldPurgeOthers:purge error:&error];
		
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
- (NSArray *)getRemoteDataForCommitsInRepository:(BRGHRepository *)repo
										   atSha:(NSString *)sha
									withPageSize:(int)pageSize
									   withLogin:(BRLogin *)login
										   error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *api = [[BRGitHubApiService alloc] init];
	
	NSDictionary *params = @{
							 @"sha": sha,
							 @"per_page": @(pageSize)
							 };
	
	BRRemoteService *service = [[BRRemoteService alloc] init];
	NSString *path = [service pathFromURLPath:repo.commitsPath withQueryStringParams:params];
	NSURL *url = [NSURL URLWithString:path];
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

- (BOOL)saveCommitsData:(NSArray *)json shouldPurgeOthers:(BOOL)purge forForRepository:(BRGHRepository *)repo error:(NSError **)error {
	
	if (!_context) {
		
		NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
		[self setContext:context];
	}
	
	NSError* inError = nil;
	BRGitHubApiService *apiService = [[BRGitHubApiService alloc] init];
	
	// Fetch all the json commits that already exist in the database
	// Sort them out to a dictionary so that each loop through the json
	// array doesn't also have to also loop through the old commits
	// every time
	Class kind = [BRGHCommit class];
	NSString *key = BRShaKey;
	NSArray *shas = [json valueForKeyPath:@"@distinctUnionOfObjects.sha"];
	NSSortDescriptor *shaSort = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
	NSArray *oldCommitsArray = [apiService findObjectsByIds:shas
													withKey:key
													 ofKind:kind
										withSortDescriptors:@[shaSort]
												  inContext:_context];
	NSMutableDictionary *oldCommits = [NSMutableDictionary dictionaryWithCapacity:0];
	[oldCommitsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		BRGHCommit *commit = (BRGHCommit *)obj;
		[oldCommits setObject:commit forKey:commit.sha];
	}];

	
	// Do the same for the Authors.
	Class authorKind = [BRGHUser class];
	NSString *authorKey = BRGitHubIdKey;
	NSMutableArray *authorIds = [NSMutableArray arrayWithArray:[json valueForKeyPath:@"@distinctUnionOfObjects.committer.id"]];
	NSSortDescriptor *authorIdSort = [NSSortDescriptor sortDescriptorWithKey:authorKey ascending:YES];
	NSArray *oldAuthorsArray = [apiService findObjectsByIds:authorIds
											   withKey:authorKey
												ofKind:authorKind
								   withSortDescriptors:@[authorIdSort]
											 inContext:_context];
	NSMutableDictionary *oldAuthors = [NSMutableDictionary dictionaryWithCapacity:0];
	[oldAuthorsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		BRGHUser *user = (BRGHUser *)obj;
		NSString *gitHubId = [NSString stringWithFormat:@"%i", user.gitHubId.integerValue];
		[oldAuthors setObject:user forKey:gitHubId];
	}];
	
	
	[json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSDictionary *itemJson = (NSDictionary *)obj;
		
		NSString *sha = (NSString *)[itemJson valueForKeyPath:@"sha"];
		
		BRGHCommit *commit = oldCommits[sha];
		if (!commit) {
			
			commit = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(kind) inManagedObjectContext:_context];
			[commit setSha:sha];
		}
		
		NSDate *date = [apiService dateFromJson:itemJson key:@"commit.committer.date"];
		
		[commit setDate:				date];
		[commit setMessage:				[itemJson objectForKey:@"commit.message" orDefault:nil]];
		[commit setParentSha:			[itemJson objectForKey:@"parents.@max.sha" orDefault:nil]];
		[commit setPath:				[itemJson objectForKey:@"url" orDefault:nil]];
		[commit setSha:					[itemJson objectForKey:@"sha" orDefault:nil]];
		[commit setRepository:repo];
		
		
		NSNumber *gitHubId = [itemJson objectForKey:@"committer.id" orDefault:nil];
		if (!gitHubId) return;
		
		NSString *gitHubIdString = [NSString stringWithFormat:@"%i", gitHubId.integerValue];
		BRGHUser *author = oldAuthors[gitHubIdString];
		if (!author) {
			
			author = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(authorKind) inManagedObjectContext:_context];
			[author setGitHubId:gitHubId];
			[oldAuthors setValue:author forKey:gitHubIdString];
		}

		[author setGravatarId:				[itemJson objectForKey:@"author.gravatar_id" orDefault:nil]];
		[author setName:					[itemJson objectForKey:@"author.login" orDefault:nil]];
		[commit setAuthor:author];
	}];
	
	if (purge) {
		
		NSPredicate *pred = (shas.count > 0)
		? [NSPredicate predicateWithFormat:@"repository = %@ AND NOT (%K IN %@)", repo, key, shas]
		: nil;
		if (![apiService deletePredicate:pred withKey:key ofKind:kind inContext:_context error:&inError]) {
			
			*error = inError;
			return NO;
		}
	}
	
	return [_context save:error];
}


@end
