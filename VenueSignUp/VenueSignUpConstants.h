//
//  VenueSignUpConstants.h
//  VenueSignUp
//
//  Created by Justin Oliver on 12/15/13.
//  Copyright (c) 2013 SceneCheck. All rights reserved.
//

#ifndef VenueSignUp_VenueSignUpConstants_h
#define VenueSignUp_VenueSignUpConstants_h

// DEBUG FLAG
#define DEBUG_VENUESIGNUP 0

// Integer values
#define IPHONE5_DISPLAY_HEIGHT 568

// Strings
#define FRIENDSFEED_NEW_ENTRY @"Tap here to make a scene in the FriendsFeed!" // same macro in FeedModel.h, FeedCell.h
#define LIVEFEED_NEW_ENTRY @"Tap to make a scene in the Live Feed!" // same macro in FeedModel.h, FeedCell.h
#define SCENECHECK_EMAIL @"info@scenecheckapp.com"

// iOS Version
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

// Network Connection
#if DEBUG_VENUESIGNUP

//#define baseURL "http://localhost:8080/SceneCheckServer/RemoteProcedureCall?function="
//#define baseURLSecure "http://localhost:8080/SceneCheckServer/RemoteProcedureCall?function="

#define baseURL "http://41d6d274.ngrok.com/SceneCheckServer/RemoteProcedureCall?function="
#define baseURLSecure "https://41d6d274.ngrok.com/SceneCheckServer/RemoteProcedureCall?function="

#else

#define baseURL "http://scenecheckserver.scenecheckapp.com/RemoteProcedureCall?function="
#define baseURLSecure "https://scenecheckserver.scenecheckapp.com/RemoteProcedureCall?function="

#endif

// YELP
#define YELP_URL_BASE @"http://api.yelp.com/v2/search?"
#define YELP_CONSUMER_KEY @"7eyX4qVQRykGDUOGWuJvFw"
#define YELP_CONSUMER_SECRET @"NJ1ZSu78GHZhjbDJmn_u8zgMnBY"
#define YELP_TOKEN @"PauQPeVIDAO7dbPtRAPRRe6t7LMcmf_M"
#define YELP_TOKEN_SECRET @"_QCoypf2KoqndlgA7VWjeGDbYbI"

// Unordered
#define DIM_SETTING_NAV_BAR 0.2f
#define DIM_SETTING_DIM_BUTTON 0.8f
#define TABLE_VIEW_HEADER_LIVEFEED_HEIGHT 115
#define TABLE_VIEW_HEADER_FRIENDSFEED_HEIGHT 115
#define TABLE_VIEW_HEADER_TOPSPOTS_HEIGHT 82
#define TABLE_VIEW_HEADER_POINTS_HEIGHT 21
#define SCENECHECK_URL @"http://scenecheckserver.scenecheckapp.com"
#define SCENECHECK_NAME @"SceneCheck"
#define POINTS_POSTED_SCENE 20
#define POINTS_CHECK_IN 10
#define POINTS_BONUS_POSTED_SCENE 40
#define POINTS_BONUS_CHECK_IN 20
#define IPHONE5_DISPLAY_HEIGHT 568
#define ZERO @"0"
#define MAX_CHECKINS_AND_LIKES 999999
#define LIVEFEED_EMPTY @"There have been no promotions in your selected scenes..."
#define FRIENDSFEED_EMPTY @"None of your friends have posted to the Friends Feed..."
#define NO_SCENEMAP_SCENES_CHOSEN @"There have been no scene selections in the SceneMap. Please press the slider button and open the SceneMap."
#define NO_FAVORITES_CHOSEN @"Please favorite a venue in the LiveFeed by tapping the heart button in your favorite venue's post!"
#define NO_CHECKINS @"You have not checked in to a venue"

// Fonts
#define MAINFONT @"Comfortaa-Light"
#define TEXTFONT @"Helvetica"

#endif
