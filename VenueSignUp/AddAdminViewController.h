//
//  AddAdminViewController.h
//  VenueSignUp
//
//  Created by Justin Oliver on 6/8/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import "CreateVenueModel.h"
#import "VenueSignUpConstants.h"
#import "BreakoutLeagueURLConnection.h"

@interface AddAdminViewController : UIViewController <BreakoutLeagueURLConnectDelegate>
{
    GenericTableViewController *scenesTVC;
    GenericTableViewController *facebookPagesTVC;
    GenericTableViewController *venuesTVC;
    
    CreateVenueModel *model;
}

@property (strong, nonatomic) IBOutlet UITableView *facebookPagesTableView;
@property (strong, nonatomic) IBOutlet UITableView *scenesTableView;
@property (strong, nonatomic) IBOutlet UITableView *venuesTableView;
@property (strong, nonatomic) IBOutlet UITextField *cityNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *stateNameTextField;

@end
