//
//  BRGHRepository.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/21/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRGHBranch, BRGHCommit, BRGHLogin;

@interface BRGHRepository : NSManagedObject

@property (nonatomic, retain) NSString * branchesPath;
@property (nonatomic, retain) NSString * commitsPath;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * defaultBranchName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * gitHubDescription;
@property (nonatomic, retain) NSNumber * gitHubId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * treesPath;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *branches;
@property (nonatomic, retain) NSSet *commits;
@property (nonatomic, retain) BRGHLogin *owner;
@end

@interface BRGHRepository (CoreDataGeneratedAccessors)

- (void)addBranchesObject:(BRGHBranch *)value;
- (void)removeBranchesObject:(BRGHBranch *)value;
- (void)addBranches:(NSSet *)values;
- (void)removeBranches:(NSSet *)values;

- (void)addCommitsObject:(BRGHCommit *)value;
- (void)removeCommitsObject:(BRGHCommit *)value;
- (void)addCommits:(NSSet *)values;
- (void)removeCommits:(NSSet *)values;

@end
