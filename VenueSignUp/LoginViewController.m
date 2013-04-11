//
//  LoginViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CreateVenueViewController.h"

@interface LoginViewController ()
{
    UIImageView *LoginImageView;
    unsigned int networkActivity;
    BOOL loginNotification;
}

@end

@implementation LoginViewController

@synthesize request = _request;

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
    self.navigationController.navigationBarHidden = YES;
    
    // Register to listen for sessionExpired
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(login:)
     name:@"login"
     object:nil ];
    
    networkActivity = 0;
    loginNotification = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)didClickLoginButton:(id)sender
{
    [self login];
}


-(void)login
{
    // If we are currently logging in, return
    if(networkActivity)
        return;
    
    if(FBSession.activeSession.isOpen)
    {
        [self loginToServer];
    }
    
    else
    {
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler: ^(FBSession *session, FBSessionState state, NSError *error){
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    
}

-(void)login:(NSNotification *) notification
{
    loginNotification = true;
    [self login];
    
}

#pragma Network Connection
- (void)requestDidFailWithError:(NSError *)error
{
	NSLog(@"%@", error);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    networkActivity = 0;
}

- (void)requestDidReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    
    // If our session has timed out
    if(([httpResponse statusCode] == 403) || ([httpResponse statusCode] == 404))
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        networkActivity = 0;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
    }
}

- (void)requestDidFinishLoadingWithDictionary:(NSDictionary *)result
{
    networkActivity--;
    if(networkActivity == 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSDictionary *loginInfo = [result objectForKey:@"Login_Info"];
    
    // Login
    if(loginInfo)
    {
        NSLog(@"Login_Info:");
        BOOL status = ((NSString *)[loginInfo objectForKey:@"status"]).boolValue;
        
        // If there was an error, print it to the log
        if (status == NO)
        {
            NSLog(@"%@", (NSString *)[loginInfo objectForKey:@"error"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
            
            return;
        }
        
        // Open next view controller
        UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        CreateVenueViewController *createVenueViewController = [sb instantiateViewControllerWithIdentifier:@"CreateVenueViewController"];
        [self.navigationController pushViewController:createVenueViewController animated:YES];
    }
}

- (void) loginToServer
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *accessToken = [appDelegate getFacebookAccessToken];
    
    if(!accessToken)
    {
        NSLog(@"Unable to get Access Token.");
        return;
    }
    
    NSLog(@"login: userName = %@, password = %@, accessToken = %@", @"", @"", accessToken);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    networkActivity++;
    
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@"&arg=%@&arg=%@&arg=%@", @"", @"", accessToken];
    NSLog(@"login: %@", requestVariables);
    _request = [NetworkJSONRequest makeRequestWithPath:@"Login" variables:requestVariables delegate:self andSecure:TRUE];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
        {
            NSLog(@"FBSessionStateOpen");
            
            // initialize the viewcontroller with a little delay, so that the UI displays the changes made above
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self loginToServer];
            });
            
            break;
        }
            
        case FBSessionStateClosed:
        {
            NSLog(@"FBSessionStateClosed");
            break;
        }
            
        case FBSessionStateClosedLoginFailed:
        {
            [FBSession.activeSession closeAndClearTokenInformation];
            NSLog(@"Facebook State Closed or Failed");
            
            break;
        }
        default:
        {
            break;
        }
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)dealloc
{
	if (_request) {
		[_request setDelegate:nil];
		_request = nil;
	}
}

@end
