//
//	NetworkStateURLConnection.m
//  TheBroCode
//
//  Created by Hector Matos on 10/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkStateURLConnection.h"

@implementation NetworkStateURLConnection

@synthesize delegate = _delegate;

static NSArray *_cookies;

+ (void)resetCookies
{
	_cookies = nil;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
	return [self initWithRequest:request delegate:delegate startImmediately:TRUE];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
	if ((self = [super init])) {
		self.delegate = delegate;
		NSMutableURLRequest *muteRequest = [NSMutableURLRequest requestWithURL:[request URL] cachePolicy:[request cachePolicy] timeoutInterval:[request timeoutInterval]];
		
		if (_cookies) {
			NSEnumerator *enumerator = [_cookies objectEnumerator];
			id cookie;
			
			while ((cookie = [enumerator nextObject])) {
				[muteRequest addValue:[(NSHTTPCookie *)cookie value] forHTTPHeaderField:@"Cookies"];
			}
		}
		
		_connection = [[NSURLConnection alloc] initWithRequest:muteRequest delegate:self startImmediately:TRUE];
	}
	
	return self;
}

// Delegate method called if an error occurred during the connection.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (self.delegate != nil)
		[self.delegate connectionDidFailWithError:error];
}

// Delegate method called when a response has been received from the server.  All of the headers
// will have been received but not the body data yet.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
	
	// Check the status code and respond appropriately.
	switch ([httpResponse statusCode]) {
		case 200: {
			// Got a response so extract any cookies.  The array will be empty if there are none.
			NSDictionary *theHeaders = [httpResponse allHeaderFields];
			NSArray *theCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:theHeaders forURL:[response URL]];
			
			// Save any cookies
			if ([theCookies count] > 0) {
				if (_cookies != nil) [_cookies release];
				_cookies = [[NSArray alloc] initWithArray:theCookies];
			}
			
			break;
		}
        case 403: {
            
            break;
        }
		default:
			break;
	}
	
	if (self.delegate != nil) {
		[self.delegate connectionDidReceiveResponse:response];
	}
}

// Delegate method called when body data has been received.  This will be called one or more times.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (self.delegate != nil) {
		[self.delegate connectionDidReceiveData:data];
	}
}

// Delegate method called when the entire transaction has completed.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	@try {
		if (self.delegate != nil) {
			[self.delegate connectionDidFinishLoading];
		}
		
		[_connection release];
	}
	@catch (id exception) {
		
	}
}

@end