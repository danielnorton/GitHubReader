//
//  BRLoginViewController.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/12/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRLoginViewController.h"
#import "BRUserService.h"


@interface BRLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (nonatomic) BOOL isAuthenticating;

@end


@implementation BRLoginViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	return !_isAuthenticating;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	
	// Move along through the text fields to the "go" state
	if ([textField isEqual:_userName]) {
		
		[_password becomeFirstResponder];
		
	} else {
		
		[self setIsAuthenticating:YES];
		[textField resignFirstResponder];
		[self doLogin];
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
}


#pragma mark Private Messages
- (void)doLogin {
	
	BRUserService *service = [[BRUserService alloc] init];
	NSError *error = nil;
	BOOL win = [service generateOAuthTokenForUser:_userName.text withPassword:_password.text error:&error];
	[self setIsAuthenticating:NO];
	
	if (!win || error) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed"
														message:error.localizedDescription
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		return;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authenticated!"
													message:nil
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

@end

