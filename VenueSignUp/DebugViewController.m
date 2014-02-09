//
//  DebugViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 7/15/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "DebugViewController.h"

@interface DebugViewController ()

@end

@implementation DebugViewController

@synthesize urlTextField = _urlTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickEnableButton:(id)sender
{
    // Notification with new URL
    NSString *theBaseURL = [NSString stringWithFormat:@"https://%@.ngrok.com%s", _urlTextField.text, baseURLDebug];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugOn" object:theBaseURL];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didClickQuitButton:(id)sender
{
    // Notification with empty URL
    [[NSNotificationCenter defaultCenter] postNotificationName:@"debugOff" object:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
