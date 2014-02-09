//
//  CreateMapViewController.m
//  VenueSignUp
//
//  Created by Justin Oliver on 2/1/14.
//  Copyright (c) 2014 SceneCheck. All rights reserved.
//

#import "CreateMapViewController.h"
#import "AppDelegate.h"

#define METERS_PER_MILE 0.000621371

@interface CreateMapViewController ()

@end

@implementation CreateMapViewController

@synthesize centerLatitudeLabel = _centerLatitudeLabel;
@synthesize centerLongitudeLabel = _centerLongitudeLabel;
@synthesize xSpanLabel = _xSpanLabel;
@synthesize ySpanLabel = _ySpanLabel;
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
	
    // Set up the delegate
    _mapView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma IBActions
- (IBAction)didClickCreateSceneMapButton:(id)sender
{
    if([self isEverythingSelectedAndCorrect] == false)
    {
        return;
    }
    
    [self createMap];
}

#pragma MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    _centerLatitudeLabel.text = [NSString stringWithFormat:@"%f", mapView.region.center.latitude];
    _centerLongitudeLabel.text = [NSString stringWithFormat:@"%f", mapView.region.center.longitude];
    
    MKMapRect mRect = _mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint northMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMaxY(mRect));
    MKMapPoint southMapPoint = MKMapPointMake(MKMapRectGetMidX(mRect), MKMapRectGetMinY(mRect));
    
    _xSpanLabel.text = [NSString stringWithFormat:@"%f", MKMetersBetweenMapPoints(eastMapPoint, westMapPoint) * METERS_PER_MILE];
    _ySpanLabel.text = [NSString stringWithFormat:@"%f", MKMetersBetweenMapPoints(northMapPoint, southMapPoint) * METERS_PER_MILE];

    //_xSpanLabel.text = [NSString stringWithFormat:@"%f", mapView.region.span.latitudeDelta];
    //_ySpanLabel.text = [NSString stringWithFormat:@"%f", mapView.region.span.longitudeDelta];
    
    return;
}

#pragma Other Functions
- (BOOL)isEverythingSelectedAndCorrect
{
    NSString *errorMsg;
    
    if(_cityTextField.text.length == 0)
        errorMsg = @"The city text field is empty...";
    else if(_stateTextField.text.length == 0)
        errorMsg = @"The state text field is empty...";
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

/*

 String stateName = req.getParameter("");
 String mapID = req.getParameter("map_id");
 String centerLatitudeString = req.getParameter("");
 String centerLongitudeString = req.getParameter("");
 String regionLatitudeString = req.getParameter("");
 String regionLongitudeString = req.getParameter("");
 */

#pragma Client API
- (void)createMap
{
    // Make the Login call to the server
    NSString *requestVariables = [NSString stringWithFormat:@"&city_name=%@&state_name=%@&center_latitude=%@&center_longitude=%@&region_latitude=%@&region_longitude=%@&", [_cityTextField.text encodedURLString], [_stateTextField.text encodedURLString], _centerLatitudeLabel.text, _centerLongitudeLabel.text, _xSpanLabel.text, _ySpanLabel.text];
    
    [self makeRequestWithPath:@"CreateSceneMap" variables:requestVariables andSecure:YES];
}

#pragma Network Connection
- (void)requestDidFinishLoadingWithDictionary:(NSDictionary *)result
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if([result objectForKey:@"CreateSceneMap_Info"])
    {
        NSLog(@"CreateSceneMap_Info:");
        
        // If there was an error, print it to the log
        if (((NSString *)[[result objectForKey:@"CreateSceneMap_Info"] objectForKey:@"status"]).boolValue == NO)
        {
            NSLog(@"%@", (NSString *)[[result objectForKey:@"CreateSceneMap_Info"] objectForKey:@"error"]);
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
                                                            message:@"Map successfully created!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
}

@end
