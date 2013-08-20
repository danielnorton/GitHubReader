//
//  BRLoginService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/17/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import <Security/Security.h>
#import "BRLoginService.h"



NSString *const BRGitHubReaderSecurityService = @"BRGitHubReaderSecurityService";


@interface BRLoginService()

@property (nonatomic, strong) BRLogin *user;

@end

@implementation BRLoginService


#pragma mark -
#pragma mark BRLoginService
#pragma mark Public Messages
+ (BOOL)hasPasswordForLogin:(BRLogin *)user {

	if (!user) return NO;
	BRLoginService *service = [[BRLoginService alloc] initWithLogin:user];
	NSString *password = [service getPassword];
	return (password && password.length > 0);
}

+ (NSArray *)getLoginNamesForService:(NSString *)serviceName {
	
	BRLoginService *service = [[BRLoginService alloc] init];
	
	__block NSMutableArray *matches = [NSMutableArray arrayWithCapacity:0];
	
	[service findKeychainItemsForServiceName:serviceName
							   whenFound:^(NSArray *found) {
								   
								   [found enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
									   
									   NSDictionary *rFound = (NSDictionary *)obj;
									   NSData *userNameData = rFound[(__bridge id)kSecAttrAccount];
									   NSString *userName = [[NSString alloc] initWithData:userNameData encoding:NSUTF8StringEncoding];
									   [matches addObject:userName];
								   }];
							   }
	 
						  whenDidNotFind:nil];
	
	return [matches copy];
}

- (id)initWithLogin:(BRLogin *)user {
	
	self = [super init];
	if (self) {
		
		_user = user;
	}
	
	return self;
}

- (NSString *)getPassword {
	
	__block NSString *password = nil;
	
	[self findKeychainItemForUserName:_user.name
						  serviceName:_user.service
					   findAttributes:NO
							whenFound:^(id found) {
								
								NSData *passwordData = (NSData *)found;
								password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
							}
	 
					   whenDidNotFind:nil];
	
	NSString *returnPassword = password
	? [NSString stringWithString:password]
	: nil;
	
	return returnPassword;
}

- (BOOL)setPassword:(NSString *)password {
	
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	__block OSStatus err = noErr;
	
	[self findKeychainItemForUserName:_user.name
						  serviceName:_user.service
					   findAttributes:YES
							whenFound:^(id found) {
								
								NSDictionary *rFound = (NSDictionary *)found;
								NSMutableDictionary *changeQuery = [NSMutableDictionary dictionaryWithDictionary:rFound];
								[changeQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
								
								NSDictionary *changeData = @{
															 (__bridge id)kSecValueData : passwordData
															 };
								
								err = SecItemUpdate((__bridge CFDictionaryRef)changeQuery, (__bridge CFDictionaryRef)changeData);
							}
	 
					   whenDidNotFind:^(NSDictionary * query) {
						   
						   NSMutableDictionary *setter = [NSMutableDictionary dictionaryWithDictionary:query];
						   [setter removeObjectForKey:(__bridge id)kSecMatchCaseInsensitive];
						   [setter removeObjectForKey:(__bridge id)kSecReturnAttributes];
						   [setter setObject:passwordData forKey:(__bridge id)kSecValueData];
						   
						   err = SecItemAdd((__bridge CFDictionaryRef)setter, NULL);
					   }];
	
	return (err == noErr);
}

- (BOOL)deletePassword {
	
	__block OSStatus err = noErr;
	
	[self findKeychainItemForUserName:_user.name
						  serviceName:_user.service
					   findAttributes:YES
							whenFound:^(id found) {
								
								NSDictionary *rFound = (NSDictionary *)found;
								NSMutableDictionary *changeQuery = [NSMutableDictionary dictionaryWithDictionary:rFound];
								[changeQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
								
								err = SecItemDelete((__bridge CFDictionaryRef)changeQuery);
							}
	 
					   whenDidNotFind:nil];
	
	return (err == noErr);
}

- (void)findKeychainItemForUserName:(NSString *)userName
						serviceName:(NSString *)serviceName
					 findAttributes:(BOOL)findAttributes
						  whenFound:(void(^)(id found))doFound
					 whenDidNotFind:(void(^)(NSDictionary *query))doNotFound {
	
	
	if (!userName || !serviceName) return;
	
	NSData *userNameData = [userName dataUsingEncoding:NSUTF8StringEncoding];
	NSData *serviceNameData = [serviceName dataUsingEncoding:NSUTF8StringEncoding];
	
	id returnParam = findAttributes
	? (__bridge id)kSecReturnAttributes
	: (__bridge id)kSecReturnData;
	
	NSDictionary *query = @{
							(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
							(__bridge id)kSecAttrAccount : userNameData,
							(__bridge id)kSecAttrService : serviceNameData,
							(__bridge id)kSecMatchCaseInsensitive : (__bridge id)kCFBooleanTrue,
							returnParam : (__bridge id)kCFBooleanTrue
							};
	
	CFDataRef found = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*) &found);
	
	if (err == noErr) {
		
		if (doFound) {
			
			doFound((__bridge id)found);
		}
		
		
	} else {
		
		if (doNotFound) {
			
			doNotFound(query);
		}
	}
}

- (void)findKeychainItemsForServiceName:(NSString *)serviceName
							  whenFound:(void(^)(NSArray *found))doFound
						 whenDidNotFind:(void(^)(NSDictionary *query))doNotFound {
	
	
	if (!serviceName) return;
	
	NSData *serviceNameData = [serviceName dataUsingEncoding:NSUTF8StringEncoding];

	NSDictionary *query = @{
							(__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
							(__bridge id)kSecAttrService : serviceNameData,
							(__bridge id)kSecMatchCaseInsensitive : (__bridge id)kCFBooleanTrue,
							(__bridge id)kSecReturnAttributes : (__bridge id)kCFBooleanTrue,
							(__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitAll
							};
	
	CFDataRef found = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*) &found);
	
	if (err == noErr) {
		
		if (doFound) {
			
			doFound((__bridge id)found);
		}
		
		
	} else {
		
		if (doNotFound) {
			
			doNotFound(query);
		}
	}
}


@end
