//
//  BROrganizationsViewController.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/18/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BROrganizationsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) BRGHUser *gitHubUser;
@property (strong, nonatomic) BRLogin *login;

@end
