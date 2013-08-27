//
//  BRGHCommit+model.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/26/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRGHCommit+model.h"

@implementation BRGHCommit(model)


- (NSString *)localizedDay {
	
	return [NSDateFormatter localizedStringFromDate:self.date
										  dateStyle:NSDateFormatterMediumStyle
										  timeStyle:NSDateFormatterNoStyle];
}

@end
