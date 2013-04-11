//
//  CreateVenueViewController.h
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkJSONRequest.h"

@interface CreateVenueViewController : UIViewController <UITextFieldDelegate, NetworkJSONRequestDelegate>

@property (strong, nonatomic) IBOutlet UITableView *scenesTableView;
@property (strong, nonatomic) IBOutlet UITableView *sceneTypesTableView;
@property (strong, nonatomic) IBOutlet UITableView *musicTypesTableView;
@property (strong, nonatomic) IBOutlet UITableView *facebookPagesTableView;
@property (strong, nonatomic) IBOutlet UITextField *venueNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *streetAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *cityTextField;
@property (strong, nonatomic) IBOutlet UITextField *stateTextField;

@end
