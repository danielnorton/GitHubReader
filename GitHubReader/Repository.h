//
//  Repository.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Commit, Login;

@interface Repository : NSManagedObject

@property (nonatomic, retain) NSString * branchesPath;
@property (nonatomic, retain) NSString * commitsPath;
@property (nonatomic, retain) NSString * created;
@property (nonatomic, retain) NSString * defaultBranchName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * gitHubDescription;
@property (nonatomic, retain) NSNumber * gitHubId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * treesPath;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSSet *commits;
@property (nonatomic, retain) Login *owner;
@end

@interface Repository (CoreDataGeneratedAccessors)

- (void)addCommitsObject:(Commit *)value;
- (void)removeCommitsObject:(Commit *)value;
- (void)addCommits:(NSSet *)values;
- (void)removeCommits:(NSSet *)values;

@end
