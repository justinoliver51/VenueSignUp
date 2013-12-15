//
//  BreakoutLeagueURLConnection.h
//  BreakoutLeague
//
//  Created by Hector on 9/13/13.
//  Copyright (c) 2013 CodeGenius. All rights reserved.

#import <Foundation/Foundation.h>

@class BreakoutLeagueURLConnection;

@protocol BreakoutLeagueURLConnectDelegate<NSObject>

@required
- (void)BreakoutLeagueURLConnectionDidFail:(BreakoutLeagueURLConnection *)URLConnection withError:(NSError *)error withURL:(NSString *)URL andErrorMessage:(NSString *)errorMessage;

@optional
- (void)BreakoutLeagueURLConnectionDidFinishLoading:(BreakoutLeagueURLConnection *)URLConnection withImage:(UIImage *)image;
- (void)BreakoutLeagueURLConnectionDidFinishLoading:(BreakoutLeagueURLConnection *)URLConnection withDictionary:(NSDictionary *)dictionary;

@end

@interface BreakoutLeagueURLConnection : NSObject
{
	NSURLConnection *requestURLConnection;
	NSMutableData *responseData;
}

@property (nonatomic, strong) id <BreakoutLeagueURLConnectDelegate> delegate;
@property (nonatomic) NSUInteger index;
@property (nonatomic, getter=isConnecting) BOOL connecting;

- (void)performRequestWithParameters:(NSDictionary *)parameters url:(NSString *)url;
- (void)abortConnection;

@end

