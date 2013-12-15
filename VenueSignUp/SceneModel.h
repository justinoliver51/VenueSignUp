//
//  SceneModel.h
//  VenueSignUp
//
//  Created by Justin Oliver on 6/8/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SceneModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *locationID;
@property (nonatomic, strong) NSMutableArray *venuesArray;
@property (nonatomic, strong) NSMutableArray *annotationsArray;

@end
