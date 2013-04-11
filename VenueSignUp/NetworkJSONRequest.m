//
//	NetworkJSONRequest.m
//  TheBroCode
//
//  Created by Hector Matos on 10/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkJSONRequest.h"
#import "BaseURL.h"

@implementation NetworkJSONRequest


static NSMutableArray *requests;

+ (NetworkJSONRequest *)requestAtIndex:(int)index
{
	return [requests objectAtIndex:index];
}

+ (void)removeRequestAtIndex:(int)index
{
	[requests removeObjectAtIndex:index];
	
	for (int i = index; i < [requests count]; i++) {
		[[requests objectAtIndex:i] setIndex:i];
	}
}

+ (NetworkJSONRequest *)makeRequestWithPath:(NSString *)path variables:(NSString *)variables delegate:(id)delegate andSecure:(BOOL)isSecure
{
	if (requests == nil) {
		requests = [[NSMutableArray alloc] init];
	}
	
	NetworkJSONRequest *request = [[NetworkJSONRequest alloc] initWithPath:path variables:variables delegate:delegate andSecure:isSecure];
	[request setIndex:[requests count]];
	[requests addObject:request];
	[request release];
	
	[delegate setRequest:[requests objectAtIndex:[requests count] - 1]];
	
	return [requests objectAtIndex:[requests count] - 1];
}


@synthesize delegate = _delegate;
@synthesize index = _index;

- (id)initWithPath:(NSString *)path variables:(NSString *)variables delegate:(id)delegate andSecure:(BOOL)isSecure
{
	if ((self = [super init])) {
		self.delegate = delegate;
		
		NSString *myURL;
		if ([path rangeOfString:@"http://"].location == NSNotFound && [path rangeOfString:@"https://"].location == NSNotFound) {
			if (isSecure) {
				myURL = [NSString stringWithFormat:@"%s%@", baseURLSecure, path];
			} else {
				myURL = [NSString stringWithFormat:@"%s%@", baseURL, path];
			}
		} else {
			myURL = path;
		}
		
		if (variables) {
			myURL = [NSString stringWithFormat:@"%@%@", myURL, variables];
		}
		
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:myURL]
												 cachePolicy:NSURLCacheStorageNotAllowed
											 timeoutInterval:30];
		
		connection = [[NetworkStateURLConnection alloc] initWithRequest:request delegate:self];
		
		if (connection) {
			responseData = [[NSMutableData data] retain];
		}
	}
	
	return self;
}

- (void)connectionDidReceiveResponse:(NSURLResponse *)response
{
    if([self.delegate respondsToSelector:@selector(requestDidReceiveResponse:)])
    {
        [self.delegate requestDidReceiveResponse:response];
    }
}

- (void)connectionDidReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connectionDidFailWithError:(NSError *)error
{
	if (self.delegate != nil) {
		[self.delegate setRequest:nil];
		[self.delegate requestDidFailWithError:error];
	}
	
	[NetworkJSONRequest removeRequestAtIndex:self.index];
}

- (void)connectionDidFinishLoading
{
	if (self.delegate != nil) {
		[self.delegate setRequest:nil];
		
		NSError *jsonParsingError = nil;
		id JSONParsingResult = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
		
		if (self.delegate != nil && [JSONParsingResult isKindOfClass:[NSDictionary class]] && [self.delegate respondsToSelector:@selector(requestDidFinishLoadingWithDictionary:)]) {
			//[self.delegate requestDidFinishLoadingWithDictionary:JSONParsingResult];
            
            // SceneCheck added this line
            [self performSelectorOnMainThread:@selector(requestDidFinishLoadingWithDictionaryOnMainThread:) withObject:JSONParsingResult waitUntilDone:YES];
		} else if (self.delegate != nil && [JSONParsingResult isKindOfClass:[NSArray class]] && [self.delegate respondsToSelector:@selector(requestDidFinishLoadingWithArray:)]) {
			[self.delegate requestDidFinishLoadingWithArray:JSONParsingResult];
		} else if (self.delegate != nil && [self.delegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
			[self.delegate requestDidFinishLoading:JSONParsingResult];
		} else if (self.delegate != nil) {
			[self.delegate requestDidFailWithError:jsonParsingError];
            // SceneCheck added this line
            [self performSelectorOnMainThread:@selector(requestDidFailWithErrorOnMainThread:) withObject:jsonParsingError waitUntilDone:YES];
            //[self.delegate requestDidFailWithError:jsonParsingError];
		}
	}
	
	[NetworkJSONRequest removeRequestAtIndex:self.index];
}

// SceneCheck added this function
- (void)requestDidFinishLoadingWithDictionaryOnMainThread:(NSDictionary *)result
{
    [self.delegate requestDidFinishLoadingWithDictionary:result];
}

// SceneCheck added this function
- (void)requestDidFailWithErrorOnMainThread:(NSError *)error
{
    [self.delegate requestDidFailWithError:error];
}


- (void)dealloc
{
	[responseData release];
	[connection setDelegate:nil];
	[connection release];
	[super dealloc];
}

@end
