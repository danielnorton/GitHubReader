//
//  BRGHCommit.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/21/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRGHRepository, BRGHUser;

@interface BRGHCommit : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * parentSha;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * sha;
@property (nonatomic, retain) BRGHRepository *repository;
@property (nonatomic, retain) BRGHUser *committer;

@end
