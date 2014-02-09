//
//  CreateVenueModel.m
//  VenueSignUp
//
//  Created by Justin Oliver on 4/10/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "CreateVenueModel.h"
#import "FacebookPageModel.h"
#import "YelpBusinessModel.h"

@implementation CreateVenueModel

@synthesize facebookPages = _facebookPages;

- (NSArray *)initializeFacebookPages:(NSDictionary *)resultDictionary
{
    NSArray *facebookPageArray = [[resultDictionary objectForKey:@"FacebookPages_Info"] objectForKey:@"facebookPages"];
    NSMutableArray *facebookPageNames = [NSMutableArray array];
    
    _facebookPages = [NSMutableDictionary dictionary];
    
    for (NSDictionary *pageDictionary in facebookPageArray)
    {
        FacebookPageModel *page = [[FacebookPageModel alloc] init];
        page.name = [pageDictionary objectForKey:@"name"];
        page.facebookID = [pageDictionary objectForKey:@"id"];
        page.accessToken = [pageDictionary objectForKey:@"access_token"];
        page.category = [pageDictionary objectForKey:@"category"];

        [facebookPageNames addObject:page.name];
        [_facebookPages setObject:page forKey:page.name];
    }
    
    return facebookPageNames;
}

@end
