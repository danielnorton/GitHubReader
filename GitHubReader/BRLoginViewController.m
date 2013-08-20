//
//  BRLoginViewController.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/12/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRLoginViewController.h"
#import "BRUserService.h"
#import "BRLoginService.h"
#import "UIColor+Helpers.h"
#import "BROrganizationService.h"
#import "BRGravatarService.h"
#import "BROrganizationsViewController.h"


#define kDefaultPasswordPlaceholder @"password"


@interface BRLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (nonatomic) BOOL isAuthenticating;

@end

static BOOL didLaunchLogin = NO;

@implementation BRLoginViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	
	if (didLaunchLogin) return;
	didLaunchLogin = YES;
	
	NSArray *userNames = [BRLoginService getLoginNamesForService:BRGitHubReaderSecurityService];
	if (userNames && userNames.count > 0) {
		
		NSString *userName = [userNames lastObject];
		[_userName setText:userName];
		[self displayFakePasswordPlaceholder];
		
		BRLogin *login = [[BRLogin alloc] init];
		[login setName:userName];
		[login setService:BRGitHubReaderSecurityService];
		
		BRLoginService *service = [[BRLoginService alloc] initWithLogin:login];
		NSString *password = [service getPassword];
		
		[self doLogin:password];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	BROrganizationsViewController *controller = (BROrganizationsViewController *)segue.destinationViewController;
	if (![controller isKindOfClass:[BROrganizationsViewController class]]) return;
	
	NSArray *items = (NSArray *)sender;
	if (![items isKindOfClass:[NSArray class]]) return;
	
	BRGHUser *user = items[0];
	if (![user isKindOfClass:[BRGHUser class]]) return;
	
	BRLogin *login = items[1];
	if (![login isKindOfClass:[BRLogin class]]) return;
	
	[controller setGitHubUser:user];
	[controller setLogin:login];
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	[_password setPlaceholder:kDefaultPasswordPlaceholder];
	[_password setTextColor:_userName.textColor];
	return !_isAuthenticating;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Move along through the text fields to the "go" state
	if ([textField isEqual:_userName]) {
		
		[_password becomeFirstResponder];
		[_password setPlaceholder:kDefaultPasswordPlaceholder];
		
	} else {
		
		[textField resignFirstResponder];
		[self doLogin:_password.text];
	}
	
	return YES;
}


#pragma mark -
#pragma mark BRLoginViewController
#pragma mark IBAction
- (IBAction)didTapTable:(id)sender {
	
	// hide the keyboard if a user taps outside
	// of the text field controls
	[_userName resignFirstResponder];
	[_password resignFirstResponder];
	
	BRLogin *login = [[BRLogin alloc] init];
	[login setName:_userName.text];
	[login setService:BRGitHubReaderSecurityService];
}


#pragma mark Private Messages
- (void)doLogin:(NSString *)password {

	[self setIsAuthenticating:YES];
	[self displayPasswordPlaceholder:@"Authenticating..." withColor:nil];
	[_avatar setImage:[UIImage imageNamed:@"octocat"]];
	
	BRLogin *login = [[BRLogin alloc] init];
	[login setName:_userName.text];
	[login setService:BRGitHubReaderSecurityService];
	
	if ([BRLoginService hasPasswordForLogin:login]) {
		
		BRLoginService *loginService = [[BRLoginService alloc] initWithLogin:login];
		[loginService deletePassword];
	}
	
	BRUserService *service = [[BRUserService alloc] init];
	NSError *error = nil;
	BRGHUser *user = [service getUser:login.name withPassword:password error:&error];
	[self setIsAuthenticating:NO];
	
	if (!user || error) {	
		
		[_avatar setImage:[UIImage imageNamed:@"strongbadtocat"]];
		[self displayPasswordPlaceholder:@"Log-in Fail'd!" withColor:[UIColor colorFrom255Red:255 green:49 blue:48]];
		return;
	}
	
	UIImage *gravatar = [BRGravatarService imageForGravatarWithHash:user.gravatarId ofSize:_avatar.frame.size.width * 2];
	[_avatar setImage:gravatar];
	
	[_password setTextColor:[UIColor colorFrom255Red:76 green:217 blue:100]];
	[self displayFakePasswordPlaceholder];
	
	NSError *orgError = nil;
	BROrganizationService *orgService = [[BROrganizationService alloc] init];
	if ([orgService saveOrganizationsForGitLogin:user withLogin:login error:&orgError]) {
		
		[self performSegueWithIdentifier:@"SegueFromLogin" sender:@[user, login]];
	}
}

- (void)displayFakePasswordPlaceholder {
	
	[_password setPlaceholder:kDefaultPasswordPlaceholder];
	[_password setText:@"xxxxxxxxxx"];
}

- (void)displayPasswordPlaceholder:(NSString *)placeholder withColor:(UIColor *)color {

	[_password setText:[NSString string]];
	
	if (!color) {
		
		[_password setPlaceholder:placeholder];
		
	} else {
	
		[_password setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: color}]];
	}
	
}


@end

