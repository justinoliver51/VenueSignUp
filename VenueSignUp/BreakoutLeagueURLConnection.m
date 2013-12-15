//
//  BreakoutLeagueURLConnection.m
//  BreakoutLeague
//
//  Created by Hector on 9/13/13.
//  Copyright (c) 2013 CodeGenius. All rights reserved.

#import "BreakoutLeagueURLConnection.h"

#define charactersToBeEscaped @"&%<>#/.+"

@interface BreakoutLeagueURLConnection () <NSURLConnectionDataDelegate>
{
	NSString *baseRequestURL;
	NSString *finalRequestURL;
}

@end

@implementation BreakoutLeagueURLConnection

- (id)init
{
    self = [super init];
    if (self) 
	{
        _connecting = FALSE;
        _delegate = nil;
	}
	return self;
}

#pragma mark - Dynamic properties

- (void)setDelegate:(id)delegate
{
    if (_delegate == delegate) {
        return;
    }
    if (!delegate) {
        [self abortConnection];
    }
    _delegate = delegate;
}

#pragma mark - Instance methods

- (void)abortConnection
{
    if (!self.connecting) {
        return;
    }
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];

	[requestURLConnection cancel];
	requestURLConnection = nil;
	responseData = nil;
	_connecting = FALSE;
}

- (void)performRequestWithParameters:(NSDictionary *)parameters url:(NSString *)url;
{
	// if nil parameters send error
	NSString *postBody = @"";
	
	if (parameters) {
		int dictionaryCount = -1;
		for (id key in parameters) {
			dictionaryCount++;
			postBody = [postBody stringByAppendingString:[NSString stringWithFormat:@"%@=", key]];
			NSString *paramVal = [self URLEncode:[NSString stringWithFormat:@"%@", [parameters objectForKey:key]]];
			
			if (dictionaryCount != parameters.count) {
				postBody = [postBody stringByAppendingString:[NSString stringWithFormat:@"%@&", paramVal]];
			}
		}
		finalRequestURL = [url stringByAppendingString:[NSString stringWithFormat:@"?%@", postBody]];
	} else {
		finalRequestURL = url;
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalRequestURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:240];
	
	if (self.connecting) {
		[self abortConnection];
	}

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
	requestURLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];
	_connecting = TRUE;

	NSHTTPCookieStorage *cookieStore = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookiesArray = [cookieStore cookies];
	NSDictionary *cookieHeaderDict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookiesArray];
	[request setAllHTTPHeaderFields:cookieHeaderDict];
	
	if (requestURLConnection) {
		responseData = [[NSMutableData alloc] init];
	}
}

- (NSString *)URLEncode:(NSString *)stringToEncode
{
	NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)stringToEncode, NULL, ((CFStringRef) __builtin___CFStringMakeConstantString(":./=,!$&'()*+;[]@#?")), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
	return encodedString;
}

- (void)connectionDidReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	
    if ([httpResponse statusCode] >= 400) {
        // do error handling here
        NSLog(@"Remote URL returned error %d %@",[httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
    } else {
        NSLog(@"Remote URL returned %d %@",[httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (responseData.length > 0) {
		if ([responseData isEqualToData:data]) {
			return;
		}
	}
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	_connecting = FALSE;
	if (self.delegate != nil) {
		NSError *JSONParsingError;
		id JSONParsingResult = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&JSONParsingError];
		UIImage *image = [UIImage imageWithData:responseData];

		if (self.delegate != nil && JSONParsingResult && [JSONParsingResult isKindOfClass:[NSDictionary class]] && [self.delegate respondsToSelector:@selector(BreakoutLeagueURLConnectionDidFinishLoading:withDictionary:)]) {
			[self.delegate BreakoutLeagueURLConnectionDidFinishLoading:self withDictionary:JSONParsingResult];
		} else if (!JSONParsingResult && image && [self.delegate respondsToSelector:@selector(BreakoutLeagueURLConnectionDidFinishLoading:withImage:)]) {
			[self.delegate BreakoutLeagueURLConnectionDidFinishLoading:self withImage:image];
		} else if (JSONParsingError && [self.delegate respondsToSelector:@selector(BreakoutLeagueURLConnectionDidFail:withError:withURL:andErrorMessage:)]) {
			NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			[self.delegate BreakoutLeagueURLConnectionDidFail:self withError:JSONParsingError withURL:finalRequestURL andErrorMessage:dataString];
		}
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];

	if (self.delegate) {
		[self.delegate BreakoutLeagueURLConnectionDidFail:self withError:error withURL:finalRequestURL andErrorMessage:[error localizedDescription]];
	}
}

#pragma mark - Cleanup

- (void)dealloc
{
    [self abortConnection];
}

@end
