//
//  ViewHelper.m
//  Branch
//
//  Created by Joshua Kendall on 6/12/11.
//  Copyright 2011 JoshuaKendall.com. All rights reserved.
//
// Thanks: http://forrst.com/posts/Converting_DateTime_to_Fuzzy_Time_in_Objective-zmH

#import "FuzzyTime.h"
#import "NSDate-Utilities.h"


@implementation NSDate(FuzzyTime)

- (NSString *)fuzzyTime {

	NSDate *date = self;
	NSString *formatted;
	NSDate *today = [NSDate date];
	NSInteger minutes = [today minutesAfterDate:date];
	NSInteger hours = [today hoursAfterDate:date];
	NSInteger days = [today daysAfterDate:date];
	NSString *period;
	if(days >= 365){
		float years = ceil((days / 365) / 2.0f);
		period = (years > 1) ? @"years" : @"year";
		formatted = [NSString stringWithFormat:@"about %.0f %@ ago", years, period];
	} else if(days < 365 && days >= 30) {
		float months = ceil((days / 30) / 2.0f);
		period = (months > 1) ? @"months" : @"month";
		formatted = [NSString stringWithFormat:@"about %.0f %@ ago", months, period];
	} else if(days < 30 && days >= 2) {
		period = @"days";
		formatted = [NSString stringWithFormat:@"about %i %@ ago", days, period];
	} else if(days == 1){
		period = @"day";
		formatted = [NSString stringWithFormat:@"about %i %@ ago", days, period];
	} else if(days < 1 && minutes > 60) {
		period = (hours > 1) ? @"hours" : @"hour";
		formatted = [NSString stringWithFormat:@"about %i %@ ago", hours, period];
	} else {
		period = (minutes < 60 && minutes > 1) ? @"minutes" : @"minute";
		formatted = [NSString stringWithFormat:@"about %i %@ ago", minutes, period];
		if(minutes < 1){
			formatted = @"a moment ago";
		}
	}
	return formatted;
}

@end