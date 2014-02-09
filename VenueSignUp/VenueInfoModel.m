//
//  VenueInfoModel.m
//  VenueSignUp
//
//  Created by Justin Oliver on 12/24/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#import "VenueInfoModel.h"
#import "YelpBusinessModel.h"

@implementation VenueInfoModel

@synthesize yelpBusinesses = _yelpBusinesses;

- (NSArray *)initializeYelpBusinessesFromResult:(NSDictionary *)resultDictionary
{
    NSArray *yelpBusinesses = [resultDictionary objectForKey:@"businesses"];
    NSMutableArray *yelpBusinessNames = [NSMutableArray array];
    
    _yelpBusinesses = [NSMutableDictionary dictionary];
    
    for (NSDictionary *business in yelpBusinesses)
    {
        YelpBusinessModel *newBusiness = [[YelpBusinessModel alloc] init];
        newBusiness.name = [business objectForKey:@"name"];
        newBusiness.yelpID = [business objectForKey:@"id"];
        newBusiness.is_closed = [[business objectForKey:@"is_closed"] boolValue];
        NSMutableString *address = [NSMutableString string];
        
        // Gets the display address
        for (NSString *addressString in [[business objectForKey:@"location"] objectForKey:@"display_address"])
        {
            [address appendString:addressString];
            [address appendString:@"\n"];
        }
        
        newBusiness.displayAddress = address;
        address = [NSMutableString string];
        
        // Gets the address
        for (NSString *addressString in [[business objectForKey:@"location"] objectForKey:@"address"])
        {
            [address appendString:addressString];
            [address appendString:@" "];
        }
        
        newBusiness.streetAddress = address;
        newBusiness.city = [[business objectForKey:@"location"] objectForKey:@"city"];
        newBusiness.state = [[business objectForKey:@"location"] objectForKey:@"state_code"];
        
        [yelpBusinessNames addObject:[NSString stringWithFormat:@"%@",newBusiness.name]];
        [_yelpBusinesses setObject:newBusiness forKey:newBusiness.name];
    }
    
    return yelpBusinessNames;
}

/*
 location =             
 {
   address =                 
   (
     "323 E 6th St"
   );
   city = Austin;
   "country_code" = US;
   "display_address" =                 
   (
     "323 E 6th St",
     Downtown,
     "Austin, TX 78701"
   );
   neighborhoods =                 (
    Downtown
   );
   "postal_code" = 78701;
   "state_code" = TX;
 };
 */

@end
