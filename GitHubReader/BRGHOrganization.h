//
//  BRGHOrganization.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/26/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BRGHLogin.h"

@class BRGHUser;

@interface BRGHOrganization : BRGHLogin

@property (nonatomic, retain) BRGHUser *user;

@end
