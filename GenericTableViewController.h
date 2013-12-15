//
//  GenericTableViewController.h
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *model;
@property (strong, nonatomic) NSString *selectedCellName;
@property (nonatomic, assign) BOOL notifyParentViewController;

@end
