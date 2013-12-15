//
//  CreateVirtualVenueViewController.h
//  VenueSignUp
//
//  Created by Justin Oliver on 7/14/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateVenueModel.h"
#import "GenericTableViewController.h"
#import "VenueSignUpConstants.h"
#import "BreakoutLeagueURLConnection.h"
#define TEXT_FIELD_ADJUSTMENT 250

@interface CreateVirtualVenueViewController : UIViewController <UITextFieldDelegate, BreakoutLeagueURLConnectDelegate>
{
    CreateVenueModel *model;
    
    GenericTableViewController *scenesTVC;
    GenericTableViewController *sceneTypesTVC;
    GenericTableViewController *musicTypesTVC;
    GenericTableViewController *facebookPagesTVC;
}

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UITableView *scenesTableView;
@property (strong, nonatomic) IBOutlet UITableView *sceneTypesTableView;
@property (strong, nonatomic) IBOutlet UITableView *musicTypesTableView;
@property (strong, nonatomic) IBOutlet UITableView *facebookPagesTableView;
@property (strong, nonatomic) IBOutlet UITextField *twitterUsernameTextField;
@property (strong, nonatomic) NSString *streetAddressString;
@property (strong, nonatomic) NSString *cityString;
@property (strong, nonatomic) NSString *stateString;
@property (strong, nonatomic) NSString *venueNameString;
@property (strong, nonatomic) NSString *latitudeString;
@property (strong, nonatomic) NSString *longitudeString;

@end