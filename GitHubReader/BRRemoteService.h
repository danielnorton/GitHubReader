//
//  BRRemoteService.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


extern NSString *const BRHTTPContentTypeJson;
extern NSString *const BRHTTPContentTypeForm;

extern NSString *const BRHTTPMethodGet;
extern NSString *const BRHTTPMethodPost;


typedef NS_ENUM(uint, BRHTTPArgumentLocation) {
	
	BRHTTPArgumentLocationQueryString,
	BRHTTPArgumentLocationBody
};

@interface BRRemoteService : NSObject

- (void)updateRequest:(NSMutableURLRequest *)request withJson:(id)json withContentType:(NSString *)contentType;
- (NSString *)pathFromURLPath:(NSString *)path withQueryStringParams:(NSDictionary *)params;

@end
