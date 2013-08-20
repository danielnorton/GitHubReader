//
//  BRGHUser.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/19/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BRGHLogin.h"


@interface BRGHUser : BRGHLogin

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSString * organizationsPath;

@end
