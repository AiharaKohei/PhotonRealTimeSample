/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "Photon-objc/inc/EGPhotonPeer.h"
#import "LoadBalancing-objc/inc/EGAuthenticationValues.h"
#import "LoadBalancing-objc/inc/EGLobbyStatsRequest.h"

@interface EGLoadBalancingPeer : EGPhotonPeer
{
}

- (bool) opJoinLobby;
- (bool) opJoinLobby:(NSString*)lobbyName;
- (bool) opJoinLobby:(NSString*)lobbyName :(nByte)lobbyType;
- (bool) opLeaveLobby;
- (bool) opCreateRoom:(NSString*)gameID;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(NSDictionary*)customLocalPlayerProperties;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(NSDictionary*)customLocalPlayerProperties :(EGArray*)propsListedInLobby;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(NSDictionary*)customLocalPlayerProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(NSDictionary*)customLocalPlayerProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(NSDictionary*)customLocalPlayerProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType :(int)playerTtl;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(NSDictionary*)customLocalPlayerProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType :(int)playerTtl :(int)emptyRoomTtl;
- (bool) opJoinRoom:(NSString*)gameID;
- (bool) opJoinRoom:(NSString*)gameID :(NSDictionary*)customLocalPlayerProperties;
- (bool) opJoinRoom:(NSString*)gameID :(NSDictionary*)customLocalPlayerProperties :(bool)createIfNotExists;
- (bool) opJoinRoom:(NSString*)gameID :(NSDictionary*)customLocalPlayerProperties :(bool)createIfNotExists :(int)playerNumber;
- (bool) opJoinRoom:(NSString*)gameID :(NSDictionary*)customLocalPlayerProperties :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex;
- (bool) opJoinRoom:(NSString*)gameID :(NSDictionary*)customLocalPlayerProperties :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex :(int)playerTtl;
- (bool) opJoinRoom:(NSString*)gameID :(NSDictionary*)customLocalPlayerProperties :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex :(int)playerTtl :(int)emptyRoomTtl;
- (bool) opJoinRandomRoom;
- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties;
- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers; // = MatchmakingMode::FILL_ROOM;
- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers :(nByte)matchmakingMode;
- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers :(nByte)matchmakingMode :(NSString*)lobbyName; // = LobbyType::DEFAULT
- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers :(nByte)matchmakingMode :(NSString*)lobbyName :(nByte)lobbyType;
- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers :(nByte)matchmakingMode :(NSString*)lobbyName :(nByte)lobbyType :(NSString*)sqlLobbyFilter;
- (bool) opLeaveRoom; // = false
- (bool) opLeaveRoom:(bool)willComeBack;
- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode; // = 0
- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID; // = EventCache::DO_NOT_CACHE
- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching; // = NULL, = 0
- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers; // = ReceiverGroup::OTHERS
- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers :(nByte)receiverGroup;
- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers :(nByte)receiverGroup :(nByte)interestGroup;
- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers :(nByte)receiverGroup :(nByte)interestGroup :(bool)forwardToWebhook;
- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers :(nByte)receiverGroup :(nByte)interestGroup :(bool)forwardToWebhook :(int)cacheSliceIndex;
- (bool) opAuthenticate:(NSString*)appID :(NSString*)appVersion :(bool)encrypted;
- (bool) opAuthenticate:(NSString*)appID :(NSString*)appVersion :(bool)encrypted :(NSString*)userID;
- (bool) opAuthenticate:(NSString*)appID :(NSString*)appVersion :(bool)encrypted :(NSString*)userID :(EGAuthenticationValues*)authenticationValues;
- (bool) opAuthenticate:(NSString*)appID :(NSString*)appVersion :(bool)encrypted :(NSString*)userID :(EGAuthenticationValues*)authenticationValues :(bool)lobbyStats;
- (bool) opAuthenticate:(NSString*)appID :(NSString*)appVersion :(bool)encrypted :(NSString*)userID :(EGAuthenticationValues*)authenticationValues :(bool)lobbyStats :(NSString*)regionCode;
- (bool) opFindFriends:(NSString**)friendsToFind :(short)numFriendsToFind;
- (bool) opLobbyStats; // = nil
- (bool) opLobbyStats:(EGArray*)lobbiesToQuery; // array of EGLobbyStatsRequest
- (bool) opChangeGroups:(EGArray*)groupsToRemove :(EGArray*)groupsToAdd; // arrays of nByte
- (bool) opWebRpc:(NSString*)uriPath :(const NSObject*)parameters;
- (bool) opGetRegions:(bool)encrypted :(NSString*)appID;
- (bool) opSetPropertiesOfPlayer:(int)playerNr :(NSDictionary*)properties;
- (bool) opSetPropertiesOfRoom:(NSDictionary*)properties; // = false
- (bool) opSetPropertiesOfRoom:(NSDictionary*)properties :(bool)webForward;

@end