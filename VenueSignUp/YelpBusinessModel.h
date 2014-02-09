//
//  YelpBusinessModel.h
//  VenueSignUp
//
//  Created by Justin Oliver on 12/24/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YelpBusinessModel : NSObject

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *displayAddress;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *streetAddress;
@property (nonatomic, strong) NSString *yelpID;
@property (nonatomic, assign) BOOL is_closed;

@end
