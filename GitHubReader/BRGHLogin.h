//
//  BRGHLogin.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/19/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRGHRepository;

@interface BRGHLogin : NSManagedObject

@property (nonatomic, retain) NSNumber * gitHubId;
@property (nonatomic, retain) NSString * gravatarId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * repositoriesPath;
@property (nonatomic, retain) NSSet *repositories;
@property (nonatomic, retain) NSNumber * sortIndex;
@end

@interface BRGHLogin (CoreDataGeneratedAccessors)

- (void)addRepositoriesObject:(BRGHRepository *)value;
- (void)removeRepositoriesObject:(BRGHRepository *)value;
- (void)addRepositories:(NSSet *)values;
- (void)removeRepositories:(NSSet *)values;

@end
