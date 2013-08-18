//
//  BRModelManager.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRModelManager.h"


@interface BRModelManager()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation BRModelManager


#pragma mark -
#pragma mark BRModelManager
#pragma mark Public Messages
+ (BRModelManager *)sharedInstance {
	
    static BRModelManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
        sharedInstance = [[BRModelManager alloc] init];
    });
	
    return sharedInstance;
}


// Context, MOM, and PSC are all basically the same as
// you would get from a project template that includes CoreData
- (NSManagedObjectContext *)context {
	
	if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GitHubReader" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
	NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
							  NSInferMappingModelAutomaticallyOption: @YES};
	
    NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:@"GitHubReader.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {

		NSAssert(NO, @"The app encountered a terminal failure and will shut down.");
		abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationLibraryDirectory {
	
	return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
