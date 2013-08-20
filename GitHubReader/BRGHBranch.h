//
//  BRGHBranch.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/19/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRGHCommit, BRGHRepository;

@interface BRGHBranch : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) BRGHCommit *commit;
@property (nonatomic, retain) BRGHRepository *repository;

@end