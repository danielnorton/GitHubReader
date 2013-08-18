//
//  Login.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Repository;

@interface Login : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * gitHubId;
@property (nonatomic, retain) NSString * gravatarId;
@property (nonatomic, retain) NSString * loginName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * repositoriesPath;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *repositories;
@end

@interface Login (CoreDataGeneratedAccessors)

- (void)addRepositoriesObject:(Repository *)value;
- (void)removeRepositoriesObject:(Repository *)value;
- (void)addRepositories:(NSSet *)values;
- (void)removeRepositories:(NSSet *)values;

@end
