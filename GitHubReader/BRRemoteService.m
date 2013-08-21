//
//  BRRemoteService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRRemoteService.h"
#import "NSDictionary+join.h"


NSString *const BRHTTPContentTypeJson = @"application/json";
NSString *const BRHTTPContentTypeForm = @"application/x-www-form-urlencoded";

NSString *const BRHTTPMethodGet = @"GET";
NSString *const BRHTTPMethodPost = @"POST";


@implementation BRRemoteService


#pragma mark -
#pragma mark BRRemoteService
- (void)updateRequest:(NSMutableURLRequest *)request withJson:(id)json withContentType:(NSString *)contentType {
	
	NSError *error = nil;
	NSData *paramsData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
	if (!paramsData || error) return;
	
	NSString *paramsString = [[NSString alloc] initWithData:paramsData encoding:NSUTF8StringEncoding];
	
	NSData *postData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:postData];
	
	if (contentType && contentType.length >0) {
		
		[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
	}
	
	NSString *length = [NSString stringWithFormat:@"%i", paramsString.length];
	[request setValue:length forHTTPHeaderField:@"Content-Length"];
}

- (NSString *)pathFromURLPath:(NSString *)path withQueryStringParams:(NSDictionary *)params; {
	
	NSString *paramsString = [params join];
	return (paramsString && paramsString.length > 0)
	? [NSString stringWithFormat:@"%@?%@", path, paramsString]
	: path;
}


@end
