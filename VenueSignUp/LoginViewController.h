//
//  LoginViewController.h
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BreakoutLeagueURLConnection.h"

@interface LoginViewController : UIViewController <UIScrollViewDelegate, BreakoutLeagueURLConnectDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@end
