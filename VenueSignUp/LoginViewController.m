//
//  LoginViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "GetVenueInfoViewController.h"
#import "AddAdminViewController.h"
#import <Accounts/Accounts.h>
#import "DebugViewController.h"

#define FB_ACCESS_TOKEN @"CAADQgbCANWcBAB0wbPMo86WvMMSdZCZBIn8X8tBMT8xm1gqmXxIuTHwO4odTB3rZBj1zO4Q48mMZANRAp6Lw0WL288UkNmc0fJXS12kzFcW5PbQYbLSkstRHw5EoHEtpxhUWZBt6mZBzb8GZCEZCKiv3maRgLTMvlVyK5uZCJakKg9AZDZD"

@interface LoginViewController ()
{
    UIImageView *LoginImageView;
    unsigned int networkActivity;
    BOOL loginNotification;
    BOOL signUp;
    BOOL addAdmin;
    BOOL adHoc;
    BOOL createMap;
}

@end

@implementation LoginViewController

@synthesize scrollView = _scrollView;
@synthesize loginButton = _loginButton;

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
    signUp = NO;
    addAdmin = NO;
    adHoc = NO;
    createMap = NO;
    
    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    delegate.debugFlag = FALSE;
    delegate.debugBaseURL = nil;
    
    // Register to listen for sessionExpired
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(login:)
     name:@"login"
     object:nil ];
    
    // Register to listen for updateLocation
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(logout:)
     name:@"logout"
     object:nil ];
    
    // Register to listen for debug
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(debugOn:)
     name:@"debugOn"
     object:nil];
    
    // Register to listen for debug
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(debugOff:)
     name:@"debugOff"
     object:nil];
    
    networkActivity = 0;
    loginNotification = false;
    
    // Scroll View
    [_scrollView setScrollEnabled:YES];
    [_scrollView setContentSize:(CGSizeMake(1536, 2008))];
    _scrollView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"iPad App Page 1@2x.png"]];
    
    // UIButton
    /*CGRect frame = _loginButton.frame;
    frame.origin.x = 226;
    frame.origin.y = 808;
    _loginButton.frame = frame;*/
}

- (void)viewWillAppear:(BOOL)animated
{
    // UIButton
    CGRect frame = _loginButton.frame;
    frame.origin.x = 226;
    frame.origin.y = 808;
    _loginButton.frame = frame;
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

#pragma IB Functions
- (IBAction)didClickDebugButton:(id)sender
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    DebugViewController *debugViewController = [sb instantiateViewControllerWithIdentifier:@"DebugViewController"];
    [self presentViewController: debugViewController animated:YES completion:nil];
}

- (IBAction)didClickLoginButton:(id)sender
{
    signUp = YES;
    [self login];
}

- (IBAction)didClickAddAdminButton:(id)sender
{
    addAdmin = YES;
    [self login];
}

- (IBAction)didClickAdHocButton:(id)sender
{
    adHoc = YES;
    [self login];
}

- (IBAction)didClickCreateMapButton:(id)sender
{
    createMap = YES;
    [self login];
}

#pragma Other Functions
- (void)login
{
    NSArray *permissions = [NSArray arrayWithObjects: @"read_stream", nil];
    
    // If we are currently logging in, return
    if(networkActivity)
        return;
    
    if(FBSession.activeSession.isOpen)
    {
        [self loginToServer];
    }
    
    else
    {
        [FBSession.activeSession closeAndClearTokenInformation];
        
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          if(error)
                                          {
                                              if(error.fberrorShouldNotifyUser)
                                              {
                                                  NSLog(@"Session error; notify user.  %@", error.fberrorUserMessage);
                                              }
                                              else if(error.fberrorCategory == FBErrorCategoryUserCancelled)
                                              {
                                                  NSLog(@"Session error; user canceled.");
                                              }
                                              else
                                              {
                                                  NSLog(@"Session unknown error");
                                              }
                                              
                                              
                                              [self fbResync];
                                              [self performSelector:@selector(fbAttemptConnection) withObject:nil afterDelay:0.5];
                                          }
                                          else
                                              [self sessionStateChanged:session state:state error:error];
                                      }];
    }
}

- (void)logout: (NSNotification *) notification
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void)debugOn: (NSNotification *) notification
{
    // If we did not receive what we expected, return
    if([[notification object] isKindOfClass:[NSString class]] == FALSE)
        return;
    
    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    delegate.debugFlag = TRUE;
    delegate.debugBaseURL = (NSString *) [notification object];

}

- (void)debugOff: (NSNotification *) notification
{
    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    delegate.debugFlag = FALSE;
    delegate.debugBaseURL = nil;
}

- (void)fbAttemptConnection
{
    NSArray *permissions = nil;
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
                                  }];
}

- (void)login:(NSNotification *) notification
{
    loginNotification = true;
    [self login];
    
}

#pragma Network Connection
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
        
        if(loginNotification == YES)
            return;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if(addAdmin == YES)
        {
            addAdmin = NO;
            [defaults setObject:@"addAdmin" forKey:@"signUpButton"];
            
            // Open next view controller
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            AddAdminViewController *addAdminViewController = [sb instantiateViewControllerWithIdentifier:@"AddAdminViewController"];
            [self.navigationController pushViewController:addAdminViewController animated:YES];
        }
        else if(signUp == YES)
        {
            signUp = NO;
            [defaults setObject:@"signUp" forKey:@"signUpButton"];
            
            // Open next view controller
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            GetVenueInfoViewController *getVenueInfoViewController = [sb instantiateViewControllerWithIdentifier:@"GetVenueInfoViewController"];
            [self.navigationController pushViewController:getVenueInfoViewController animated:YES];
        }
        else if(adHoc == YES)
        {
            adHoc = NO;
            [defaults setObject:@"adHoc" forKey:@"signUpButton"];
            
            // Open next view controller
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            GetVenueInfoViewController *getVenueInfoViewController = [sb instantiateViewControllerWithIdentifier:@"GetVenueInfoViewController"];
            [self.navigationController pushViewController:getVenueInfoViewController animated:YES];
        }
        else if(createMap == YES)
        {
            createMap = NO;
            [defaults setObject:@"createMap" forKey:@"signUpButton"];
            
            // Open next view controller
            UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            GetVenueInfoViewController *getVenueInfoViewController = [sb instantiateViewControllerWithIdentifier:@"CreateMapViewController"];
            [self.navigationController pushViewController:getVenueInfoViewController animated:YES];
        }
        
        // Save the information
        [defaults synchronize];
    }
}

#pragma Facebook
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

- (void)fbResync
{
    ACAccountStore *accountStore;
    ACAccountType *accountTypeFB;
    if ((accountStore = [[ACAccountStore alloc] init]) && (accountTypeFB = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook] ) )
    {
        
        NSArray *fbAccounts = [accountStore accountsWithAccountType:accountTypeFB];
        id account;
        if (fbAccounts && [fbAccounts count] > 0 && (account = [fbAccounts objectAtIndex:0]))
        {
            [accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                //we don't actually need to inspect renewResult or error.
                if (error){
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        }
    }
}

#pragma Client Code
- (void) loginToServer
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *accessToken = [appDelegate getFacebookAccessToken];
    
    if(!accessToken)
    {
        NSLog(@"Unable to get Access Token.");
        return;
    }
    
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@"&username=%@&password=%@&access_token=%@", @"", @"", accessToken];
    [self makeRequestWithPath:@"Login" variables:requestVariables andSecure:YES];
}

# pragma BreakoutLeague
- (void)makeRequestWithPath:(NSString *)path variables:(NSString *)variables andSecure:(BOOL)secure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    networkActivity++;
    
    NSString *theBaseURL;
    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    
    if(delegate.debugFlag == TRUE)
        theBaseURL = delegate.debugBaseURL;
    else if(secure == YES)
        theBaseURL = @baseURLSecure;
    else
        theBaseURL = @baseURL;
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@", theBaseURL, path, variables];
    
    BreakoutLeagueURLConnection *urlConnection = [[BreakoutLeagueURLConnection alloc] init];
    urlConnection.delegate = self;
    [urlConnection performRequestWithParameters:nil url:url];
    
    NSLog(@"%@", url);
}

- (void)BreakoutLeagueURLConnectionDidFinishLoading:(BreakoutLeagueURLConnection *)URLConnection withDictionary:(NSDictionary *)dictionary
{
    NSLog(@"%@", dictionary);
    [self requestDidFinishLoadingWithDictionary:dictionary];
}

- (void)BreakoutLeagueURLConnectionDidFail:(BreakoutLeagueURLConnection *)URLConnection withError:(NSError *)error withURL:(NSString *)URL andErrorMessage:(NSString *)errorMessage
{
    NSLog(@"%@", error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    networkActivity = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
}

@end
