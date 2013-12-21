//
//  FacebookPageModel.h
//  VenueSignUp
//
//  Created by Justin Oliver on 4/12/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookPageModel : NSObject

@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *category;

@end
