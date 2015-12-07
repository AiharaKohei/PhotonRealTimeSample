/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "LoadBalancing-objc/inc/EGFriendInfo.h"
#import "LoadBalancing-objc/inc/EGLoadBalancingListener.h"
#import "LoadBalancing-objc/inc/EGLoadBalancingPeer.h"
#import "LoadBalancing-objc/inc/EGLoadBalancingRoom.h"
#import "LoadBalancing-objc/inc/EGLobbyStatsResponse.h"

@interface EGLoadBalancingClient : NSObject <EGPhotonListener>

@property (readonly) int ServerTimeOffset;
@property (readonly) int ServerTime;
@property (readonly) int BytesOut;
@property (readonly) int BytesIn;
@property (readonly) int ByteCountCurrentDispatch;
@property (readonly) int ByteCountLastOperation;
@property (readwrite) int SentCountAllowance;
@property (readwrite) int TimePingInterval;
@property (readonly) int RoundTripTime;
@property (readonly) int RoundTripTimeVariance;
@property (readonly) int TimestampOfLastSocketReceive;
@property (readwrite) int DebugOutputLevel;
@property (readonly) int IncomingReliableCommandsCount;
@property (readonly) short PeerID;
@property (readwrite) int DisconnectTimeout;
@property (readonly) int QueuedIncomingCommands;
@property (readonly) int QueuedOutgoingCommands;
@property (readonly) bool IsEncryptionAvailable;
@property (readonly) int ResentReliableCommands;
@property (readwrite) int LimitOfUnreliableCommands;
@property (readwrite) bool CrcEnabled;
@property (readonly) int PacketLossByCrc;
@property (readwrite) bool TrafficStatsEnabled;
@property (readonly) int TrafficStatsElapsedMs;
@property (readonly) EGTrafficStats* TrafficStatsIncoming;
@property (readonly) EGTrafficStats* TrafficStatsOutgoing;
@property (readonly) EGTrafficStatsGameLevel* TrafficStatsGameLevel;
@property (readwrite) nByte QuickResendAttempts;
@property (readonly) short PeerCount;
@property (readonly) int State;
@property (readonly) NSString* MasterserverAddress;
@property (readonly) int CountPlayersIngame;
@property (readonly) int CountGamesRunning;
@property (readonly) int CountPlayersOnline;
@property (readonly) EGLoadBalancingMutableRoom* CurrentlyJoinedRoom;
@property (readonly) NSDictionary* RoomList;
@property (readonly) bool IsInRoom;
@property (readonly) bool IsInGameRoom;
@property (readonly) bool IsInLobby;
@property (readwrite) bool AutoJoinLobby;
@property (readonly) EGLoadBalancingMutablePlayer* LocalPlayer;
@property (readonly) EGArray* FriendList;
@property (readonly) int FriendListAge;
@property (readonly) int DisconnectedCause;

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username;
- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol;
- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol :(EGAuthenticationValues*)authenticationValues;
- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol :(EGAuthenticationValues*)authenticationValues :(bool)autoLobbyStats;
- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol :(EGAuthenticationValues*)authenticationValues :(bool)autoLobbyStats :(bool)useDefaultRegion NS_DESIGNATED_INITIALIZER;
+ (instancetype) new NS_UNAVAILABLE;

- (bool) connect; // = NAMESERVER
- (bool) connect:(NSString*)serverAddress; // = ServerType::NAME_SERVER
- (bool) connect:(NSString* const)serverAddress :(nByte)serverType;
- (void) disconnect;
- (void) service; // = true
- (void) service:(bool)dispatchIncomingCommands;
- (void) serviceBasic;
- (bool) sendOutgoingCommands;
- (bool) sendAcksOnly;
- (bool) dispatchIncomingCommands;
- (void) fetchServerTimestamp;
- (void) resetTrafficStats;
- (void) resetTrafficStatsMaximumCounters;
- (NSString*) vitalStatsToString:(bool)all;

- (bool) opJoinLobby;
- (bool) opJoinLobby:(NSString*)lobbyName;
- (bool) opJoinLobby:(NSString*)lobbyName :(nByte)lobbyType;
- (bool) opLeaveLobby;
- (bool) opCreateRoom:(NSString*)gameID;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType :(int)playerTtl;
- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType :(int)playerTtl :(int)emptyRoomTtl;
- (bool) opJoinRoom:(NSString*)gameID;
- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists;
- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists :(int)playerNumber;
- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex;
- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex :(int)playerTtl;
- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex :(int)playerTtl :(int)emptyRoomTtl;
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
- (bool) opFindFriends:(NSString**)friendsToFind :(short)numFriendsToFind;
- (bool) opLobbyStats; // = nil
- (bool) opLobbyStats:(EGArray*)lobbiesToQuery; // array of EGLobbyStatsRequest
- (bool) opChangeGroups:(EGArray*)groupsToRemove :(EGArray*)groupsToAdd; // arrays of nByte
- (bool) opCustomAuthenticationSendNextStepData:(EGAuthenticationValues*)authenticationValues;
- (bool) opWebRpc:(NSString*)uriPath :(const NSObject*)parameters;
- (bool) selectRegion:(NSString*)selectedRegion;

@end