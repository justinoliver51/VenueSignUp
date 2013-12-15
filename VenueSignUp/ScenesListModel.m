//
//  ScenesListModel.m
//  VenueSignUp
//
//  Created by Justin Oliver on 6/8/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "ScenesListModel.h"

@implementation ScenesListModel

@synthesize scenesArray = _scenesArray;

- (void)initWithJSONResultDictionary:(NSDictionary *)resultDictionary
{
    NSArray *theScenesArray = [resultDictionary objectForKey:@"ScenesArray"];
    _scenesArray = [NSMutableArray array];
    
    for(NSDictionary *scenesDictionary in theScenesArray)
    {
        SceneModel *scene = [[SceneModel alloc] init];
        scene.name = [scenesDictionary objectForKey:@"name"];
        scene.locationID = [scenesDictionary objectForKey:@"locationID"];
        scene.venuesArray = [NSMutableArray array];
        scene.annotationsArray = [NSMutableArray array];
        
        NSArray *theVenuesArray = [scenesDictionary objectForKey:@"venuesArray"];
        
        for(NSDictionary *venuesDictionary in theVenuesArray)
        {
            VenueModel *venue = [[VenueModel alloc] init];
            venue.name = [venuesDictionary objectForKey:@"name"];
            venue.longitude = [venuesDictionary objectForKey:@"longitude"];
            venue.latitude = [venuesDictionary objectForKey:@"latitude"];
            venue.venueID = [venuesDictionary objectForKey:@"venueID"];
            
            // Add to venues array
            [scene.venuesArray addObject:venue];
        }
        
        // Add to scenes array
        [_scenesArray addObject:scene];
    }
}

- (NSMutableArray *)getScenes
{
    NSMutableArray *theScenesArray = [NSMutableArray array];
    
    for(SceneModel *newScene in _scenesArray)
    {
        [theScenesArray addObject:newScene.name];
    }
    
    return theScenesArray;
}

- (NSMutableArray *)getVenuesFromScene:(NSString *)sceneName
{
    NSMutableArray *theVenuesArray = [NSMutableArray array];
    
    for(SceneModel *newScene in _scenesArray)
    {
        if([newScene.name isEqualToString:sceneName])
        {
            for(VenueModel *venue in newScene.venuesArray)
                [theVenuesArray addObject:venue.name];
            
            return theVenuesArray;
        }
    }
    
    return nil;
}

- (NSString *)getVenueIDFromVenue:(NSString *)venueName andScene:(NSString *)sceneName
{
    
    for(SceneModel *newScene in _scenesArray)
    {
        if([newScene.name isEqualToString:sceneName])
        {
            for(VenueModel *venue in newScene.venuesArray)
            {
                if([newScene.name isEqualToString:sceneName])
                    return venue.venueID;
            }
            
            return nil;
        }
    }
    
    return nil;
}

@end
