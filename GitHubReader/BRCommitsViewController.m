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


typedef NS_ENUM(uint, BRCommitFetchState) {
	
	BRCommitFetchStateIdle,
	BRCommitFetchStateFetching,
	BRCommitFetchStateDone
};

#define kDataPageSize 100

@interface BRCommitsViewController()

@property (strong, nonatomic) IBOutlet UIView *footerPagingIndicatorView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchRequest *fetchRequest;
@property (strong, nonatomic) BRBasicFetchedResultControllerDelegate *delegate;
@property (strong, nonatomic) id observer;
@property (nonatomic) BRCommitFetchState fetchState;
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
	
	id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
																	object:nil
																	 queue:[NSOperationQueue mainQueue]
																usingBlock:^(NSNotification *note) {
																	
																	if (note.object == [[BRModelManager sharedInstance] context]) return;
																	
																	[self updateDataFromNotifiction:note];
																}];
	[self setObserver:observer];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[_fetchedResultsController setDelegate:nil];
	
	[self setObserver:nil];
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
	
	if (_fetchState != BRCommitFetchStateIdle) return;
	
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
	
	BRCommitsService *service = [[BRCommitsService alloc] init];
	[service beginSaveCommitsForRepository:_repository atSha:_topSha withPageSize:kDataPageSize withLogin:_login shouldPurgeOthers:YES withCompletion:^(BOOL saved, NSError *error) {
		
		[self calculateDataCount];
		[self displayPagingIndicator];
		[self setFetchState:BRCommitFetchStateIdle];
		[sender endRefreshing];
	}];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	BRGHCommit *commit = (BRGHCommit *)[_fetchedResultsController objectAtIndexPath:indexPath];
	[cell.textLabel setText:commit.message];
	
	NSString *date = [NSDateFormatter localizedStringFromDate:commit.date
													dateStyle:NSDateFormatterNoStyle
													timeStyle:NSDateFormatterMediumStyle];
	NSString *who = [NSString stringWithFormat:@"%@ authored at %@", commit.author.name, date];
	[cell.detailTextLabel setText:who];
}

- (void)fetchNextPage {
	
	BRCommitsService *service = [[BRCommitsService alloc] init];
	
	int startingCount = [self dataCount];
	int sections = [self numberOfSectionsInTableView:self.tableView];
	int rows = [self tableView:self.tableView numberOfRowsInSection:(sections - 1)];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(rows - 1) inSection:(sections - 1)];
	BRGHCommit *lastCommit = [_fetchedResultsController objectAtIndexPath:indexPath];
	
	if (!lastCommit.parentSha) {
		
		[self.tableView setTableFooterView:nil];
		[self setFetchState:BRCommitFetchStateDone];
		return;
	}
	
	[self setFetchState:BRCommitFetchStateFetching];
	[service beginSaveCommitsForRepository:_repository atSha:lastCommit.parentSha withPageSize:kDataPageSize withLogin:_login shouldPurgeOthers:NO withCompletion:^(BOOL saved, NSError *error) {
		
		int count = [self calculateDataCount];
		if (startingCount == count) {
			
			[self.tableView setTableFooterView:nil];
			[self setFetchState:BRCommitFetchStateDone];
			return;
		}
		
		[self setFetchState:BRCommitFetchStateIdle];
	}];
}

- (void)displayPagingIndicator {
	
	int rows = [self dataCount];
	UIView *view = ((kDataPageSize % rows) == 0)
	? _footerPagingIndicatorView
	: nil;
	[self.tableView setTableFooterView:view];
}

- (void)updateDataFromNotifiction:(NSNotification *)notification {
    
    if (![NSThread isMainThread]) {
		
		[self performSelectorOnMainThread:@selector(updateDataFromNotifiction:) withObject:notification waitUntilDone:NO];
		return;
	}
	
    [_fetchedResultsController.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}


@end
