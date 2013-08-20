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


@interface BROrganizationsViewController()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) IBOutlet UIRefreshControl *refresh;

@end

@implementation BROrganizationsViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self initializeFetchedResultsController];
	[self setTitle:@"Organizations"];
	
	UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleDone target:self action:@selector(didTapLogout:)];
	[self.navigationItem setLeftBarButtonItem:logout];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	
//	NSIndexPath *indexPath = (NSIndexPath *)sender;
//	BRGHLogin *login = (BRGHLogin *)[_fetchedResultsController objectAtIndexPath:indexPath];
//	[segue.destinationViewController]
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self performSegueWithIdentifier:@"SegueFromOrganizations" sender:indexPath];
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


#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
	
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark -
#pragma mark BROrganizationsViewController
- (void)initializeFetchedResultsController {
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	[self setContext:context];
	
	NSSortDescriptor *sortIndex = [NSSortDescriptor sortDescriptorWithKey:@"sortIndex" ascending:YES];
	NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([BRGHLogin class])
											  inManagedObjectContext:_context];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:@[sortIndex, name]];
	[fetchRequest setPredicate:nil];

	NSFetchedResultsController *fetchedResultsController =
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:_context
										  sectionNameKeyPath:nil
												   cacheName:nil];
	
	[fetchedResultsController setDelegate:self];
	[self setFetchedResultsController:fetchedResultsController];
	
	NSError *error = nil;
	[fetchedResultsController performFetch:&error];
}

- (IBAction)didBeginRefresh:(UIRefreshControl *)sender {
	
	NSError *error = nil;
	BROrganizationService *service = [[BROrganizationService alloc] init];
	
	if (![service saveOrganizationsForGitLogin:_gitHubUser withLogin:_login error:&error]) return;
	
	[sender endRefreshing];
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