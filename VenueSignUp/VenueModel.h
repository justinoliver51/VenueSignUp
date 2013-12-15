//
//  VenueModel.h
//  VenueSignUp
//
//  Created by Justin Oliver on 6/8/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *venueID;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSString *facebookID;
@property (nonatomic, strong) NSString *facebookURL;
@property (nonatomic, strong) NSString *facebookPageName;
@property (nonatomic, strong) NSString *sceneID;

@end
