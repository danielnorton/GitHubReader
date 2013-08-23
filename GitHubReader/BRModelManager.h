//
//  BRModelManager.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


@interface BRModelManager : NSObject

+ (BRModelManager *)sharedInstance;
- (NSManagedObjectContext *)context;
@property (readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
