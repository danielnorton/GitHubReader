//
//  BRGravatarService.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/19/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRGravatarService.h"

@interface BRGravatarService()

@property (strong, nonatomic) NSOperationQueue *queue;

@end


@implementation BRGravatarService


#pragma mark -
#pragma mark NSObject
- (id)init {
	
	self = [super init];
	if (self) {
		
		NSOperationQueue *queue = [[NSOperationQueue alloc] init];
		[queue setName:@"BRGravatarService queue"];
		[queue setMaxConcurrentOperationCount:3];
		_queue = queue;
	}
	
	return self;
}


#pragma mark BRGravatarService
+ (NSURL *)urlForGravatarWithHash:(NSString *)hash ofSize:(int)size {
	
	NSString *gravatarPath = [NSString stringWithFormat:@"https://gravatar.com/avatar/%@?s=%i", hash, size];
	return [NSURL URLWithString:gravatarPath];
}

+ (UIImage *)imageForGravatarWithHash:(NSString *)hash ofSize:(int)size {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURL *url = [self urlForGravatarWithHash:hash ofSize:size];
	UIImage *gravatarDownload = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
	UIImage *answer = [UIImage imageWithCGImage:[gravatarDownload CGImage] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	return answer;
}

- (void)saveGravatarsForLogin:(BRGHLogin *)login ofSize:(int)size {

	NSManagedObjectID *objectId = login.objectID;
	NSURL *url = [BRGravatarService urlForGravatarWithHash:login.gravatarId ofSize:size];
	NSString *lastModified = nil;
	
	BRGHGravatar *gravatar = login.thumbnailGravatar;
	if (gravatar) {
		
		lastModified = gravatar.lastModified;
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringCacheData
															timeoutInterval:30.0f];
	if (lastModified) {
		
		[request setValue:lastModified forHTTPHeaderField:@"if-modified-since"];
	}
	
	[NSURLConnection sendAsynchronousRequest:request queue:_queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

		if (connectionError || !data) return;

		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		if (httpResponse.statusCode != 200) return;
		
		NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
		[context setPersistentStoreCoordinator:[BRModelManager sharedInstance].persistentStoreCoordinator];
		
		BRGHLogin *login = (BRGHLogin *)[context objectWithID:objectId];
		BRGHGravatar *gravatar = login.thumbnailGravatar;
		if (!gravatar) {
			
			gravatar = (BRGHGravatar *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([BRGHGravatar class])
																	 inManagedObjectContext:context];
			[login setThumbnailGravatar:gravatar];
		}
		
		[gravatar setImage:data];
		[gravatar setLastModified:httpResponse.allHeaderFields[@"Last-Modified"]];
		
		[context save:NULL];
	}];
}
@end
