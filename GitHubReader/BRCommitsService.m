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



#pragma mark Private Messages
- (NSArray *)getRemoteDataForCommitsInRepository:(BRGHRepository *)repo
										   atSha:(NSString *)sha
										  atPage:(int)page
									   withLogin:(BRLogin *)login
										   error:(NSError **)error {
	
	NSError* inError = nil;
	BRGitHubApiService *api = [[BRGitHubApiService alloc] init];
	
	NSDictionary *params = @{
							 @"sha": sha,
							 @"per_page": @(_pageSize)
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
	if (inError || !json) {
		
		*error = inError;
		return nil;
	}
	
	return json;
}

@end
