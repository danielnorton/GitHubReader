//
//  BRGHBranch.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/21/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRGHRepository;

@interface BRGHBranch : NSManagedObject

@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sha;
@property (nonatomic, retain) BRGHRepository *repository;

@end
