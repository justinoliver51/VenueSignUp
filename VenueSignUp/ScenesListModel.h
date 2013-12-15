//
//  ScenesListModel.h
//  VenueSignUp
//
//  Created by Justin Oliver on 6/8/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SceneModel.h"
#import "VenueModel.h"

@interface ScenesListModel : NSObject

@property (nonatomic, strong) NSMutableArray *scenesArray;

- (void)initWithJSONResultDictionary:(NSDictionary *)resultDictionary;
- (NSMutableArray *)getScenes;
- (NSMutableArray *)getVenuesFromScene:(NSString *)sceneName;
- (NSString *)getVenueIDFromVenue:(NSString *)venue andScene:(NSString *)scene;

@end
