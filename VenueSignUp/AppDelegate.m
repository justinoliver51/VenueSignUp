//
//  AppDelegate.m
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize request = _request;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Set the height and width of the device
    self.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // View will disappear is not called
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // View will appear is not called
    
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    
    // Test the connection to the server
    [self testConnection];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}





// Facebook
NSString *const FBSessionStateChangedNotification =
@"com.SceneCheck.SceneCheckApp:FBSessionStateChangedNotification";

/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"user_likes",
                            nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (NSString *) getFacebookAccessToken
{
    return [[FBSession activeSession] accessToken];;
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)dealloc
{
	if (_request) {
		[_request setDelegate:nil];
		_request = nil;
	}
}

#pragma NetworkActivity
- (void)requestDidFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)requestDidReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // If our session has timed out
    if(([httpResponse statusCode] == 403) || ([httpResponse statusCode] == 404))
    {
        NSLog(@"%ld", (long)[httpResponse statusCode]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionExpired" object:self];
    }
}

- (void)requestDidFinishLoadingWithDictionary:(NSDictionary *)result
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // If we successfully tested the connection
    if([[[result objectForKey:@"TestConnection_Info"] objectForKey:@"status"] boolValue] == YES)
    {
        // Pass the statistic information and get the new advertisement
        [[NSNotificationCenter defaultCenter] postNotificationName:@"adInfo" object:self];
    }
}

- (void)testConnection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *requestVariables = @"";
    NSLog(@"testConnection: %@", requestVariables);
    _request = [NetworkJSONRequest makeRequestWithPath:@"TestConnection" variables:requestVariables delegate:self andSecure:TRUE];
}

@end
