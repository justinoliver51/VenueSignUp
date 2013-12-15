//
//  GetVenueInfoViewController.h
//  VenueSignUp
//
//  Created by Justin Oliver on 5/28/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TEXT_FIELD_ADJUSTMENT 250

@interface GetVenueInfoViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *venueNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *streetAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *cityTextField;
@property (strong, nonatomic) IBOutlet UITextField *stateTextField;

@end
