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


@implementation BRUserService

#pragma mark -
#pragma mark BRUserService
- (BOOL)getUser:(NSString *)userName withPassword:(NSString *)password error:(NSError **)error {
	
	// Verbose construction of syncronous request. All the code
	// is 'right here' to make the demo easier to follow
	
	// Create the request object and set all the pertainant HTTP parts
	NSURL *url = [NSURL URLWithString:@"https://api.github.com/user"];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringCacheData
															timeoutInterval:30.0f];
	[request setHTTPMethod:@"GET"];
	
	// Set Basic Auth headers
	NSDictionary *headers = [BRBasicAuthenticationService headerDictionaryForUser:userName withPassword:password];
	if (!headers) return NO;
	
	[headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		
		if (![obj isKindOfClass:[NSString class]]) return;
		
		NSString *value = (NSString *)obj;
		[request setValue:value forHTTPHeaderField:key];
	}];
	
	// Now make the syncronous call
	NSURLResponse *response = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
	if (*error || !data) return NO;
	

	// Parse out the json response data
	NSDictionary *returnJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
	if (*error || !returnJson) return NO;
	
	BRLogin *login = [[BRLogin alloc] init];
	[login setName:userName];
	[login setService:BRGitHubReaderSecurityService];
	
	BRLoginService *service = [[BRLoginService alloc] initWithLogin:login];
	[service setPassword:password];

	
	return YES;
}


@end
