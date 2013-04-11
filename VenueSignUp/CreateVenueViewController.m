//
//  CreateVenueViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "CreateVenueViewController.h"
#import "GenericTableViewController.h"

@interface CreateVenueViewController ()

@end

@implementation CreateVenueViewController
{
    GenericTableViewController *scenesTVC;
    GenericTableViewController *sceneTypesTVC;
    GenericTableViewController *musicTypesTVC;
    GenericTableViewController *facebookPagesTVC;
    
    unsigned int networkActivity;
    NSString *latitudeString;
    NSString *longitudeString;
}

@synthesize request = _request;
@synthesize scenesTableView = _scenesTableView;
@synthesize sceneTypesTableView = _sceneTypesTableView;
@synthesize musicTypesTableView = _musicTypesTableView;
@synthesize facebookPagesTableView = _facebookPagesTableView;
@synthesize venueNameTextField = _venueNameTextField;
@synthesize streetAddressTextField = _streetAddressTextField;
@synthesize cityTextField = _cityTextField;
@synthesize stateTextField = _stateTextField;

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
    
    // Initialize the four TableViewControllers
    scenesTVC = [[GenericTableViewController alloc] init];
    scenesTVC.tableView = _scenesTableView;
    [_scenesTableView setDelegate:scenesTVC];
    [_scenesTableView setDataSource:scenesTVC];
    scenesTVC.model = [NSArray arrayWithObjects:@"Scene1", @"Scene2", @"Scene3", nil];

    sceneTypesTVC = [[GenericTableViewController alloc] init];
    sceneTypesTVC.tableView = _sceneTypesTableView;
    [_sceneTypesTableView setDelegate:sceneTypesTVC];
    [_sceneTypesTableView setDataSource:sceneTypesTVC];
    sceneTypesTVC.model = [NSArray arrayWithObjects:@"SceneType1", @"SceneType2", @"SceneType3", nil];
    
    musicTypesTVC = [[GenericTableViewController alloc] init];
    musicTypesTVC.tableView = _musicTypesTableView;
    [_musicTypesTableView setDelegate:musicTypesTVC];
    [_musicTypesTableView setDataSource:musicTypesTVC];
    musicTypesTVC.model = [NSArray arrayWithObjects:@"MusicType1", @"MusicType2", @"MusicType3", nil];
    
    facebookPagesTVC = [[GenericTableViewController alloc] init];
    facebookPagesTVC.tableView = _facebookPagesTableView;
    [_facebookPagesTableView setDelegate:facebookPagesTVC];
    [_facebookPagesTableView setDataSource:facebookPagesTVC];
    facebookPagesTVC.model = [NSArray arrayWithObjects:@"FacebookPage1", @"FacebookPage2", @"FacebookPage3", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITextField Functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldShouldBeginEditing");
    textField.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
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
    NSLog(@"textField:shouldChangeCharactersInRange:replacementString:");
    if ([string isEqualToString:@"#"]) {
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn:");
    if (textField.tag == 1) {
        UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:2];
        [passwordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma IBOutlets
- (IBAction)didClickSendLocation:(id)sender
{
    [self getScenesInCity:_cityTextField.text andState:_stateTextField.text];
}

- (IBAction)didClickCreateVenue:(id)sender
{
    if([self isEverythingSelected] == false)
    {
        return;
    }
    
    NSString *addressString = [NSString stringWithFormat:@"%@ %@,%@", _streetAddressTextField.text, _cityTextField.text, _stateTextField.text];
    
    NSString *lookUpString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", addressString];
    lookUpString = [lookUpString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:lookUpString]];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonResponse options:kNilOptions error:nil];
    
    NSArray *locationArray = [[[jsonDict valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"];
    locationArray = [locationArray objectAtIndex:0];
    
    latitudeString = [locationArray valueForKey:@"lat"];
    longitudeString = [locationArray valueForKey:@"lng"];
    
    NSLog(@"LatitudeString:%@ & LongitudeString:%@", latitudeString, longitudeString);
    
    [self createVenue];
}

#pragma Server API
- (void)createVenue
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    networkActivity++;
    
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@"&arg=%@&arg=%@&arg=%@", @"", @"", _venueNameTextField.text];
    NSLog(@"login: %@", requestVariables);
    _request = [NetworkJSONRequest makeRequestWithPath:@"Login" variables:requestVariables delegate:self andSecure:TRUE];
}

- (void)getScenesInCity:(NSString *)city andState:(NSString *)state
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    networkActivity++;
    
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@"&arg=%@,%@", _cityTextField.text, _stateTextField.text];
    NSLog(@"getScenesInCity: %@", requestVariables);
    _request = [NetworkJSONRequest makeRequestWithPath:@"GetScenes" variables:requestVariables delegate:self andSecure:TRUE];
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
    
    // GetSignUpVenueTablesInfo
    if([result objectForKey:@"GetSignUpVenueTablesInfo_Info"])
    {
        NSLog(@"GetSignUpVenueTablesInfo_Info:");
        
        // If there was an error, print it to the log
        if (((NSString *)[result objectForKey:@"GetSignUpVenueTablesInfo_Info"]).boolValue == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"GetSignUpVenueTablesInfo_Info"] objectForKey:@"error"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
            
            return;
        }
        
        // Initialize tables
        
    }
    else if([result objectForKey:@"CreateVenue_Info"])
    {
        NSLog(@"CreateVenue_Info:");
        
        // If there was an error, print it to the log
        if (((NSString *)[result objectForKey:@"CreateVenue_Info"]).boolValue == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"CreateVenue_Info"] objectForKey:@"error"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
            
            return;
        }
        
        // Let the user know that it was a success...
    }
}

#pragma Other Functions
- (BOOL)isEverythingSelected
{
    return true;
}

@end
