//
//  FBLAppConstants.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#ifndef Stndout_FBLAppConstants_h
#define Stndout_FBLAppConstants_h

#define		PF_STUB_USER_ID                     @"0000000000001"
#define		PF_STUB_USER_FULLNAME               @"Shane Rogers"
#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"		//	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class

//----------------------- CUSTOMERS ----------------------------
#define		PF_USER_CLASS_NAME					@"_User"				//	Class name
#define		PF_USER_OBJECTID					@"objectId"				//	String
#define		PF_USER_USERNAME					@"username"				//	String
#define		PF_USER_PASSWORD					@"password"				//	String
#define		PF_USER_EMAIL						@"email"				//	String
#define		PF_USER_EMAILCOPY					@"emailCopy"			//	String
#define		PF_USER_FULLNAME					@"fullname"				//	String
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"		//	String
#define		PF_USER_FACEBOOKID					@"facebookId"			//	String
#define		PF_USER_PICTURE						@"picture"				//	File
#define		PF_USER_THUMBNAIL					@"thumbnail"			//	File
//----------------------- MEMBERS ----------------------------
#define		PF_MEMBER_CLASS_NAME				@"_Member"				//	Class name
#define		PF_MEMBER_OBJECTID					@"objectId"				//	String
#define		PF_MEMBER_REALNAME					@"realname"				//	String
#define		PF_MEMBER_EMAIL						@"email"				//	String
#define		PF_MEMBER_TITLE						@"title"				//	String
#define		PF_MEMBER_SLACKNAME					@"slackname"			//	String
#define		PF_MEMBER_SLACKID					@"slackId"			    //	String
#define		PF_MEMBER_PICTURE					@"picture"				//	String
//------------------------------------------------------------
#define		PF_MESSAGE_CLASS_NAME				@"Message"				//	Class name
#define		PF_MESSAGE_USER						@"user"					//	Pointer to User Class
#define		PF_MESSAGE_GROUPID					@"groupId"				//	String
#define		PF_MESSAGE_TEXT						@"text"					//	String
#define		PF_MESSAGE_PICTURE					@"picture"				//	File
#define		PF_MESSAGE_VIDEO					@"video"				//	File
#define		PF_MESSAGE_CREATEDAT				@"createdAt"			//	Date
//-----------------------------------------------------------------------
#define		PF_GROUPS_CLASS_NAME				@"Groups"				//	Class name
#define		PF_GROUPS_NAME						@"name"					//	String
//-----------------------------------------------------------------------
#define		PF_CHAT_CLASS_NAME                  @"Chat"                 //	Class name
#define		PF_CHAT_USER                        @"user"					//	Pointer to User Class
#define		PF_CHAT_GROUPID                     @"groupId"				//	String
#define		PF_CHAT_DESCRIPTION                 @"description"			//	String
#define		PF_CHAT_LASTUSER                    @"lastUser"				//	Pointer to User Class
#define		PF_CHAT_LASTMESSAGE                 @"lastMessage"			//	String
#define		PF_CHAT_COUNTER					    @"counter"				//	Number
#define		PF_CHAT_UPDATEDACTION			    @"updatedAction"		//	Date

#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"

#define     BLANK_AVATAR_IMG @"Persona"

// Slack Base API Info
#define     SLACK_API_KEY @"xoxp-4363020674-4363020680-4429695137-cdb875"
#define     SLACK_API_BASE_URL @"https://slack.com/api"

// Slack Methods
#define     SLACK_MEMBERS_URI @"/users.list"

#endif