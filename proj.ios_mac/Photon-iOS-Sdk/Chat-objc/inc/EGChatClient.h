/* Exit Games Photon Chat - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "Photon-objc/inc/EGPhotonListener.h"
#import "Chat-objc/inc/EGAuthenticationValues.h"
#import "Chat-objc/inc/EGChatChannel.h"
#import "Chat-objc/inc/EGChatListener.h"
#import "Chat-objc/inc/EGChatPeer.h"

@interface EGChatClient : NSObject  <EGPhotonListener>

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

@property (readwrite, copy) NSString* UserId;
@property (readonly) int State;
@property (readonly) int DisconnectedCause;
@property (readwrite, copy) NSString* Region;
@property (readonly) EGArray* PublicChannels;
@property (readonly) EGArray* PrivateChannels;

- (instancetype) initClient:(id<EGChatListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username;
- (instancetype) initClient:(id<EGChatListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol;
- (instancetype) initClient:(id<EGChatListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol :(EGAuthenticationValues*)authenticationValues NS_DESIGNATED_INITIALIZER;

- (bool) connect; // = NAMESERVER
- (bool) connect:(NSString*)serverAddress;
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

- (EGChatChannel*) getPublicChannel:(NSString*)channelName;
- (EGChatChannel*) getPrivateChannel:(NSString*)userName;

- (bool) opSubscribe:(EGArray*)channels; // = 0
- (bool) opSubscribe:(EGArray*)channels :(int)messagesFromHistory;
- (bool) opUnsubscribe:(EGArray*)channels;
- (bool) opPublishMessage:(NSString*)channelName :(id<NSObject>)message;
- (bool) opSendPrivateMessage:(NSString*)target :(id<NSObject>)message; // = false
- (bool) opSendPrivateMessage:(NSString*)target :(id<NSObject>)message :(bool)encrypt;
- (bool) opSetOnlineStatus:(int)status; // nil
- (bool) opSetOnlineStatus:(int)status :(id<NSObject>)message; // = false
- (bool) opSetOnlineStatus:(int)status :(id<NSObject>)message :(bool)skipMessage;
- (bool) opAddFriends:(EGArray*)userIds;
- (bool) opRemoveFriends:(EGArray*)userIds;

@end