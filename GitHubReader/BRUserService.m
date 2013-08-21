//
//  BRUserService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/16/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRUserService.h"
#import "BRBasicAuthenticationService.h"
#import "BRLoginService.h"
#import "BRModel.h"
#import "NSDictionary+valueOrDefault.h"


@implementation BRUserService

#pragma mark -
#pragma mark BRUserService
- (BRGHUser *)getUser:(NSString *)userName withPassword:(NSString *)password error:(NSError **)error {
	
	// Verbose construction of syncronous request. All the code
	// is 'right here' to make the demo easier to follow
	NSError* inError = nil;
	
	// Create the request object and set all the pertainant HTTP parts
	NSURL *url = [NSURL URLWithString:@"https://api.github.com/user"];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringCacheData
															timeoutInterval:30.0f];
	[request setHTTPMethod:@"GET"];
	
	// Set Basic Auth headers
	NSDictionary *headers = [BRBasicAuthenticationService headerDictionaryForUser:userName withPassword:password];
	if (!headers) return nil;
	
	[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if (![obj isKindOfClass:[NSString class]]) return;
		
		NSString *value = (NSString *)obj;
		[request setValue:value forHTTPHeaderField:key];
	}];
	
	// Now make the syncronous call
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&inError];
	if (inError || !data) {
		
		*error = inError;
		return nil;
	}
	

	// Parse out the json response data
	NSDictionary *returnJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&inError];
	if (inError || !returnJson) {
		
		*error = inError;
		return nil;
	}
	
	if (returnJson[@"message"]) return nil;
	
	BRLogin *login = [[BRLogin alloc] init];
	[login setName:userName];
	[login setService:BRGitHubReaderSecurityService];
	
	BRLoginService *service = [[BRLoginService alloc] initWithLogin:login];
	[service setPassword:password];

	return [self saveUserData:returnJson];
}


#pragma mark Private Messages
- (BRGHUser *)saveUserData:(NSDictionary *)json {
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	NSString *entityName = NSStringFromClass([BRGHUser class]);
	
	NSNumber *gitHubId = json[@"id"];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",@"gitHubId", gitHubId];
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription *desc = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[fetch setReturnsDistinctResults:YES];
	[fetch setEntity:desc];
	[fetch setPredicate:pred];
	
	NSError *error = nil;
	NSArray *matches = [context executeFetchRequest:fetch error:&error];
	if (error) return nil;
	
	BRGHUser *user = (matches && matches.count > 0)
	? [matches lastObject]
	: [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];

	[user setGitHubId:				gitHubId];
	[user setLongName:				[json objectForKey:@"name" orDefault:nil]];
	[user setOrganizationsPath:		[json objectForKey:@"organizations_url" orDefault:nil]];
	[user setGravatarId:			[json objectForKey:@"gravatar_id" orDefault:nil]];
	[user setName:					[json objectForKey:@"login" orDefault:nil]];
	[user setPath:					[json objectForKey:@"url" orDefault:nil]];
	[user setRepositoriesPath:		[json objectForKey:@"repos_url" orDefault:nil]];
	[user setSortIndex:				@(0)];
	[user setIsAuthenticated:		@(YES)];
	
	
	[context save:&error];
	 
	if(error) return nil;
	
	return user;
}


@end
