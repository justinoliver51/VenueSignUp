//
//  DebugViewController.h
//  VenueSignUp
//
//  Created by Justin Oliver on 7/15/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkJSONRequest.h"
#define baseURLDebug "/SceneCheckServer/RemoteProcedureCall?function="

@interface DebugViewController : UIViewController <NetworkJSONRequestDelegate>

@property (strong, nonatomic) IBOutlet UITextField *urlTextField;

@end
