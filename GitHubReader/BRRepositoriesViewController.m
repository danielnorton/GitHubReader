//
//  BRRepositoriesViewController.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRRepositoriesViewController.h"
#import "BRRepositoriesService.h"
#import "BRBasicFetchedResultControllerDelegate.h"


@interface BRRepositoriesViewController()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) BRBasicFetchedResultControllerDelegate *delegate;

@end

@implementation BRRepositoriesViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self initializeFetchedResultsController];
	[self setTitle:@"Repos"];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	
	return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	
    id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *const cellIdentifier = @"RepoCell";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}


#pragma mark -
#pragma mark BRRepositoriesViewController
- (void)initializeFetchedResultsController {
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	
	NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([BRGHRepository class])
											  inManagedObjectContext:context];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:@[name]];
	[fetchRequest setPredicate:nil];
	
	NSFetchedResultsController *fetchedResultsController =
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:context
										  sectionNameKeyPath:nil
												   cacheName:nil];
	
	BRRepositoriesViewController *me = self;
	BRBasicFetchedResultControllerDelegate *delegate = [[BRBasicFetchedResultControllerDelegate alloc] init];
	[delegate setTableView:self.tableView];
	[delegate setConfigureCell:^(UITableViewCell *cell, NSIndexPath *indexPath) {
		
		[me configureCell:cell atIndexPath:indexPath];
	}];
	
	[self setDelegate:delegate];
	[fetchedResultsController setDelegate:delegate];
	[self setFetchedResultsController:fetchedResultsController];
	
	NSError *error = nil;
	[fetchedResultsController performFetch:&error];
}

- (IBAction)didBeginRefresh:(UIRefreshControl *)sender {
	
	NSError *error = nil;
	BRRepositoriesService *service = [[BRRepositoriesService alloc] init];
	
	if (![service saveRepositoriesForGitLogin:_gitHubLogin withLogin:_login error:&error]) return;
	
	[sender endRefreshing];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	BRGHRepository *repo = (BRGHRepository *)[_fetchedResultsController objectAtIndexPath:indexPath];
	
	[cell.textLabel setText:repo.name];
	if (repo.updated) {
		
		NSString *date = [NSDateFormatter localizedStringFromDate:repo.updated dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
		NSString *message = [NSString stringWithFormat:@"last updated: %@", date];
		[cell.detailTextLabel setText:message];
	}
}


@end
