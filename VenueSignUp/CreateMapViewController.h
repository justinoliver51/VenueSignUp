//
//  CreateMapViewController.h
//  VenueSignUp
//
//  Created by Justin Oliver on 2/1/14.
//  Copyright (c) 2014 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BreakoutLeagueURLConnection.h"
#import "VenueSignUpConstants.h"

@interface CreateMapViewController : UIViewController <MKMapViewDelegate, BreakoutLeagueURLConnectDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *centerLatitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *centerLongitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *xSpanLabel;
@property (strong, nonatomic) IBOutlet UILabel *ySpanLabel;
@property (strong, nonatomic) IBOutlet UITextField *cityTextField;
@property (strong, nonatomic) IBOutlet UITextField *stateTextField;

@end
