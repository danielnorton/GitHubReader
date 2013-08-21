//
//  BRGHUser.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/21/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BRGHLogin.h"

@class BRGHCommit, BRGHOrganization;

@interface BRGHUser : BRGHLogin

@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSString * organizationsPath;
@property (nonatomic, retain) NSSet *commits;
@property (nonatomic, retain) BRGHOrganization *organizations;
@end

@interface BRGHUser (CoreDataGeneratedAccessors)

- (void)addCommitsObject:(BRGHCommit *)value;
- (void)removeCommitsObject:(BRGHCommit *)value;
- (void)addCommits:(NSSet *)values;
- (void)removeCommits:(NSSet *)values;

@end
