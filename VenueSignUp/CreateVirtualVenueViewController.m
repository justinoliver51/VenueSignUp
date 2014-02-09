//
//  CreateVirtualVenueViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 7/14/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "CreateVirtualVenueViewController.h"
#import "AppDelegate.h"
#import "NSString+URLEncoding.h"
#import "FacebookPageModel.h"
#import "DebugViewController.h"
#import "YelpBusinessModel.h"

@interface CreateVirtualVenueViewController ()

@end

@implementation CreateVirtualVenueViewController
{
    UIActivityIndicatorView *facebookPagesSpinner;
    UIActivityIndicatorView *scenesSpinner;
    
    unsigned int networkActivity;
    CGPoint originalCenter;
}

@synthesize navigationBar = _navigationBar;
@synthesize scenesTableView = _scenesTableView;
@synthesize sceneTypesTableView = _sceneTypesTableView;
@synthesize musicTypesTableView = _musicTypesTableView;
@synthesize facebookPagesTableView = _facebookPagesTableView;
@synthesize streetAddressString = _streetAddressString;
@synthesize twitterUsernameTextField = _twitterUsernameTextField;
@synthesize cityString = _cityString;
@synthesize stateString = _stateString;
@synthesize venueNameString = _venueNameString;
@synthesize latitudeString = _latitudeString;
@synthesize longitudeString = _longitudeString;
@synthesize yelpID = _yelpID;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Model
    model = [[CreateVenueModel alloc] init];
    
    
    // Flags
    networkActivity = 0;
    
    // Initialize the four TableViewControllers
    scenesTVC = [[GenericTableViewController alloc] init];
    scenesTVC.tableView = _scenesTableView;
    [_scenesTableView setDelegate:scenesTVC];
    [_scenesTableView setDataSource:scenesTVC];
    
    sceneTypesTVC = [[GenericTableViewController alloc] init];
    sceneTypesTVC.tableView = _sceneTypesTableView;
    [_sceneTypesTableView setDelegate:sceneTypesTVC];
    [_sceneTypesTableView setDataSource:sceneTypesTVC];
    sceneTypesTVC.model = [[NSArray alloc] initWithObjects:
                           @"Alternative", @"Beer/Beer Garden", @"Classic", @"College", @"Cocktail Bar", @"Country Western",@"Dance Club", @"Dive Bar", @"DJ's", @"Electronic",
                           @"Folk", @"Games", @"Greek", @"Hip-Hop", @"Indie", @"International", @"Jazz", @"Latino", @"LGBT",
                           @"Live Music", @"Lounge", @"Metal", @"Pub", @"Night Club", @"Punk", @"Rock", @"Shot Bar", @"Sports Bar",
                           @"Top-40s", nil];
    
    musicTypesTVC = [[GenericTableViewController alloc] init];
    musicTypesTVC.tableView = _musicTypesTableView;
    [_musicTypesTableView setDelegate:musicTypesTVC];
    [_musicTypesTableView setDataSource:musicTypesTVC];
    musicTypesTVC.model = [[NSArray alloc] initWithObjects:
                           @"Alternative", @"Blues", @"Comedy", @"Country/Western", @"Dance", @"Electronic", @"Top 40's", @"Hip-Hop", @"Indie",@"Jazz", @"Latin", @"Lounge", @"Metal", @"Pop", @"Oldies", @"Reggae", @"Rock",
                           nil];
    
    facebookPagesTVC = [[GenericTableViewController alloc] init];
    facebookPagesTVC.tableView = _facebookPagesTableView;
    [_facebookPagesTableView setDelegate:facebookPagesTVC];
    [_facebookPagesTableView setDataSource:facebookPagesTVC];
    
    // NAVIGATION BAR
    self.navigationController.navigationBarHidden = YES;
    self.parentViewController.navigationController.navigationBarHidden = YES;
    self.navigationItem.hidesBackButton = YES;
    /*
     if ([_navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] )
     {
     UIImage *image = [UIImage imageNamed:@"SceneCheck Nav Bar.png"];
     [_navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
     }
     
     // Add a tap gesture
     UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickNavigationBar)];
     tapGestureRecognizer.numberOfTapsRequired = 1;
     [_navigationBar addGestureRecognizer:tapGestureRecognizer];
     _navigationBar.userInteractionEnabled = YES;
     */
    
    // NAVIGATION BAR ITEMS
    // Menu button
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 40, 40)];//[UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"Slider Menu Button.png"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(didClickSignOut) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    self.navigationItem.leftBarButtonItem = menuButtonItem;
    [_navigationBar setItems:[NSArray arrayWithObject:self.navigationItem]];
    
    facebookPagesSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    facebookPagesSpinner.frame = CGRectMake(191, 676, 25, 25);
    [facebookPagesSpinner setColor:[UIColor colorWithRed:0.0f/255.0f green:186.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    facebookPagesSpinner.hidesWhenStopped = YES;
    [self.view bringSubviewToFront:facebookPagesSpinner];
    
    scenesSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    scenesSpinner.frame = CGRectMake(191, 275, 25, 25);
    [scenesSpinner setColor:[UIColor colorWithRed:0.0f/255.0f green:186.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    scenesSpinner.hidesWhenStopped = YES;
    [self.view bringSubviewToFront:scenesSpinner];
    
    NSArray *permissions = [NSArray arrayWithObjects: @"publish_actions", @"manage_pages", @"publish_stream", nil];
    
    [[FBSession activeSession] requestNewPublishPermissions:permissions
                                            defaultAudience:FBSessionDefaultAudienceFriends
                                          completionHandler:^(FBSession *session, NSError *error) {
                                              [self getVirtualVenueFacebookPages];
                                          }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma IBOutlets
- (IBAction)didClickGetFacebookPages:(id)sender
{
    NSArray *permissions = [NSArray arrayWithObjects: @"publish_checkins", @"manage_pages", @"publish_stream", nil];
    
    [[FBSession activeSession] requestNewPublishPermissions:permissions
                                            defaultAudience:FBSessionDefaultAudienceFriends
                                          completionHandler:^(FBSession *session, NSError *error) {
                                              [self getVirtualVenueFacebookPages];
                                          }];
}

- (IBAction)didClickLogoutButton:(id)sender
{
    [self logout];
}

- (IBAction)didClickCreateVenue:(id)sender
{
    if([self isEverythingSelectedAndCorrect] == false)
    {
        return;
    }
    
    
    
    [self createVenue];
}

- (void)didClickSignOut
{
    [self logout];
}

- (IBAction)didClickDebugButton:(id)sender
{
    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    DebugViewController *debugViewController = [sb instantiateViewControllerWithIdentifier:@"DebugViewController"];
    [self presentViewController: debugViewController animated:YES completion:nil];
}

#pragma UITextField Functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
    
    if(originalCenter.y == 0)
        originalCenter = self.view.center;
    
    if(self.view.center.y != originalCenter.y)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.view.center = CGPointMake(originalCenter.x, originalCenter.y);// - TEXT_FIELD_ADJUSTMENT);
        [UIView commitAnimations];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing");
    textField.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    
    if(originalCenter.y == 0)
        originalCenter = self.view.center;
    
    if(self.view.center.y == originalCenter.y)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.view.center = CGPointMake(originalCenter.x, originalCenter.y - TEXT_FIELD_ADJUSTMENT);
        [UIView commitAnimations];
    }
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldEndEditing");
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing");
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"textField:shouldChangeCharactersInRange: %lu replacementString: %@", (unsigned long)range.length, string);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn:");
    [textField resignFirstResponder];
    return YES;
}


#pragma Server API
- (void)createVenue
{
    // Get the information for the new venue
    NSString *venueName = [_venueNameString encodedURLString];
    NSString *scene = [scenesTVC.selectedCellName encodedURLString];
    NSString *city = [_cityString encodedURLString];
    NSString *state = [_stateString encodedURLString];
    NSString *latitude = _latitudeString;
    NSString *longitude = _longitudeString;
    NSString *musicTypes = [musicTypesTVC.selectedCellName encodedURLString];
    NSString *sceneTypes = [sceneTypesTVC.selectedCellName encodedURLString];
    NSString *facebookPageName = [facebookPagesTVC.selectedCellName encodedURLString];
    NSString *twitterUsername = _twitterUsernameTextField.text;
    NSString *yelpID = [_yelpID encodedURLString];
    
    // Get the Facebook ID
    FacebookPageModel *page = [model.facebookPages objectForKey:facebookPagesTVC.selectedCellName];
    NSString *facebookID = [page.facebookID encodedURLString];
    
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@"&venue_name=%@&geoscenes=%@&city_id=%@%@&latitude=%@&longitude=%@&music_types=%@&scene_types=%@&facebook_page_name=%@&facebook_id=%@&twitter_username=%@&yelp_id=%@", venueName, scene, city, state, latitude, longitude, musicTypes, sceneTypes, facebookPageName, facebookID, twitterUsername, yelpID];
    [self makeRequestWithPath:@"CreateVenue" variables:requestVariables andSecure:YES];
}

- (void)getScenesInCity:(NSString *)city andState:(NSString *)state
{
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@"&city_id=%@%@", [_cityString encodedURLString], [_stateString encodedURLString]];
    [self makeRequestWithPath:@"GetScenes" variables:requestVariables andSecure:YES];
}

- (void)getSceneTypesAndMusicTypes
{
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@""];
    [self makeRequestWithPath:@"GetSceneTypesAndMusicTypes" variables:requestVariables andSecure:YES];
}

- (void)getVirtualVenueFacebookPages
{
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@""];
    [self makeRequestWithPath:@"GetVirtualVenueFacebookPages" variables:requestVariables andSecure:YES];
}

- (void)logout
{
    // Pass the location to the server
    NSString *requestVariables = @"";
    [self makeRequestWithPath:@"Logout" variables:requestVariables andSecure:YES];
}

#pragma Network Connection
- (void)requestDidFinishLoadingWithDictionary:(NSDictionary *)result
{
    networkActivity--;
    if(networkActivity == 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // GetSignUpVenueTablesInfo
    if([result objectForKey:@"FacebookPages_Info"])
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
        [facebookPagesSpinner stopAnimating];
        facebookPagesTVC.model = [model initializeFacebookPages:result];
        [facebookPagesTVC.tableView reloadData];
        
        [self getScenesInCity:_cityString andState:_stateString];
    }
    else if([result objectForKey:@"GetScenes_Info"])
    {
        NSLog(@"GetScenes_Info:");
        
        // If there was an error, print it to the log
        if (((NSString *)[[result objectForKey:@"GetScenes_Info"] objectForKey:@"status"]).boolValue == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"GetScenes_Info"] objectForKey:@"error"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
            
            // Let the user know that it was a failure
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:(NSString *)[[result objectForKey:@"GetScenes_Info"] objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        
        // Initialize tables
        [scenesSpinner stopAnimating];
        scenesTVC.model = [[result objectForKey:@"GetScenes_Info"] objectForKey:@"scenesArray"];
        [scenesTVC.tableView reloadData];
        
        //[self getSceneTypesAndMusicTypes];
    }
    else if([result objectForKey:@"SceneTypesAndMusicTypes_Info"])
    {
        NSLog(@"SceneTypesAndMusicTypes_Info:");
        
        // If there was an error, print it to the log
        if (((NSString *)[[result objectForKey:@"SceneTypesAndMusicTypes_Info"] objectForKey:@"status"]).boolValue == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"SceneTypesAndMusicTypes_Info"] objectForKey:@"error"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
            
            // Let the user know that it was a failure
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:(NSString *)[[result objectForKey:@"SceneTypesAndMusicTypes_Info"] objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        
        // Initialize tables
        musicTypesTVC.model = [[result objectForKey:@"SceneTypesAndMusicTypes_Info"] objectForKey:@"musicTypesArray"];
        [musicTypesTVC.tableView reloadData];
        
        sceneTypesTVC.model = [[result objectForKey:@"SceneTypesAndMusicTypes_Info"] objectForKey:@"sceneTypesArray"];
        [sceneTypesTVC.tableView reloadData];
    }
    else if([result objectForKey:@"CreateVenue_Info"])
    {
        NSLog(@"CreateVenue_Info:");
        
        // If there was an error, print it to the log
        if (((NSString *)[[result objectForKey:@"CreateVenue_Info"] objectForKey:@"status"]).boolValue == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"CreateVenue_Info"] objectForKey:@"error"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
            
            // Let the user know that it was a failure
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:(NSString *)[[result objectForKey:@"CreateVenue_Info"] objectForKey:@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        
        // Let the user know that it was a success...
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:@"Venue successfully created!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
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

- (void)makeRequest:(OAMutableURLRequest *)request
{
    BreakoutLeagueURLConnection *urlConnection = [[BreakoutLeagueURLConnection alloc] init];
    urlConnection.delegate = self;
    [urlConnection performRequest:request];
    
    NSLog(@"%@", request.URL.lastPathComponent);
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
}

#pragma Other Functions
- (BOOL)isEverythingSelectedAndCorrect
{
    NSString *errorMsg;
    
    if(scenesTVC.selectedCellName == nil)
        errorMsg = @"No scene was selected...";
    else if(sceneTypesTVC.selectedCellName == nil)
        errorMsg = @"No Scene Type was selected...";
    else if(musicTypesTVC.selectedCellName == nil)
        errorMsg = @"No Music Type was selected...";
    else if(facebookPagesTVC.selectedCellName == nil)
        errorMsg = @"No Facebook Page was selected...";
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

