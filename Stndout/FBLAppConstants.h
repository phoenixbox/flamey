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

//--------------------- SLACK ------------------------------
#define     SLACK_API_KEY @"xoxp-4363020674-4363020680-4429695137-cdb875"
#define     SLACK_API_BASE_URL @"https://slack.com/api"

#define     SLACK_GEN_TOKEN @"64a702c6-d868-480a-aff1-1ec6ab90e267"

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

//-------------------FEEDBACKLOOP ------------------------------
#define     PROD_API_BASE_URL @"http://www.getfeedbackloop.com/api";

#define     DEV_API_BASE_URL @"http://lvh.me:3000/api";
//127.0.0.1
//#define     DEV_API_BASE_URL @"http://192.168.0.109:3000/api";

//--------------FEEDBACKLOOP ENDPOINTS------------------------------

#define     FBL_TEAMS_URI @"/teams"

#endif