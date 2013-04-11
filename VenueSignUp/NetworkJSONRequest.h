//
//	NetworkJSONRequest.h
//  TheBroCode
//
//  Created by Hector Matos on 10/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkStateURLConnection.h"

@class NetworkJSONRequest;

@protocol NetworkJSONRequestDelegate <NSObject>

@property (nonatomic, assign) NetworkJSONRequest *request;

@required
- (void)requestDidFailWithError:(NSError *)error;

@optional
- (void)requestDidFinishLoading:(id)result;
- (void)requestDidFinishLoadingWithDictionary:(NSDictionary *)result;
- (void)requestDidFinishLoadingWithArray:(NSArray *)result;
- (void)requestDidReceiveResponse:(NSURLResponse *)response;

@end


@interface NetworkJSONRequest : NSObject <NetworkStateURLConnectionDelegate>
{
	
	id<NetworkJSONRequestDelegate> _delegate;
	NetworkStateURLConnection *connection;
	NSMutableData *responseData;
	
}

@property (atomic, assign) id<NetworkJSONRequestDelegate> delegate;
@property (atomic) int index;

- (id)initWithPath:(NSString *)path variables:(NSString *)variables delegate:(id)delegate andSecure:(BOOL)isSecure;
+ (NetworkJSONRequest *)makeRequestWithPath:(NSString *)path variables:(NSString *)variables delegate:(id)delegate andSecure:(BOOL)isSecure;

@end
