//
//  CreateVenueModel.h
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateVenueModel : NSObject

@property (strong, nonatomic) NSMutableDictionary *facebookPages;

- (NSArray *)initializeFacebookPages:(NSDictionary *)resultJson;

@end
