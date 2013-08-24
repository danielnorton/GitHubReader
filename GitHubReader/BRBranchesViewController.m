//
//  BRBranchesViewController.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRBranchesViewController.h"
#import "BRBranchService.h"
#import "BRCommitsViewController.h"
#import "BRCommitsService.h"
#import "BRBasicFetchedResultControllerDelegate.h"
#import "UITableViewCell+activity.h"


@interface BRBranchesViewController()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) BRBasicFetchedResultControllerDelegate *delegate;

@end


@implementation BRBranchesViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setTitle:@"Branches"];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self initializeFetchedResultsController];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	BRCommitsViewController *controller = (BRCommitsViewController *)segue.destinationViewController;
	if (![controller isKindOfClass:[BRCommitsViewController class]]) return;
	
	NSIndexPath *indexPath = (NSIndexPath *)sender;
	BRGHBranch *branch = (BRGHBranch *)[_fetchedResultsController objectAtIndexPath:indexPath];
	
	NSError *error = nil;
	BRCommitsService *service = [[BRCommitsService alloc] init];
	if (![service saveCommitsForRepository:_repository
									 atSha:branch.sha
							  withPageSize:[BRCommitsViewController dataPageSize]
								 withLogin:_login
						 shouldPurgeOthers:YES
									 error:&error]) return;
	
	[self setTitle:branch.name];
	
	[controller setRepository:_repository];
	[controller setTopSha:branch.sha];
	[controller setLogin:_login];
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[self performSegueWithIdentifier:@"SegueFromBranches" sender:indexPath];
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
	
	BRGHBranch *branch = (BRGHBranch *)[_fetchedResultsController objectAtIndexPath:indexPath];
	NSString *cellIdentifier = [branch.isDefault boolValue]
	? @"DefaultBranchCell"
	: @"BranchCell";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}


#pragma mark -
#pragma mark BRBranchesViewController
- (void)initializeFetchedResultsController {
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	
	NSSortDescriptor *isDefault = [NSSortDescriptor sortDescriptorWithKey:@"isDefault" ascending:NO];
	NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([BRGHBranch class])
											  inManagedObjectContext:context];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"repository = %@", _repository];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:@[isDefault, name]];
	[fetchRequest setPredicate:pred];
	
	NSFetchedResultsController *fetchedResultsController =
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:context
										  sectionNameKeyPath:nil
												   cacheName:nil];
	
	BRBranchesViewController *me = self;
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
	
	BRBranchService *service = [[BRBranchService alloc] init];
	[service beginSaveBranchesForRepository:_repository withLogin:_login withCompletion:^(BOOL saved, NSError *error) {
		
		[sender endRefreshing];
	}];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	BRGHBranch *branch = (BRGHBranch *)[_fetchedResultsController objectAtIndexPath:indexPath];
	[cell.textLabel setText:branch.name];
}

@end
