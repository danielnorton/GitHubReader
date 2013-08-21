//
//  BRGHCommit.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRGHBranch, BRGHRepository;

@interface BRGHCommit : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) BRGHRepository *repository;
@property (nonatomic, retain) BRGHBranch *branch;
@property (nonatomic, retain) NSString * sha;

@end
