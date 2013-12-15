//
//  AddAdminViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 6/8/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "AddAdminViewController.h"
#import "FacebookPageModel.h"
#import "NSString+URLEncoding.h"
#import "ScenesListModel.h"
#import "AppDelegate.h"
#import "DebugViewController.h"

@interface AddAdminViewController ()

@end

@implementation AddAdminViewController
{
    unsigned int networkActivity;
    
    ScenesListModel *scenesListModel;
}

@synthesize facebookPagesTableView = _facebookPagesTableView;
@synthesize scenesTableView = _scenesTableView;
@synthesize venuesTableView = _venuesTableView;
@synthesize cityNameTextField = _cityNameTextField;
@synthesize stateNameTextField = _stateNameTextField;

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
    
    // Model
    model = [[CreateVenueModel alloc] init];
    
    // Variables and flags
    networkActivity = 0;
    
    // Initialize the TableViewControllers
    facebookPagesTVC = [[GenericTableViewController alloc] init];
    facebookPagesTVC.tableView = _facebookPagesTableView;
    [_facebookPagesTableView setDelegate:facebookPagesTVC];
    [_facebookPagesTableView setDataSource:facebookPagesTVC];
    
    scenesTVC = [[GenericTableViewController alloc] init];
    scenesTVC.tableView = _scenesTableView;
    [_scenesTableView setDelegate:scenesTVC];
    [_scenesTableView setDataSource:scenesTVC];
    scenesTVC.notifyParentViewController = YES;
    
    venuesTVC = [[GenericTableViewController alloc] init];
    venuesTVC.tableView = _venuesTableView;
    [_venuesTableView setDelegate:venuesTVC];
    [_venuesTableView setDataSource:venuesTVC];
    
    // Register to listen for updateLocation
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sceneRowSelected:)
     name:@"rowSelected"
     object:nil ];
    
    NSArray *permissions = [NSArray arrayWithObjects: @"publish_actions", @"manage_pages", @"publish_stream", nil];
    
    [[FBSession activeSession] requestNewPublishPermissions:permissions
                                            defaultAudience:FBSessionDefaultAudienceFriends
                                          completionHandler:^(FBSession *session, NSError *error) {
                                              [self getFacebookPages];
                                          }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Notifications
- (void)sceneRowSelected:(NSNotification *)notification
{
    NSLog(@"%@", notification.object);
    NSLog(@"%@", [notification.object objectForKey:@"SceneName"]);
    
    [self updateVenuesTable:((NSString *) [notification.object objectForKey:@"SceneName"])];
}

#pragma IBOutlets
- (IBAction)didClickDebugButton:(id)sender
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    DebugViewController *debugViewController = [sb instantiateViewControllerWithIdentifier:@"DebugViewController"];
    [self presentViewController: debugViewController animated:YES completion:nil];
}

- (IBAction)didClickSendLocation:(id)sender
{
    NSString *errorMsg;
    [self.view endEditing:TRUE]; //Resign firstresponder for all textboxes on the view
    
    if(_cityNameTextField.text.length == 0)
        errorMsg = @"City must contain at least one character...";
    else if(_stateNameTextField.text.length == 0)
        errorMsg = @"State must contain at least one character...";
    else
    {
        [self getScenes];
        return;
    }
    
    // Let the user know that it was a failure
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)didClickAddAdmin:(id)sender
{
    if([self isEverythingSelectedAndCorrect] == false)
    {
        return;
    }
    
    NSString *venueID = [scenesListModel getVenueIDFromVenue:venuesTVC.selectedCellName andScene:scenesTVC.selectedCellName];
    
    [self addAdmin:venueID];
}

- (IBAction)didClickLogoutButton:(id)sender
{
    [self logout];
}


#pragma Network Activity
- (void)requestDidFinishLoadingWithDictionary:(NSDictionary *)result
{
    networkActivity--;
    if(networkActivity == 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // List Scenes
    if([result objectForKey:@"ListScenes_Info"])
    {
        if([[[result objectForKey:@"ListScenes_Info"] objectForKey:@"status"] boolValue] == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"ListScenes_Info"] objectForKey:@"error"]);
            //[self showAlert:[[result objectForKey:@"ListScenes_Info"] objectForKey:@"error"]];
            return;
        }
        
        scenesListModel = [[ScenesListModel alloc] init];
        [scenesListModel initWithJSONResultDictionary:result];
        scenesTVC.model = [scenesListModel getScenes];
        [scenesTVC.tableView reloadData];
    }
    // Facebook Pages
    else if([result objectForKey:@"FacebookPages_Info"])
    {
        NSLog(@"FacebookPages_Info:");
        
        // If there was an error, print it to the log
        if (((NSString *)[[result objectForKey:@"FacebookPages_Info"] objectForKey:@"status"]).boolValue == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"FacebookPages_Info"] objectForKey:@"error"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
            
            // Let the user know that it was a failure
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:(NSString *)[[result objectForKey:@"FacebookPages_Info"] objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        
        // Initialize tables
        facebookPagesTVC.model = [model initializeFacebookPages:result];
        [facebookPagesTVC.tableView reloadData];
    }
    // Facebook Pages
    else if([result objectForKey:@"AddAdmin_Info"])
    {
        NSLog(@"AddAdmin_Info:");
        
        // If there was an error, print it to the log
        if (((NSString *)[[result objectForKey:@"AddAdmin_Info"] objectForKey:@"status"]).boolValue == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"AddAdmin_Info"] objectForKey:@"error"]);
            
            // Let the user know that it was a failure
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:(NSString *)[[result objectForKey:@"AddAdmin_Info"] objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"Admin successfully added!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
    else if([[result objectForKey:@"Logout_Info"] objectForKey:@"status"])
    {
        if([[[result objectForKey:@"Logout_Info"] objectForKey:@"status"] boolValue] == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"Logout_Info"] objectForKey:@"error"]);
        }
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if(FBSession.activeSession.isOpen)
            [appDelegate closeSession];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
    }
}

# pragma BreakoutLeague
- (void)makeRequestWithPath:(NSString *)path variables:(NSString *)variables andSecure:(BOOL)secure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    networkActivity++;
    
    NSString *theBaseURL;
    if(secure == YES)
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

#pragma Network Client Functions
- (void)logout
{
    NSLog(@"logout:");
    
    // Pass the location to the server
    NSString *requestVariables = @"";
    [self makeRequestWithPath:@"Logout" variables:requestVariables andSecure:YES];
}

- (void)getScenes
{
    // Post to server
    NSString *requestVariables = [NSString stringWithFormat:@"&arg=%@%@&arg=%f&arg=%f", [_cityNameTextField.text encodedURLString], _stateNameTextField.text, 0.0f, 0.0f];
    [self makeRequestWithPath:@"ListScenes" variables:requestVariables andSecure:YES];
}

- (void)getFacebookPages
{
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@""];
    [self makeRequestWithPath:@"GetFacebookPages" variables:requestVariables andSecure:YES];
}

- (void)addAdmin:(NSString *)venueID
{
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@"&arg=%@", venueID];
    [self makeRequestWithPath:@"AddAdmin" variables:requestVariables andSecure:YES];
}


#pragma Other Functions
- (void)updateVenuesTable:(NSString *)sceneName
{
    
    venuesTVC.model = [scenesListModel getVenuesFromScene:sceneName];
    [venuesTVC.tableView reloadData];
}
                            
- (BOOL)isEverythingSelectedAndCorrect
{
    NSString *errorMsg;
    
    if(facebookPagesTVC.selectedCellName == nil)
        errorMsg = @"No Facebook Page was selected...";
    else if(scenesTVC.selectedCellName == nil)
        errorMsg = @"No scene was selected...";
    else if(venuesTVC.selectedCellName == nil)
        errorMsg = @"No Music Type was selected...";
    else
        return true;
    
    // Let the user know that it was a failure
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    
    return false;
}

@end
