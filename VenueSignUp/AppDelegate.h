//
//  AppDelegate.h
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "VenueSignUpConstants.h"
#import "BreakoutLeagueURLConnection.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BreakoutLeagueURLConnectDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *debugBaseURL;
@property (nonatomic, assign) BOOL debugFlag;

// Facebook
extern NSString *const FBSessionStateChangedNotification;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void)closeSession;
- (NSString *)getFacebookAccessToken;

@end
