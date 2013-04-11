//
//	NSString+URLEncoding.m
//  TheBroCode
//
//  Created by Hector Matos on 10/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLEncoding.h"


@implementation NSString (OAURLEncodingAdditions)

- (NSString *)encodedURLString {
	NSString *result = [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR("?=&+"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) autorelease];
	return result;
}

- (NSString *)encodedURLParameterString {
	NSString *result = [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR(":/=,!$&'()*+;[]@#?"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) autorelease];
	return result;
}

- (NSString *)decodedURLString {
	NSString *result = [(NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) autorelease];
	return result;
	
}

- (NSString *)removeQuotes
{
	NSUInteger length = [self length];
	NSString *ret = self;
	if ([self characterAtIndex:0] == '"') {
		ret = [ret substringFromIndex:1];
	}
	if ([self characterAtIndex:length - 1] == '"') {
		ret = [ret substringToIndex:length - 2];
	}
	
	return ret;
}

- (NSString *)extractURL
{
	NSString *html = [NSString stringWithString:self];
	NSString *url = nil;
	NSString *text = nil;
	NSScanner *htmlScanner = [NSScanner scannerWithString:html];
	
	while (![htmlScanner isAtEnd]) {
		// find start of tag
		[htmlScanner scanUpToString:@"<a href=" intoString:NULL];
		
		// find end of tag
		[htmlScanner scanUpToString:@" target=" intoString:&text];
		
		// replace the found tag with a space
		//(you can filter multi-spaces out later if you wish)
		if (text) {
			url = [[NSString stringWithFormat:@"%@", text] stringByReplacingOccurrencesOfString:@"<a href=" withString:@""];
		}
	}
	
	return url;
}

- (NSString *)flattenHTML
{
	NSString *html = [NSString stringWithString:self];
	NSString *text = nil;
	NSScanner *htmlScanner = [NSScanner scannerWithString:html];
	
	while (![htmlScanner isAtEnd]) {
		// find start of tag
		[htmlScanner scanUpToString:@"<" intoString:NULL];
		
		// find end of tag
		[htmlScanner scanUpToString:@">" intoString:&text];
		
		// replace the found tag with a space
		//(you can filter multi-spaces out later if you wish)
		html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text]
											   withString:@""];
	}
	
	return [html decodeHTMLEntitiesInString];
}

- (NSString *)decodeHTMLEntitiesInString
{
	NSString *input = [NSString stringWithString:self];
	
	NSMutableString *results = [NSMutableString string];
	NSScanner *scanner = [NSScanner scannerWithString:input];
	[scanner setCharactersToBeSkipped:nil];
	while (![scanner isAtEnd]) {
		NSString *temp;
		if ([scanner scanUpToString:@"&" intoString:&temp]) {
			[results appendString:temp];
		}
		if ([scanner scanString:@"&" intoString:NULL]) {
			BOOL valid = TRUE;
			unsigned c = 0;
			NSUInteger savedLocation = [scanner scanLocation];
			if ([scanner scanString:@"#" intoString:NULL]) {
				// it's a numeric entity
				if ([scanner scanString:@"x" intoString:NULL]) {
					// hexadecimal
					unsigned int value;
					if ([scanner scanHexInt:&value]) {
						c = value;
					} else {
						valid = FALSE;
					}
				} else {
					// decimal
					int value;
					if ([scanner scanInt:&value] && value >= 0) {
						c = value;
					} else {
						valid = FALSE;
					}
				}
				if (![scanner scanString:@";" intoString:NULL]) {
					// not ;-terminated, bail out and emit the whole entity
					valid = FALSE;
				}
			} else {
				if (![scanner scanUpToString:@";" intoString:&temp]) {
					// &; is not a valid entity
					valid = FALSE;
				} else if (![scanner scanString:@";" intoString:NULL]) {
					// there was no trailing ;
					valid = FALSE;
				} else if ([temp isEqualToString:@"amp"]) {
					c = '&';
				} else if ([temp isEqualToString:@"quot"]) {
					c = '"';
				} else if ([temp isEqualToString:@"lt"]) {
					c = '<';
				} else if ([temp isEqualToString:@"gt"]) {
					c = '>';
				} else {
					// unknown entity
					valid = FALSE;
				}
			}
			if (!valid) {
				// we errored, just emit the whole thing raw
				[results appendString:[input substringWithRange:NSMakeRange(savedLocation, [scanner scanLocation]-savedLocation)]];
			} else {
				[results appendFormat:@"%u", c];
			}
		}
	}
	
	return results;
}

- (NSArray *)extractPhoneNumbers
{
	NSString *originalString = [NSString stringWithString:self];
	NSScanner *scanner = [NSScanner scannerWithString:originalString];
	
	NSMutableArray *numberArray = [[[NSMutableArray alloc] init] autorelease];
	
	// Intermediate
	while (![scanner isAtEnd]) {
		NSString *numberString = nil;
		NSString *strippedString = @"";
		NSString *phoneNumber = @"";
		
		NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
		NSCharacterSet *letters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
		
		// Throw away characters before the first number.
		[scanner scanUpToCharactersFromSet:numbers intoString:NULL];
		
		// Collect numbers.
		[scanner scanUpToCharactersFromSet:letters intoString:&numberString];
		if (numberString != nil) {
			for (int i=0; i<[numberString length]; i++) {
				if (isdigit([numberString characterAtIndex:i])) {
					strippedString = [strippedString stringByAppendingFormat:@"%c",[numberString characterAtIndex:i]];
				}
			}
			
			int length = [strippedString length];
			for (int i=0; i<length; i++) {
				if (isdigit([strippedString characterAtIndex:i])) {
					NSString *hyphen = ((length == 11 && (i == 1 || i == 4 || i == 7)) ||
										(length == 10 && (i == 3 || i == 6)) ||
										(length == 7 && i == 3)) ? @"-" : @"";
					phoneNumber = [phoneNumber stringByAppendingFormat:@"%@%c",hyphen,[strippedString characterAtIndex:i]];
				}
			}			
			[numberArray addObject:phoneNumber];
		}
	}
	
	// Result.
	return [NSArray arrayWithArray:numberArray];
}

@end
