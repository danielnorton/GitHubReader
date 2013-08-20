//
//  BRBasicFetchedResultControllerDelegate.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


@interface BRBasicFetchedResultControllerDelegate : NSObject<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) void(^configureCell)(UITableViewCell *cell, NSIndexPath *indexPath);

@end
