//
//  BRBasicAuthenticationService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/17/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRBasicAuthenticationService.h"
#import "NSData+Base64.h"


@implementation BRBasicAuthenticationService


#pragma mark -
#pragma mark BRBasicAuthenticationService
+ (NSDictionary *)headerDictionaryForUser:(NSString *)userName withPassword:(NSString *)password {
	
	NSString *auth = [self basicAuthStringFromUser:userName withPassword:password];
	NSDictionary *headers = auth
	? @{@"Authorization" : auth}
	: nil;
	
	return headers;
}


#pragma mark Private Messages
+ (NSString *)basicAuthStringFromUser:(NSString *)userName withPassword:(NSString *)password {
	
	if (!userName || userName.length <= 0) return nil;
	if (!password || password.length == 0) return nil;
	
	NSString *raw = [NSString stringWithFormat:@"%@:%@", userName, password];
	NSData *data = [raw dataUsingEncoding:[NSString defaultCStringEncoding]];
	NSString *encoded = [[data base64EncodedString] stringByReplacingOccurrencesOfString:@"\r\n" withString:[NSString string]];
	
	return [NSString stringWithFormat:@"BASIC %@", encoded];
}


@end
