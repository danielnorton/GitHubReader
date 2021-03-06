//
//  BRCommitsViewController.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/21/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BRCommitsViewController : UITableViewController

@property (strong, nonatomic) BRGHRepository *repository;
@property (strong, nonatomic) BRGHBranch *branch;
@property (strong, nonatomic) BRLogin *login;

+ (int)dataPageSize;

@end
