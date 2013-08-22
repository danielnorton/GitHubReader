//
//  BRGHCommit.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/21/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRGHCommit.h"
#import "BRGHRepository.h"
#import "BRGHUser.h"


@implementation BRGHCommit

@dynamic date;
@dynamic day;
@dynamic message;
@dynamic parentSha;
@dynamic path;
@dynamic sha;
@dynamic author;
@dynamic repository;


#pragma -
#pragma mark Custom Messages
- (NSString *)localizedDay {
	
	return [NSDateFormatter localizedStringFromDate:self.date
										  dateStyle:NSDateFormatterMediumStyle
										  timeStyle:NSDateFormatterNoStyle];
}

@end
