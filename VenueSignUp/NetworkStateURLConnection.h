//
//	NetworkStateURLConnection.h
//  TheBroCode
//
//  Created by Hector Matos on 10/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol NetworkStateURLConnectionDelegate

@optional
- (void)connectionDidFailWithError:(NSError *)error;
- (void)connectionDidReceiveResponse:(NSURLResponse *)response;
- (void)connectionDidReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading;

@end


@interface NetworkStateURLConnection : NSObject
{
	
	NSURLConnection *_connection;
	
	id<NetworkStateURLConnectionDelegate> _delegate;
	
}

@property(nonatomic, assign) id<NetworkStateURLConnectionDelegate> delegate;

+ (void)resetCookies;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
