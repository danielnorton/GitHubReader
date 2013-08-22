//
//  BRCommitsViewController.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/21/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRCommitsViewController.h"
#import "BRCommitsService.h"
#import "BRBasicFetchedResultControllerDelegate.h"
#import "BRGravatarService.h"
#import "FuzzyTime.h"

#define kDataPageSize 100

@interface BRCommitsViewController()

@property (strong, nonatomic) IBOutlet UIView *footerPagingIndicatorView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchRequest *fetchRequest;
@property (strong, nonatomic) BRBasicFetchedResultControllerDelegate *delegate;
@property (nonatomic) BOOL isDoneFetching;
@property (nonatomic) int dataCount;
@end


@implementation BRCommitsViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setTitle:@"Commits"];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	[self displayPagingIndicator];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[_fetchedResultsController setDelegate:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self initializeFetchedResultsController];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	
	return [[_fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	return [_fetchedResultsController.sections[section] name];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	
    id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *const cellIdentifier = @"CommitCell";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (_isDoneFetching) return;
	
	float offset = scrollView.contentOffset.y;
	float rowHeight = self.tableView.rowHeight;
	int rows = [self dataCount];
	int buffer = kDataPageSize / 2;
	float start = (rowHeight * rows) - (buffer * rowHeight);
	if (offset >= start) {
		
		[self fetchNextPage];
	}
}


#pragma mark -
#pragma mark BRCommitsViewController
+ (int)dataPageSize {
	
	return kDataPageSize;
}


#pragma mark Private Messages
- (void)initializeFetchedResultsController {
	
	NSManagedObjectContext *context = [[BRModelManager sharedInstance] context];
	
	NSSortDescriptor *date = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([BRGHCommit class])
											  inManagedObjectContext:context];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"repository = %@", _repository];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:@[date]];
	[fetchRequest setPredicate:pred];
	[self setFetchRequest:fetchRequest];
	
	NSFetchedResultsController *fetchedResultsController =
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:context
										  sectionNameKeyPath:@"localizedDay"
												   cacheName:nil];
	
	BRCommitsViewController *me = self;
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
	[self calculateDataCount];
}

- (int)calculateDataCount {
	
	NSError *error = nil;
	int count = [_fetchedResultsController.managedObjectContext countForFetchRequest:_fetchRequest error:&error];
	if (error) count = 0;
	
	_dataCount = count;
	return count;
}

- (IBAction)didBeginRefresh:(UIRefreshControl *)sender {
	
	NSError *error = nil;
	BRCommitsService *service = [[BRCommitsService alloc] init];
	int dataPage = 1;
	
	if (![service saveCommitsForRepository:_repository atSha:_topSha atPage:dataPage withPageSize:kDataPageSize withLogin:_login error:&error]) return;
	
	[self calculateDataCount];
	[self displayPagingIndicator];
	[self setDataPage:dataPage];
	[self setIsDoneFetching:NO];
	[sender endRefreshing];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	BRGHCommit *commit = (BRGHCommit *)[_fetchedResultsController objectAtIndexPath:indexPath];
	[cell.imageView setImage:[BRGravatarService imageForGravatarWithHash:commit.author.gravatarId ofSize:80]];
	[cell.textLabel setText:commit.message];
	
	NSString *date = [commit.date fuzzyTime];
	NSString *who = [NSString stringWithFormat:@"%@ authored %@", commit.author.name, date];
	[cell.detailTextLabel setText:who];
}

- (void)fetchNextPage {
	
	NSError *error = nil;
	BRCommitsService *service = [[BRCommitsService alloc] init];
	
	int startingCount = [self dataCount];
	int sections = [self numberOfSectionsInTableView:self.tableView];
	int rows = [self tableView:self.tableView numberOfRowsInSection:(sections - 1)];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(rows - 1) inSection:(sections - 1)];
	BRGHCommit *lastCommit = [_fetchedResultsController objectAtIndexPath:indexPath];
	
	if (!lastCommit.parentSha) {
		
		[self.tableView setTableFooterView:nil];
		[self setIsDoneFetching:YES];
		return;
	}
	
	if (![service saveCommitsForRepository:_repository atSha:lastCommit.parentSha atPage:(_dataPage + 1) withPageSize:kDataPageSize withLogin:_login error:&error]) return;
	
	int count = [self calculateDataCount];
	if (startingCount == count) {
		
		[self.tableView setTableFooterView:nil];
		[self setIsDoneFetching:YES];
		return;
	}
	
	_dataPage++;
}

- (void)displayPagingIndicator {
	
	int rows = [self tableView:self.tableView numberOfRowsInSection:0];
	UIView *view = ((kDataPageSize % rows) == 0)
	? _footerPagingIndicatorView
	: nil;
	[self.tableView setTableFooterView:view];
}

@end
