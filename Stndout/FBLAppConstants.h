//
//  FBLAppConstants.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#ifndef Stndout_FBLAppConstants_h
#define Stndout_FBLAppConstants_h

//--------------------- APP HELPERS ----------------------------
#define     BLANK_AVATAR_IMG @"Persona"
#define     FBL_DEFAULT_EMAIL @"help@feedbackloop.com"
#define     FBL_DEFAULT_TITLE @"bot"

//--------------------- PARSE HELPERS ----------------------------
#define		PF_STUB_USER_ID                     @"0000000000001"
#define		PF_STUB_USER_FULLNAME               @"Shane Rogers"
#define		PF_INSTALLATION_CLASS_NAME			@"Installation"         //	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class
#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"

//----------------------- CUSTOMERS ----------------------------
#define		PF_CUSTOMER_CLASS_NAME				@"Customer"             //	Class name
#define		PF_CUSTOMER_OBJECTID				@"objectId"				//	String
#define		PF_CUSTOMER_USERNAME				@"username"				//	String
#define		PF_CUSTOMER_PASSWORD				@"password"				//	String
#define		PF_CUSTOMER_EMAIL					@"email"				//	String
#define		PF_CUSTOMER_EMAILCOPY				@"emailCopy"			//	String
#define		PF_CUSTOMER_FULLNAME				@"fullname"				//	String
#define		PF_CUSTOMER_FULLNAME_LOWER			@"fullname_lower"		//	String
#define		PF_CUSTOMER_FACEBOOKID				@"facebookId"			//	String
#define		PF_CUSTOMER_PICTURE					@"picture"				//	File
#define		PF_CUSTOMER_THUMBNAIL				@"thumbnail"			//	File

//----------------------- MEMBERS ----------------------------
#define		PF_MEMBER_CLASS_NAME				@"Member"				//	Class name
#define		PF_MEMBER_OBJECTID					@"objectId"				//	String
#define		PF_MEMBER_REALNAME					@"realname"				//	String
#define		PF_MEMBER_EMAIL						@"email"				//	String
#define		PF_MEMBER_TITLE						@"title"				//	String
#define		PF_MEMBER_SLACKNAME					@"slackname"			//	String
#define		PF_MEMBER_SLACKID					@"slackId"			    //	String
#define		PF_MEMBER_IMAGE_URL					@"imageUrl"				//	String
#define		PF_MEMBER_PICTURE					@"picture"				//	File
#define		PF_MEMBER_THUMBNAIL                 @"thumbnail"			//	File


////---------------------- MESSAGES ----------------------------
//#define		PF_MESSAGE_CLASS_NAME				@"Message"				//	Class name
//#define		PF_MESSAGE_USER						@"user"					//	Pointer to User Class
//#define		PF_MESSAGE_GROUPID					@"groupId"				//	String
//#define		PF_MESSAGE_TEXT						@"text"					//	String
//#define		PF_MESSAGE_PICTURE					@"picture"				//	File
//#define		PF_MESSAGE_VIDEO					@"video"				//	File
//#define		PF_MESSAGE_CREATEDAT				@"createdAt"			//	Date

//----------------------- CHANNELS ---------------------------
#define		PF_CHANNEL_CLASS_NAME                  @"Channel"                 //	Class name
#define		PF_CHANNEL_CUSTOMER                    @"customer"					//	Pointer to Customer Class
#define		PF_CHANNEL_OBJECTID					@"objectId"				//	String
#define		PF_CHANNEL_SLACKID					@"slackId"				//	String

//--------------------- SLACK ------------------------------
#define     SLACK_API_KEY @"xoxp-4363020674-4363020680-4429695137-cdb875"
#define     SLACK_API_BASE_URL @"https://slack.com/api"

//----------------- SLACK ENDPOINTS ------------------------------
//------- RTM
#define     SLACK_API_RTM_START @"/rtm.start"
//------- Channel
#define     SLACK_API_CHANNEL_CREATE @"/channels.create"
//PARAMS    "?token=#{token}&name=#{channelName}
#define     SLACK_API_CHANNEL_JOIN @"/channels.join"
//PARAMS    "?token=#{token}&name=#{channelName}
#define     SLACK_API_CHANNEL_HISTORY @"/channels.history"
//------- Message
#define     SLACK_API_MESSAGE_POST @"/chat.postMessage"
//PARAMS    "?token=#{token}  &  channel=#{channelName}"?token="
//------- Members
#define     SLACK_MEMBERS_URI @"/users.list"

#endif