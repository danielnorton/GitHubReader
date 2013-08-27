//
//  BRGHLogin.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/26/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRGHGravatar, BRGHRepository;

@interface BRGHLogin : NSManagedObject

@property (nonatomic, retain) NSNumber * gitHubId;
@property (nonatomic, retain) NSString * gravatarId;
@property (nonatomic, retain) NSNumber * isAuthenticated;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * repositoriesPath;
@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) NSString * repositoriesLastModified;
@property (nonatomic, retain) NSSet *repositories;
@property (nonatomic, retain) BRGHGravatar *thumbnailGravatar;
@end

@interface BRGHLogin (CoreDataGeneratedAccessors)

- (void)addRepositoriesObject:(BRGHRepository *)value;
- (void)removeRepositoriesObject:(BRGHRepository *)value;
- (void)addRepositories:(NSSet *)values;
- (void)removeRepositories:(NSSet *)values;

@end
