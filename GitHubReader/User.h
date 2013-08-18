//
//  User.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Login.h"

@class Organization;

@interface User : Login

@property (nonatomic, retain) NSString * organizationsPath;
@property (nonatomic, retain) NSSet *organizations;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addOrganizationsObject:(Organization *)value;
- (void)removeOrganizationsObject:(Organization *)value;
- (void)addOrganizations:(NSSet *)values;
- (void)removeOrganizations:(NSSet *)values;

@end
