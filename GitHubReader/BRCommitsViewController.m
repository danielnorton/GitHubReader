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


#define kDataPageSize 10

@interface BRCommitsViewController()

@property (strong, nonatomic) IBOutlet UIView *footerPagingIndicatorView;

@end


@implementation BRCommitsViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setTitle:@"Commits"];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self.tableView setTableFooterView:nil];
	
	[self loadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	
	return _commits.count;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	
    return _commits.count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *const cellIdentifier = @"CommitCell";
	
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}


#pragma mark -
#pragma mark BRCommitsViewController
#pragma mark BRCommitsViewController
+ (int)dataPageSize {
	
	return kDataPageSize;
}


#pragma mark Private Messages

- (void)loadData {
	
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

	NSArray *commits = [context executeFetchRequest:fetchRequest error:nil];
	[self setCommits:commits];
	[self.tableView reloadData];
}

- (IBAction)didBeginRefresh:(UIRefreshControl *)sender {
	
	NSError *error = nil;
	BRCommitsService *service = [[BRCommitsService alloc] init];

	if (![service saveCommitsForRepository:_repository atSha:_topSha withPageSize:kDataPageSize withLogin:_login shouldPurgeOthers:YES error:&error]) return;
	[self loadData];
	
	[sender endRefreshing];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	BRGHCommit *commit = (BRGHCommit *)_commits[indexPath.row];
	[cell.imageView setImage:[BRGravatarService imageForGravatarWithHash:commit.author.gravatarId ofSize:80]];
	[cell.textLabel setText:commit.message];
	
	NSString *date = [NSDateFormatter localizedStringFromDate:commit.date
													dateStyle:NSDateFormatterNoStyle
													timeStyle:NSDateFormatterMediumStyle];
	NSString *who = [NSString stringWithFormat:@"%@ authored at %@", commit.author.name, date];
	[cell.detailTextLabel setText:who];
}

@end
