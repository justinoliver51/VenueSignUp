//
//  VenueInfoModel.h
//  VenueSignUp
//
//  Created by Justin Oliver on 12/24/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueInfoModel : NSObject

@property (strong, nonatomic) NSMutableDictionary *yelpBusinesses;

- (NSArray *)initializeYelpBusinessesFromResult:(NSDictionary *)resultDictionary;

@end
