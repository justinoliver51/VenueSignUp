//
//  GetVenueInfoViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 5/28/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "GetVenueInfoViewController.h"
#import "CreateVenueViewController.h"
#import "CreateVirtualVenueViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DebugViewController.h"
#import "AppDelegate.h"
#import "YelpBusinessModel.h"
#import "UILabel+Clipboard.h"

@interface GetVenueInfoViewController ()

@end

@implementation GetVenueInfoViewController
{
    CGPoint originalCenter;
}

@synthesize venueNameTextField = _venueNameTextField;
@synthesize streetAddressTextField = _streetAddressTextField;
@synthesize cityTextField = _cityTextField;
@synthesize stateTextField = _stateTextField;
@synthesize yelpIDTextField = _yelpIDTextField;
@synthesize yelpAddressLabel = _yelpAddressLabel;
@synthesize yelpBusinessesTableView = _yelpBusinessesTableView;

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
    
    // Model
    model = [[VenueInfoModel alloc] init];
    
    // Initialize tableview
    yelpBusinessesTVC = [[GenericTableViewController alloc] init];
    yelpBusinessesTVC.tableView = _yelpBusinessesTableView;
    yelpBusinessesTVC.notifyParentViewController = YES;
    [_yelpBusinessesTableView setDelegate:yelpBusinessesTVC];
    [_yelpBusinessesTableView setDataSource:yelpBusinessesTVC];
    
    // Register to listen for updateLocation
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(yelpBusinessRowSelected:)
     name:@"rowSelected"
     object:nil ];
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
    
    if( (textField.tag == 2 || textField.tag == 3 || textField.tag == 4) && (self.view.center.y == originalCenter.y) )
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
    
    // 
    if( (textField.tag == 2 || textField.tag == 3 || textField.tag == 4) && (self.view.center.y != originalCenter.y) )
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        self.view.center = CGPointMake(originalCenter.x, originalCenter.y - TEXT_FIELD_ADJUSTMENT);
        [UIView commitAnimations];
    }
    
    // 
    if ([string isEqualToString:@"#"])
    {
        return NO;
    }
    else if(textField.tag == 4 && textField.text.length >= 2 && range.length == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn:");
    if (textField.tag != 1 && textField.tag < 4)
    {
        UITextField *nextTextField = (UITextField *)[self.view viewWithTag:(textField.tag+1)];
        [nextTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
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
    //[self getScenesInCity:_cityTextField.text andState:[_stateTextField.text uppercaseString]];
    
    // If everything is not correctly selected, return an error
    if([self isEverythingSelectedAndCorrect] == false)
    {
        return;
    }
    
    // USES INFORMATION FROM YELP UNLESS THERE IS OVERRIDE TEXT
    YelpBusinessModel *business;
    NSString *streetAddress;
    NSString *city;
    NSString *state;
    NSString *yelpID;
    
    if(yelpBusinessesTVC.selectedCellName != nil)
        business = [model.yelpBusinesses objectForKey:yelpBusinessesTVC.selectedCellName];
    else
        business = nil;
    
    // Use the selected cell if there isn't override text - Street Address
    if( (([_streetAddressTextField.text isEqualToString:@""] == YES) || (_streetAddressTextField.text == nil)) && (business != nil) )
        streetAddress = business.streetAddress;
    else
        streetAddress = _streetAddressTextField.text;
    
    // Use the selected cell if there isn't override text - City
    if( (([_cityTextField.text isEqualToString:@""] == YES) || (_cityTextField.text == nil)) && (business != nil) )
        city = business.city;
    else
        city = _cityTextField.text;
    
    // Use the selected cell if there isn't override text - State
    if( (([_stateTextField.text isEqualToString:@""] == YES) || (_stateTextField.text == nil)) && (business != nil) )
        state = business.state;
    else
        state = _stateTextField.text;
    
    // Use the selected cell if there isn't override text - YelpID
    if( ([_yelpIDTextField.text isEqualToString:@""] == YES) || (_yelpIDTextField.text == nil) )
        yelpID = business.yelpID;
    else
        yelpID = _yelpIDTextField.text;
    
    // GOOGLE MAPS API
    // Get the location information
    NSString *addressString = [NSString stringWithFormat:@"%@ %@,%@", streetAddress, city, state];
    
    NSString *lookUpString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", addressString];
    lookUpString = [lookUpString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSData *jsonResponse = [NSData dataWithContentsOfURL:[NSURL URLWithString:lookUpString]];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonResponse options:kNilOptions error:nil];
    
    NSArray *locationArray = [[[jsonDict valueForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"];
    
    if(locationArray == nil)
    {
        // Let the user know that it was a failure
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Invalid address..."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    locationArray = [locationArray objectAtIndex:0];
    
    NSString *latitudeString = [locationArray valueForKey:@"lat"];
    NSString *longitudeString = [locationArray valueForKey:@"lng"];
    
    NSLog(@"LatitudeString:%@ & LongitudeString:%@", latitudeString, longitudeString);
    
    // Open next view controller
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([[defaults objectForKey:@"signUpButton"] isEqualToString:@"signUp"])
    {
        // Capture Screenshot
        UIGraphicsBeginImageContext(self.view.bounds.size);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(screenshotImage, nil, nil, nil);
        
        CreateVenueViewController *createVenueViewController = [sb instantiateViewControllerWithIdentifier:@"CreateVenueViewController"];
        createVenueViewController.venueNameString = _venueNameTextField.text;
        createVenueViewController.streetAddressString = streetAddress;
        createVenueViewController.cityString = city;
        createVenueViewController.stateString = state;
        createVenueViewController.latitudeString = latitudeString;
        createVenueViewController.longitudeString = longitudeString;
        //createVenueViewController.yelpID = yelpID;
        
        [self.navigationController pushViewController:createVenueViewController animated:YES];
    }
    else if([[defaults objectForKey:@"signUpButton"] isEqualToString:@"adHoc"])
    {
        CreateVirtualVenueViewController *createVirtualVenueViewController = [sb instantiateViewControllerWithIdentifier:@"CreateVirtualVenueViewController"];
        createVirtualVenueViewController.venueNameString = _venueNameTextField.text;
        createVirtualVenueViewController.latitudeString = latitudeString;
        createVirtualVenueViewController.longitudeString = longitudeString;
        createVirtualVenueViewController.streetAddressString = streetAddress;
        createVirtualVenueViewController.cityString = city;
        createVirtualVenueViewController.stateString = state;
        createVirtualVenueViewController.yelpID = yelpID;
        
        [self.navigationController pushViewController:createVirtualVenueViewController animated:YES];
    }
}

- (IBAction)didClickSentToYelp:(id)sender
{
    // Dump the table
    yelpBusinessesTVC.model = nil;
    [_yelpBusinessesTableView reloadData];
    
    // Get the Yelp information
    [self getYelpInformationForVenue:_venueNameTextField.text];
}

- (BOOL)isEverythingSelectedAndCorrect
{
    NSString *errorMsg;
    
    BOOL validSelectedBusiness = ([model.yelpBusinesses count] > 0) && (yelpBusinessesTVC.selectedCellName != nil);
    
    if(_venueNameTextField.text.length == 0)
        errorMsg = @"Venue name must contain at least one character...";
    else if( (yelpBusinessesTVC.selectedCellName == nil) && ([model.yelpBusinesses count] > 0) )
        errorMsg = @"No Yelp business was selected... Please select one even if you have not found a match.";
    else if( (_streetAddressTextField.text.length == 0) && ((validSelectedBusiness == FALSE) || ([(YelpBusinessModel *) [model.yelpBusinesses objectForKey:yelpBusinessesTVC.selectedCellName] streetAddress] == nil)) )
        errorMsg = @"Illegal address, Street field...";
    else if( (_cityTextField.text.length == 0) && ((validSelectedBusiness == FALSE) || ([(YelpBusinessModel *) [model.yelpBusinesses objectForKey:yelpBusinessesTVC.selectedCellName] city] == nil)) )
        errorMsg = @"Illegal address, City field...";
    else if( (_stateTextField.text.length == 0) && ((validSelectedBusiness == FALSE) || ([(YelpBusinessModel *) [model.yelpBusinesses objectForKey:yelpBusinessesTVC.selectedCellName] state] == nil)) )
        errorMsg = @"Illegal address, State field...";
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

#pragma Yelp API
- (void)getYelpInformationForVenue:(NSString *)venueName
{
    NSString *theURL = [NSString stringWithFormat:@"%@term=%@&location=%@", YELP_URL_BASE, [venueName encodedURLString], [_cityTextField.text encodedURLString]];
    NSURL *URL = [NSURL URLWithString:theURL];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:YELP_CONSUMER_KEY secret:YELP_CONSUMER_SECRET];
    OAToken *token = [[OAToken alloc] initWithKey:YELP_TOKEN secret:YELP_TOKEN_SECRET];
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init];
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    
    [request prepare];
    [self makeRequest:request];
}

#pragma Network Connection
- (void)requestDidFinishLoadingWithDictionary:(NSDictionary *)result
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if([result objectForKey:@"businesses"])
    {
        // Initialize tables
        yelpBusinessesTVC.model = [model initializeYelpBusinessesFromResult:result];
        [yelpBusinessesTVC.tableView reloadData];
    }
    else if([result objectForKey:@"error"])
    {
        NSString *error = [NSString stringWithFormat:@"The error is described below:\n%@", result];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:error
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

# pragma BreakoutLeague
- (void)makeRequestWithPath:(NSString *)path variables:(NSString *)variables andSecure:(BOOL)secure
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
}

#pragma Notifications
- (void)yelpBusinessRowSelected:(NSNotification *)notification
{
    NSLog(@"%@", notification.object);
    NSLog(@"%@", [notification.object objectForKey:@"SceneName"]);
    
    [self updateBusinessesTable:((NSString *) [notification.object objectForKey:@"SceneName"])];
}

#pragma Other Functions
- (void)updateBusinessesTable:(NSString *)businessName
{
    YelpBusinessModel *business = [model.yelpBusinesses objectForKey:businessName];
    _yelpAddressLabel.text = business.displayAddress;
    _yelpIDTextField.text = business.yelpID;
    [_yelpBusinessesTableView reloadData];
}

@end
