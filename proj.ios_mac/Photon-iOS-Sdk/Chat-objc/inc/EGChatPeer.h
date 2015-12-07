/* Exit Games Photon Chat - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "Photon-objc/inc/EGPhotonPeer.h"
#import "Chat-objc/inc/EGAuthenticationValues.h"
#import "Common-objc/inc/EGArray.h"

@interface EGChatPeer : EGPhotonPeer

- (bool) opAuthenticateOnNameServer:(NSString*)appID :(NSString*)appVersion :(NSString*)region :(NSString*)userID :(const EGAuthenticationValues*)authenticationValues;
- (bool) opAuthenticateOnFrontEnd:(NSString*)secret;
- (bool) opSubscribe:(EGArray*)channels;
- (bool) opSubscribe:(EGArray*)channels :(int)messagesFromHistory;
- (bool) opUnsubscribe:(EGArray*)channels;
- (bool) opPublishMessage:(NSString*)channelName :(id<NSObject>)message;
- (bool) opSendPrivateMessage:(NSString*)target :(id<NSObject>)message;
- (bool) opSendPrivateMessage:(NSString*)target :(id<NSObject>)message :(bool)encrypt;
- (bool) opSetOnlineStatus:(int)status :(id<NSObject>)message :(bool)skipMessage;
- (bool) opAddFriends:(EGArray*)userIds;
- (bool) opRemoveFriends:(EGArray*)userIds;

@end