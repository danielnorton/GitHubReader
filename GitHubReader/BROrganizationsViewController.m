//
//  BROrganizationsViewController.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BROrganizationsViewController.h"
#import "BRGravatarService.h"
#import "BROrganizationService.h"
#import "BRRepositoriesService.h"
#import "BRRepositoriesViewController.h"
#import "BRBasicFetchedResultControllerDelegate.h"


@interface BROrganizationsViewController()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) BRBasicFetchedResultControllerDelegate *delegate;

@end

@implementation BROrganizationsViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setTitle:@"Organizations"];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self initializeFetchedResultsController];
	
	UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleDone target:self action:@selector(didTapLogout:)];
	[self.navigationItem setLeftBarButtonItem:logout];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
	BRRepositoriesViewController *controller = (BRRepositoriesViewController *)segue.destinationViewController;
	if (![controller isKindOfClass:[BRRepositoriesViewController class]]) return;
	
	NSIndexPath *indexPath = (NSIndexPath *)sender;
	BRGHLogin *login = (BRGHLogin *)[_fetchedResultsController objectAtIndexPath:indexPath];
	
	[self setTitle:login.name];
	
	[controller setGitHubLogin:login];
	[controller setLogin:_login];
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	BRGHLogin *login = (BRGHLogin *)[_fetchedResultsController objectAtIndexPath:indexPath];
	BRRepositoriesService *service = [[BRRepositoriesService alloc] init];
	[service beginSaveRepositoriesForGitLogin:login withLogin:_login withCompletion:^(BOOL saved, NSError *error) {

		[self performSegueWithIdentifier:@"SegueFromOrganizations" sender:indexPath];
	}];
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
	
	BRGHLogin *login = (BRGHLogin *)[_fetchedResultsController objectAtIndexPath:indexPath];
	NSString *cellIdentifier = [login isKindOfClass:[BRGHUser class]]
	? @"UserCell"
	: @"OrganizationCell";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}


#pragma mark -
#pragma mark BROrganizationsViewController
- (void)initializeFetchedResultsController {
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	
	NSSortDescriptor *sortIndex = [NSSortDescriptor sortDescriptorWithKey:@"sortIndex" ascending:YES];
	NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([BRGHLogin class])
											  inManagedObjectContext:context];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"isAuthenticated = %@", @(YES)];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:@[sortIndex, name]];
	[fetchRequest setPredicate:pred];
	[fetchRequest setFetchBatchSize:20];

	NSFetchedResultsController *fetchedResultsController =
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:context
										  sectionNameKeyPath:nil
												   cacheName:nil];
	
	BROrganizationsViewController *me = self;
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
	
	BROrganizationService *service = [[BROrganizationService alloc] init];
	[service beginSaveOrganizationsForGitLogin:_gitHubUser withLogin:_login withCompletion:^(BOOL saved, NSError *error) {
		
		[sender endRefreshing];
	}];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	BRGHLogin *login = (BRGHLogin *)[_fetchedResultsController objectAtIndexPath:indexPath];
	[cell.imageView setImage:[BRGravatarService imageForGravatarWithHash:login.gravatarId ofSize:80]];
	[cell.textLabel setText:login.name];
}

- (void)didTapLogout:(UIBarButtonItem *)sender {

	[self performSegueWithIdentifier:@"unwindFromOrganizationSegue" sender:self];
}


@end
