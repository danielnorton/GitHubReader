//
//  BRLoginViewController.m
//  GitHubReader
//
//  Created by Daniel Norton on 8/12/13.
//  Copyright (c) 2013 Daniel Norton. All rights reserved.
//

#import "BRLoginViewController.h"


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


@end

