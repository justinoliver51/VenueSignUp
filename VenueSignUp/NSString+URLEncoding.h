//
//	NSString+URLEncoding.h
//  TheBroCode
//
//  Created by Hector Matos on 10/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSString (OAURLEncodingAdditions)

- (NSString *)encodedURLString;
- (NSString *)encodedURLParameterString;
- (NSString *)decodedURLString;
- (NSString *)removeQuotes;
- (NSString *)extractURL;
- (NSString *)flattenHTML;
- (NSString *)decodeHTMLEntitiesInString;
- (NSArray *)extractPhoneNumbers;

@end
