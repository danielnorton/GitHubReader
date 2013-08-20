//
//  BRRepositoriesViewController.h
//  GitHubReader
//
//  Created by Daniel Norton on 8/20/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//


#import "BRLogin.h"


@interface BRRepositoriesViewController : UITableViewController

@property (strong, nonatomic) BRGHLogin *gitHubLogin;
@property (strong, nonatomic) BRLogin *login;

@end
