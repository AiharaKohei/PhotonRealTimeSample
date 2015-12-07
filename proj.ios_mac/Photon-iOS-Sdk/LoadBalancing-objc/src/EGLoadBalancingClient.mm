/* Exit Games Photon LoadBalancing - objC Client Lib
* Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
* http://www.exitgames.com
* mailto:developer@exitgames.com
*/
#import <Foundation/NSException.h>
#include "LoadBalancing-cpp/inc/Enums/ErrorCode.h"
#include "LoadBalancing-cpp/inc/Enums/LobbyType.h"
#include "LoadBalancing-cpp/inc/Enums/MatchmakingMode.h"
#include "LoadBalancing-cpp/inc/Enums/ServerType.h"
#include "LoadBalancing-cpp/inc/Enums/DisconnectCause.h"
#include "LoadBalancing-cpp/inc/Internal/Enums/EventCode.h"
#include "LoadBalancing-cpp/inc/Internal/Enums/JoinType.h"
#include "LoadBalancing-cpp/inc/Internal/Enums/OperationCode.h"
#include "LoadBalancing-cpp/inc/Internal/Enums/ParameterCode.h"
#include "LoadBalancing-cpp/inc/Internal/Enums/Properties/Room.h"
#include "LoadBalancing-cpp/inc/Enums/PeerStates.h"
#import "Photon-objc/inc/Protected/EGPhotonPeer+Protected.h"
#import "LoadBalancing-objc/inc/Internal/EGAuthenticationValues+Internal.h"
#import "LoadBalancing-objc/inc/Internal/EGLoadBalancingClient+Internal.h"
#import "LoadBalancing-objc/inc/Internal/EGLoadBalancingPeer+Internal.h"
#import "LoadBalancing-objc/inc/Internal/EGLoadBalancingPlayer+Internal.h"
#import "LoadBalancing-objc/inc/Internal/EGLoadBalancingRoom+Internal.h"
#import "LoadBalancing-objc/inc/Protected/EGLoadBalancingClient+Protected.h"
#import "LoadBalancing-objc/inc/Protected/EGLoadBalancingPlayer+Protected.h"
#import "LoadBalancing-objc/inc/Protected/EGLoadBalancingRoom+Protected.h"

/** @file EGLoadBalancingClient.h */

namespace ExitGames
{
	namespace LoadBalancing
	{
		// default name server address and port
		NSString* const NAMESERVER = @"ns.exitgamescloud.com:5058";
		
		const bool SEND_AUTHENTICATE_ENCRYPTED = true;
	}
}

using namespace ExitGames;
using namespace ExitGames::Photon;
using namespace ExitGames::Common::DebugLevel;
using namespace ExitGames::LoadBalancing;
using namespace ExitGames::LoadBalancing::Internal;

@interface EGLoadBalancingClient ()

@property (readonly) bool IsOnGameServer;
- (EGLoadBalancingMutablePlayer*) setLocalPlayer:(EGLoadBalancingMutablePlayer*)localPlayer;
- (EGLoadBalancingMutablePlayer*) setLocalPlayer:(int)number :(NSDictionary*)properties;
@property (readonly) EGLogger* Logger;
@property (readwrite) int State; // redeclare for private write access

- (void) readoutProperties:(NSMutableDictionary**)pRoomProperties :(NSMutableDictionary**)pPlayerProperties :(bool)multiplePlayers :(int)targetPlayerNr;
- (void) handleConnectionFlowError:(int)oldState :(int)errorCode :(NSString* const)errorString;
- (void) onConnectToMasterFinished:(bool)comingFromGameserver;

@end

@implementation EGLoadBalancingClient
{
@private
	EGLoadBalancingPeer* mPeer;
	id<EGLoadBalancingListener> mListener;
	EGLogger* mLogger;
	NSString* mGameserver;
	NSString* mAppVersion;
	NSString* mRoomName;
	NSString* mAppID;
	int mPeerCount;
	int mRoomCount;
	int mMasterPeerCount;
	nByte mLastJoinType;
	nByte mLastLobbyJoinType;
	bool mLastJoinCreateIfNotExists;
	int mLastJoinPlayerNumber;
	int mLastCacheSliceIndex;
	EGLoadBalancingMutableRoom* mCurrentlyJoinedRoom;
	NSMutableDictionary* mRoomList;
	int mCachedErrorCodeFromGameServer;
	NSString* mCachedErrorStringFromGameServer;
	nByte mConnectionProtocol;
	NSString* mNameserver;
	NSString* mMasterserver;
	bool mAutoJoinLobby;
	EGLoadBalancingMutablePlayer* mLocalPlayer;
	EGMutableArray* mFriendList;
	int mFriendListTimestamp;
	bool mIsFetchingFriendList;
	EGArray* mLobbyStatsList;
	int mState;
	EGAuthenticationValues* mAuthenticationValues;
	bool mAutoLobbyStats;
	int mDisconnectedCause;

	NSString* mSelectedRegion;
	bool mUseDefaultRegion;
}
// properties

- (int) ServerTimeOffset
{
	return mPeer.ServerTimeOffset;
}

- (int) ServerTime
{
	return mPeer.ServerTime;
}

- (int) BytesOut
{
	return mPeer.BytesOut;
}

- (int) BytesIn
{
	return mPeer.BytesIn;
}

- (int) ByteCountCurrentDispatch
{
	return mPeer.ByteCountCurrentDispatch;
}

- (int) ByteCountLastOperation
{
	return mPeer.ByteCountLastOperation;
}

- (int) SentCountAllowance
{
	return mPeer.SentCountAllowance;
}

- (void) setSentCountAllowance:(int)setSentCountAllowance
{
	mPeer.SentCountAllowance = setSentCountAllowance;
}

- (int) TimePingInterval
{
	return mPeer.TimePingInterval;
}

- (void) setTimePingInterval:(int)setTimePingInterval
{
	mPeer.TimePingInterval = setTimePingInterval;
}

- (int) RoundTripTime
{
	return mPeer.RoundTripTime;
}

- (int) RoundTripTimeVariance
{
	return mPeer.RoundTripTimeVariance;
}

- (int) TimestampOfLastSocketReceive
{
	return mPeer.TimestampOfLastSocketReceive;
}

- (int) DebugOutputLevel
{
	return mPeer.DebugOutputLevel;
}

- (void) setDebugOutputLevel:(int)debugOutputLevel
{
	mLogger.DebugOutputLevel = mPeer.DebugOutputLevel = debugOutputLevel;
}

- (short) PeerID
{
	return mPeer.PeerID;
}

- (bool) IsEncryptionAvailable
{
	return mPeer.IsEncryptionAvailable;
}

- (int) IncomingReliableCommandsCount
{
	return mPeer.IncomingReliableCommandsCount;
}

- (int) DisconnectTimeout
{
	return mPeer.DisconnectTimeout;
}

- (void) setDisconnectTimeout:(int)disconnectTimeout
{
	mPeer.DisconnectTimeout = disconnectTimeout;
}

- (int) QueuedIncomingCommands
{
	return mPeer.QueuedIncomingCommands;
}

- (int) QueuedOutgoingCommands
{
	return mPeer.QueuedOutgoingCommands;
}

- (NSString*) ServerAddress
{
	return mPeer.ServerAddress;
}

- (int) ResentReliableCommands
{
	return mPeer.ResentReliableCommands;
}

- (int) LimitOfUnreliableCommands
{
	return mPeer.LimitOfUnreliableCommands;
}

- (void) setLimitOfUnreliableCommands:(int)setLimitOfUnreliableCommands
{
	mPeer.LimitOfUnreliableCommands = setLimitOfUnreliableCommands;
}

- (bool) CrcEnabled
{
	return mPeer.CrcEnabled;
}

- (void) setCrcEnabled:(bool)crcEnabled
{
	mPeer.CrcEnabled = crcEnabled;
}

- (int) PacketLossByCrc
{
	return mPeer.PacketLossByCrc;
}

- (short) PeerCount
{
	return mPeer.PeerCount;
}

- (bool) TrafficStatsEnabled
{
	return mPeer.TrafficStatsEnabled;
}

- (void) setTrafficStatsEnabled:(bool)setTrafficStatsEnabled
{
	mPeer.TrafficStatsEnabled = setTrafficStatsEnabled;
}

- (int) TrafficStatsElapsedMs
{
	return mPeer.TrafficStatsElapsedMs;
}

- (EGTrafficStats*) TrafficStatsIncoming
{
	return mPeer.TrafficStatsIncoming;
}

- (EGTrafficStats*) TrafficStatsOutgoing
{
	return mPeer.TrafficStatsOutgoing;
}

- (EGTrafficStatsGameLevel*) TrafficStatsGameLevel
{
	return mPeer.TrafficStatsGameLevel;
}

- (nByte) QuickResendAttempts
{
	return mPeer.QuickResendAttempts;
}

- (void) setQuickResendAttempts:(nByte)quickResendAttempts
{
	mPeer.QuickResendAttempts = quickResendAttempts;
}

@synthesize State = mState;

- (NSString*) MasterserverAddress
{
	return mMasterserver;
}

@synthesize CountPlayersIngame = mPeerCount;
@synthesize CountGamesRunning = mRoomCount;

- (int) CountPlayersOnline
{
	return mPeerCount + mMasterPeerCount;
}

@synthesize RoomList = mRoomList;
@synthesize CurrentlyJoinedRoom = mCurrentlyJoinedRoom;

- (bool) IsInRoom
{
	return self.IsInGameRoom || self.IsInLobby;
}

- (bool) IsInGameRoom
{
	return mState == PeerStates::Joined;
}

- (bool) IsInLobby
{
	return mState == PeerStates::JoinedLobby;
}

@synthesize AutoJoinLobby = mAutoJoinLobby;
@synthesize LocalPlayer = mLocalPlayer;
@synthesize FriendList = mFriendList;
@synthesize DisconnectedCause = mDisconnectedCause;

- (int) FriendListAge
{
	return mIsFetchingFriendList||!mFriendListTimestamp ? 0 : GETTIMEMS()-mFriendListTimestamp;
}

@synthesize Logger = mLogger;



// methods

- (instancetype) init
{
	EG_ASSERT(false, @"not implemented");
	return nil;
}

- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username
{
	return [self initClient:listener :applicationID :appVersion :username :ConnectionProtocol::UDP];
}

- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol
{
	return [self initClient:listener :applicationID :appVersion :username :connectionProtocol :nil];
}

- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol :(EGAuthenticationValues*)authenticationValues
{
	return [self initClient:listener :applicationID :appVersion :username :connectionProtocol :authenticationValues :false];
}

- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol :(EGAuthenticationValues*)authenticationValues :(bool)autoLobbyStats
{
	return [self initClient:listener :applicationID :appVersion :username :connectionProtocol :authenticationValues :autoLobbyStats :true];
}

- (instancetype) initClient:(id<EGLoadBalancingListener>)listener :(NSString*)applicationID :(NSString*)appVersion :(NSString*)username :(nByte)connectionProtocol :(EGAuthenticationValues*)authenticationValues :(bool)autoLobbyStats :(bool)useDefaultRegion
{
	self = [super init];
	mPeer =  [[EGLoadBalancingPeer alloc] initWithPhotonListener:self :mConnectionProtocol=connectionProtocol];
	(mLogger = [EGLogger new]).Listener = mListener = [listener retain];
	mState = PeerStates::PeerCreated;
	mAppVersion = [appVersion retain];
	mCurrentlyJoinedRoom = [[self createMutableRoom:@"" :nil :nil :0 :0] retain];
	[self setLocalPlayer:-1 :[NSDictionary dictionaryWithObject:username forKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]]];
	mAppID = [applicationID retain];
	mAutoJoinLobby = true;
	mAuthenticationValues = [authenticationValues retain];
	mDisconnectedCause = DisconnectCause::NONE;
	mAutoLobbyStats = autoLobbyStats;
	mUseDefaultRegion = useDefaultRegion;    
	return self;
}

+ (instancetype) new
{
	EG_ASSERT(false, @"not implemented");
	return nil;
}

- (bool) connect
{
	return [self connect:NAMESERVER];
}

- (bool) connect:(NSString* const)serverAddress
{
	return [self connect:serverAddress :ServerType::NAME_SERVER];
}

- (bool) connect:(NSString* const)serverAddress :(nByte)serverType
{
	mAuthenticationValues.Secret = @""; //reset secret
	static const int NAMESERVER_PORT_GAP = 3;
	if(serverType == ServerType::MASTER_SERVER)
		mMasterserver = serverAddress;
	if([mPeer connect:[NSString stringWithFormat:@"%@%@", serverAddress, [serverAddress containsString:@":"]?@"":[NSString stringWithFormat:@":%d", (mConnectionProtocol==ConnectionProtocol::UDP?NetworkPort::UDP:NetworkPort::TCP)+(serverType==ServerType::NAME_SERVER?NAMESERVER_PORT_GAP:0)]]])
	{
		self.State = serverType==ServerType::NAME_SERVER?PeerStates::ConnectingToNameserver:PeerStates::Connecting;
		return true;
	}
	else
		return false;
}

- (void) disconnect
{
	mState = PeerStates::Disconnecting;
	[mPeer disconnect];
}

- (void) service
{
	[mPeer service];
}

- (void) service:(bool)dispatchIncomingCommands
{
	[mPeer service:dispatchIncomingCommands];
}

- (void) serviceBasic
{
	[mPeer serviceBasic];
}

- (bool) sendOutgoingCommands
{
	return [mPeer sendOutgoingCommands];
}

- (bool) sendAcksOnly
{
	return [mPeer sendAcksOnly];
}

- (bool) dispatchIncomingCommands
{
	return [mPeer dispatchIncomingCommands];
}

- (void) fetchServerTimestamp
{
	[mPeer fetchServerTimestamp];
}

- (void) resetTrafficStats
{
	[mPeer resetTrafficStats];
}

- (void) resetTrafficStatsMaximumCounters
{
	[mPeer resetTrafficStatsMaximumCounters];
}

- (NSString*) vitalStatsToString:(bool)all
{
	return [mPeer vitalStatsToString:all];
}

- (bool) opJoinLobby
{
	return [self opJoinLobby:nil];
}

- (bool) opJoinLobby:(NSString*)lobbyName
{
	return [self opJoinLobby:lobbyName :ExitGames::LoadBalancing::LobbyType::DEFAULT];
}

- (bool) opJoinLobby:(NSString*)lobbyName :(nByte)lobbyType
{
	if(self.IsInRoom)
	{
		EGLOG(ERRORS, L"already in a room");
		return false;
	}
	mLastLobbyJoinType = JoinType::EXPLICIT_JOIN_LOBBY;
	return [mPeer opJoinLobby :lobbyName :lobbyType];
}

- (bool) opLeaveLobby
{
	if(!self.IsInLobby)
	{
		EGLOG(ERRORS, L"lobby isn't currently joined");
		return false;
	}
	return [mPeer opLeaveLobby];
}

- (bool) opCreateRoom:(NSString*)gameID
{
	return [self opCreateRoom:gameID :true];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible
{
	return [self opCreateRoom:gameID :isVisible :true];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen
{
	return [self opCreateRoom:gameID :isVisible :isOpen :0];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers
{
	return [self opCreateRoom:gameID :isVisible :isOpen :maxPlayers :nil];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties
{
	return [self opCreateRoom:gameID :isVisible :isOpen :maxPlayers :customRoomProperties :nil];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby
{
	return [self opCreateRoom:gameID :isVisible :isOpen :maxPlayers :customRoomProperties :propsListedInLobby :nil];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName
{
	return [self opCreateRoom:gameID :isVisible :isOpen :maxPlayers :customRoomProperties :propsListedInLobby :lobbyName :LobbyType::DEFAULT];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType
{
	return [self opCreateRoom:gameID :isVisible :isOpen :maxPlayers :customRoomProperties :propsListedInLobby :lobbyName :lobbyType :0];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType :(int)playerTtl
{
	return [self opCreateRoom:gameID :isVisible :isOpen :maxPlayers :customRoomProperties :propsListedInLobby :lobbyName :lobbyType :playerTtl :0];
}

- (bool) opCreateRoom:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType :(int)playerTtl :(int)emptyRoomTtl
{
	if(self.IsInGameRoom)
	{
		EGLOG(ERRORS, L"already in a gameroom");
		return false;
	}
	if(mRoomName != gameID)
	{
		[mRoomName release];
		mRoomName = [gameID retain];
	}

	EGMutableDictionary* op = [mPeer opCreateRoomImplementation:gameID :isVisible :isOpen :maxPlayers :self.IsOnGameServer?customRoomProperties:nil :self.IsOnGameServer?self.LocalPlayer.CustomProperties:nil :self.IsOnGameServer?propsListedInLobby:nil  :lobbyName :lobbyType :playerTtl :emptyRoomTtl];
	if(self.LocalPlayer.Name)
	{
		if([op objectForKey:[NSValue value:&ParameterCode::PLAYER_PROPERTIES withObjCType:@encode(nByte)]])
			[[op objectForKey:[NSValue value:&ParameterCode::PLAYER_PROPERTIES withObjCType:@encode(nByte)]] setObject:self.LocalPlayer.Name forKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]];
		else
			[op setObject:[NSDictionary dictionaryWithObject:self.LocalPlayer.Name forKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]] forKey:[NSValue value:&ParameterCode::PLAYER_PROPERTIES withObjCType:@encode(nByte)]];
	}
	if(![mPeer opCustom:[EGOperationRequest operationRequestWithOperationCode:OperationCode::CREATE_ROOM :op] :true])
		return false;

	NSMutableDictionary* roomProps = [EGLoadBalancingPeer stripToCustomProperties:customRoomProperties];
	[roomProps setObject:[NSValue value:&isOpen withObjCType:@encode(bool)] forKey:[NSValue value:&Properties::Room::IS_OPEN withObjCType:@encode(nByte)]];
	[roomProps setObject:[NSValue value:&isVisible withObjCType:@encode(bool)] forKey:[NSValue value:&Properties::Room::IS_VISIBLE withObjCType:@encode(nByte)]];
	[roomProps setObject:[NSValue value:&maxPlayers withObjCType:@encode(nByte)] forKey:[NSValue value:&Properties::Room::MAX_PLAYERS withObjCType:@encode(nByte)]];
	[roomProps setObject:[propsListedInLobby.Type isEqual:NSStringFromClass([NSString class])]?[[propsListedInLobby copyDeep] autorelease]:[EGArray arrayWithType:NSStringFromClass([NSString class])] forKey:[NSValue value:&Properties::Room::PROPS_LISTED_IN_LOBBY withObjCType:@encode(nByte)]];

	[mCurrentlyJoinedRoom release];
	mCurrentlyJoinedRoom = [[self createMutableRoom:gameID :roomProps :propsListedInLobby :playerTtl :emptyRoomTtl] retain];
	mCurrentlyJoinedRoom.PlayerTtl = playerTtl;
	mCurrentlyJoinedRoom.EmptyRoomTtl = emptyRoomTtl;
	return true;
}

- (bool) opJoinRoom:(NSString*)gameID
{
    return [self opJoinRoom:gameID :false];
}

- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists
{
    return [self opJoinRoom:gameID :createIfNotExists :0];
}

- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists :(int)playerNumber
{
    return [self opJoinRoom:gameID :createIfNotExists :playerNumber :0];
}

- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex
{
    return [self opJoinRoom:gameID :createIfNotExists :playerNumber :cacheSliceIndex :0];
}

- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex :(int)playerTtl
{
	return [self opJoinRoom:gameID :createIfNotExists :playerNumber :cacheSliceIndex :playerTtl :0];
}

- (bool) opJoinRoom:(NSString*)gameID :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex :(int)playerTtl :(int)emptyRoomTtl
{
	if(self.IsInGameRoom)
	{
		EGLOG(ERRORS, L"already in a gameroom");
		return false;
	}
	if(mRoomName != gameID)
	{
		[mRoomName release];
		mRoomName = [gameID retain];
	}
    // TODO:
    if(playerNumber) // (workaround for some server issue we will fix)
        createIfNotExists = true;

	EGMutableDictionary* op = [mPeer opJoinRoomImplementation:gameID :self.IsOnGameServer?self.LocalPlayer.CustomProperties:nil :createIfNotExists :playerNumber :self.IsOnGameServer?cacheSliceIndex:0 :playerTtl :emptyRoomTtl];
	if(self.LocalPlayer.Name)
	{
		if([op objectForKey:[NSValue value:&ParameterCode::PLAYER_PROPERTIES withObjCType:@encode(nByte)]])
			[[op objectForKey:[NSValue value:&ParameterCode::PLAYER_PROPERTIES withObjCType:@encode(nByte)]] setObject:self.LocalPlayer.Name forKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]];
		else
			[op setObject:[NSDictionary dictionaryWithObject:self.LocalPlayer.Name forKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]] forKey:[NSValue value:&ParameterCode::PLAYER_PROPERTIES withObjCType:@encode(nByte)]];
	}
	if(!gameID || ![mPeer opCustom:[EGOperationRequest operationRequestWithOperationCode:OperationCode::JOIN_ROOM :op] :true])
		return false;
	[mCurrentlyJoinedRoom release];
	mCurrentlyJoinedRoom = [[self createMutableRoom:gameID :nil :nil :playerTtl :emptyRoomTtl] retain];
	
	mLastJoinCreateIfNotExists = createIfNotExists;
	mLastJoinPlayerNumber = playerNumber;
	mLastCacheSliceIndex = cacheSliceIndex;
	mCurrentlyJoinedRoom.PlayerTtl = playerTtl;
	mCurrentlyJoinedRoom.EmptyRoomTtl = emptyRoomTtl;

	return true;
}

- (bool) opJoinRandomRoom
{
	return [self opJoinRandomRoom:nil];
}

- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties
{
	return [self opJoinRandomRoom:customRoomProperties :0];
}

- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers
{
	return [self opJoinRandomRoom:customRoomProperties :maxPlayers :MatchmakingMode::FILL_ROOM];
}

- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers :(nByte)matchmakingMode
{
	return [self opJoinRandomRoom:customRoomProperties :maxPlayers :matchmakingMode :nil];
}

- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers :(nByte)matchmakingMode :(NSString*)lobbyName
{
	return [self opJoinRandomRoom:customRoomProperties :maxPlayers :matchmakingMode :lobbyName :LobbyType::DEFAULT];
}

- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers :(nByte)matchmakingMode :(NSString*)lobbyName :(nByte)lobbyType
{
	return [self opJoinRandomRoom:customRoomProperties :maxPlayers :matchmakingMode :lobbyName :lobbyType :nil];
}

- (bool) opJoinRandomRoom:(NSDictionary*)customRoomProperties :(nByte)maxPlayers :(nByte)matchmakingMode :(NSString*)lobbyName :(nByte)lobbyType :(NSString*)sqlLobbyFilter
{
	if(self.IsInGameRoom)
	{
		EGLOG(ERRORS, L"already in a gameroom");
		return false;
	}
	if(![mPeer opJoinRandomRoom:customRoomProperties :maxPlayers :matchmakingMode :lobbyName :lobbyType :sqlLobbyFilter])
		return false;

	[mCurrentlyJoinedRoom release];
	mCurrentlyJoinedRoom = [[self createMutableRoom:@"" :[EGLoadBalancingPeer stripToCustomProperties:customRoomProperties] :nil :0 :0] retain];
	return true;
}


- (bool) opLeaveRoom
{
	return [self opLeaveRoom:false];
}

- (bool) opLeaveRoom:(bool)willComeBack;
{
	if(!self.IsInGameRoom)
	{
		EGLOG(ERRORS, L"no gameroom is currently joined");
		return false;
	}
	if(willComeBack)
	{
		mState = PeerStates::DisconnectingFromGameserver;
		[mPeer disconnect];
	}
	else
	{
		if(![mPeer opLeaveRoom])
			return false;
		mState = PeerStates::Leaving;
	}
	return true;
}

- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode
{
	return [mPeer opRaiseEvent:reliable :parameters :eventCode];
}

- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID
{
	return [mPeer opRaiseEvent:reliable :parameters :eventCode :channelID];
}

- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching
{
	return [mPeer opRaiseEvent:reliable :parameters :eventCode :channelID :eventCaching];
}

- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers
{
	return [mPeer opRaiseEvent:reliable :parameters :eventCode :channelID :eventCaching :targetPlayers : numTargetPlayers];
}

- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers :(nByte)receiverGroup
{
	return [mPeer opRaiseEvent:reliable :parameters :eventCode :channelID :eventCaching :targetPlayers : numTargetPlayers :receiverGroup];
}

- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers :(nByte)receiverGroup :(nByte)interestGroup
{
	return [mPeer opRaiseEvent:reliable :parameters :eventCode :channelID :eventCaching :targetPlayers : numTargetPlayers :receiverGroup :interestGroup];
}

- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers :(nByte)receiverGroup :(nByte)interestGroup :(bool)forwardToWebhook
{
	return [mPeer opRaiseEvent:reliable :parameters :eventCode :channelID :eventCaching :targetPlayers : numTargetPlayers :receiverGroup :interestGroup :forwardToWebhook];
}

- (bool) opRaiseEvent:(bool)reliable :(id<NSObject>)parameters :(nByte)eventCode :(nByte)channelID :(nByte)eventCaching :(int*)targetPlayers :(short)numTargetPlayers :(nByte)receiverGroup :(nByte)interestGroup :(bool)forwardToWebhook :(int)cacheSliceIndex
{
	return [mPeer opRaiseEvent:reliable :parameters :eventCode :channelID :eventCaching :targetPlayers : numTargetPlayers :receiverGroup :interestGroup :forwardToWebhook :cacheSliceIndex];
}

- (bool) opFindFriends:(NSString**)friendsToFind :(short)numFriendsToFind
{
	if(self.IsOnGameServer || mIsFetchingFriendList)
		return false;
	[mFriendList release];
	EGMutableArray* friendList = [EGMutableArray arrayWithType:NSStringFromClass([EGFriendInfo class])];
	for(unsigned int i=0; i<numFriendsToFind; ++i)
		[friendList addObject:[EGFriendInfo friendInfo:friendsToFind[i]]];
	mFriendList = [[EGMutableArray alloc] initWithArray:friendList];
	return mIsFetchingFriendList = [mPeer opFindFriends:friendsToFind :numFriendsToFind];
}

- (bool) opLobbyStats
{
	return [self opLobbyStats:nil];
}

- (bool) opLobbyStats:(EGArray*)lobbiesToQuery
{
	if(!self.IsInLobby)
	{
		EGLOG(ERRORS, L"lobby isn't currently joined");
		return false;
	}
    [mLobbyStatsList release];
	mLobbyStatsList = lobbiesToQuery?[[EGArray alloc] initWithArray:lobbiesToQuery]:nil;
	return [mPeer opLobbyStats:lobbiesToQuery];
}

- (bool) opChangeGroups:(EGArray*)groupsToRemove :(EGArray*)groupsToAdd
{
	if(!self.IsOnGameServer)
		return false;
    return [mPeer opChangeGroups:groupsToRemove :groupsToAdd];
}

- (bool) opCustomAuthenticationSendNextStepData:(EGAuthenticationValues*) authenticationValues
{
	if(mState != PeerStates::WaitingForCustomAuthenticationNextStepCall)
		return false;
	mState = PeerStates::ConnectedToNameserver;
	return [mPeer opAuthenticate:mAppID :mAppVersion :SEND_AUTHENTICATE_ENCRYPTED :self.LocalPlayer.Name :authenticationValues :mAutoLobbyStats :mSelectedRegion];
}

- (bool) opWebRpc:(NSString*)uriPath :(NSObject*) parameters
{
	return [mPeer opWebRpc:uriPath :parameters];
}

- (bool) opGetRegions:(bool)encrypted :(NSString*)appID
{
	return [mPeer opGetRegions:encrypted :appID];
}

- (bool) selectRegion:(NSString* const)selectedRegion
{
    if(mUseDefaultRegion)
    {
        EGLOG(ERRORS, L"this function should only be called, when when you have explicitly specified in the constructor not to use the default region.");
        return false;
    }
    else
    {
        mSelectedRegion=[selectedRegion copy];
        return [mPeer opAuthenticate:mAppID :mAppVersion :SEND_AUTHENTICATE_ENCRYPTED :self.LocalPlayer.Name :mAuthenticationValues :mAutoLobbyStats :selectedRegion];
    }
}

// inherited

- (void) dealloc
{
	[mFriendList release];
	[mRoomList release];
	[mRoomName release];
	[mGameserver release];
	[mAuthenticationValues release];
	[mAppID release];
	[mLocalPlayer release];
	[mCurrentlyJoinedRoom release];
	[mAppVersion release];
	[mLogger release];
	[mListener release];
	[mPeer dealloc];
	[super dealloc];
}



// protocol implementations

- (void) onOperationResponse:(EGOperationResponse*)operationResponse
{
	EGLOG(operationResponse.ReturnCode?ERRORS:INFO, [operationResponse toString:true :true].UTF32String);
	
	// Use the secret whenever we get it, no matter the operation code.
	if([operationResponse objectForKey:[NSValue value:&ParameterCode::SECRET withObjCType:@encode(nByte)]])
	{
		if(!mAuthenticationValues)
			mAuthenticationValues = [EGAuthenticationValues new];
		mAuthenticationValues.Secret = [operationResponse objectForKey:[NSValue value:&ParameterCode::SECRET withObjCType:@encode(nByte)]];
		EGLOG(INFO, L"Server returned secret: %ls.", mAuthenticationValues.Secret.UTF32String);
		if([mListener respondsToSelector:@selector(onSecretReceival:)])
			[mListener onSecretReceival:mAuthenticationValues.Secret];
	}

	switch(operationResponse.OperationCode)
	{
		case OperationCode::AUTHENTICATE:
		{
			int oldState = mState;
			if(operationResponse.ReturnCode)
			{
				EGLOG(ERRORS, L"authentication failed with errorcode %d: %ls", operationResponse.ReturnCode, operationResponse.DebugMessage.UTF32String);
				
				switch(operationResponse.ReturnCode)
				{
					case ExitGames::LoadBalancing::ErrorCode::INVALID_AUTHENTICATION:
						mDisconnectedCause = DisconnectCause::INVALID_AUTHENTICATION;
						break;
					case ExitGames::LoadBalancing::ErrorCode::CUSTOM_AUTHENTICATION_FAILED:
						mDisconnectedCause = DisconnectCause::CUSTOM_AUTHENTICATION_FAILED;
						break;
					case ExitGames::LoadBalancing::ErrorCode::INVALID_REGION:
						mDisconnectedCause = DisconnectCause::INVALID_REGION;
						break;
					case ExitGames::LoadBalancing::ErrorCode::MAX_CCU_REACHED:
						mDisconnectedCause = DisconnectCause::MAX_CCU_REACHED;
						break;
					case ExitGames::LoadBalancing::ErrorCode::OPERATION_DENIED:
						mDisconnectedCause = DisconnectCause::OPERATION_NOT_ALLOWED_IN_CURRENT_STATE;
						break;
				}

				[self handleConnectionFlowError:oldState :operationResponse.ReturnCode :operationResponse.DebugMessage];
				break;
			}
			else
			{
				if(mState == PeerStates::ConnectedToNameserver)
				{
					if([operationResponse objectForKey:[NSValue value:&ParameterCode::DATA withObjCType:@encode(nByte)]])
					{
						mState = PeerStates::WaitingForCustomAuthenticationNextStepCall;
						if([mListener respondsToSelector:@selector(onCustomAuthenticationIntermediateStep:)])
							[mListener onCustomAuthenticationIntermediateStep:[operationResponse objectForKey:[NSValue value:&ParameterCode::DATA withObjCType:@encode(nByte)]]];
						break;
					}
					else
					{
						mState = PeerStates::DisconnectingFromNameserver;
						mMasterserver = [[operationResponse objectForKey:[NSValue value:&ParameterCode::ADDRESS withObjCType:@encode(nByte)]] copy];
						[mPeer disconnect];
					}
				}
				else if(mState == PeerStates::Connected || mState == PeerStates::ConnectedComingFromGameserver)
				{
					mState = mState==PeerStates::Connected?PeerStates::Authenticated:PeerStates::AuthenticatedComingFromGameserver;
					if(mAutoJoinLobby)
					{
						[self opJoinLobby];
						mLastLobbyJoinType = JoinType::AUTO_JOIN_LOBBY;
					}
					else
						[self onConnectToMasterFinished:oldState==PeerStates::ConnectedComingFromGameserver];
					
				}
				else if(mState == PeerStates::ConnectedToGameserver)
				{
					mState = PeerStates::Joining;
					if(mLastJoinType == JoinType::CREATE_ROOM)
						[self opCreateRoom:mRoomName :mCurrentlyJoinedRoom.IsVisible :mCurrentlyJoinedRoom.IsOpen :mCurrentlyJoinedRoom.MaxPlayers :mCurrentlyJoinedRoom.CustomProperties :mCurrentlyJoinedRoom.PropsListedInLobby :nil :LobbyType::DEFAULT :mCurrentlyJoinedRoom.PlayerTtl :mCurrentlyJoinedRoom.EmptyRoomTtl];
					else if(mLastJoinType == JoinType::JOIN_ROOM)
						[self opJoinRoom:mRoomName :mLastJoinCreateIfNotExists :mLastJoinPlayerNumber :mLastCacheSliceIndex :mCurrentlyJoinedRoom.PlayerTtl :mCurrentlyJoinedRoom.EmptyRoomTtl];
					else if(mLastJoinType == JoinType::JOIN_RANDOM_ROOM)
						[self opJoinRoom:mRoomName];
				}
			}
		}
			break;
		case OperationCode::CREATE_ROOM:
		case OperationCode::JOIN_ROOM:
			if(self.IsOnGameServer)
			{
				if(operationResponse.ReturnCode)
				{
					EGLOG(ERRORS, L"%ls failed with errorcode %d: %ls. Client is therefore returning to masterserver!", operationResponse.OperationCode==OperationCode::CREATE_ROOM?L"opCreateRoom":L"opJoinRoom", operationResponse.ReturnCode, operationResponse.DebugMessage);
					[self handleConnectionFlowError:mState :operationResponse.ReturnCode :operationResponse.DebugMessage];
					break;
				}
				mState = PeerStates::Joined;
				int nr;
				[[operationResponse objectForKey:[NSValue value:&ParameterCode::PLAYERNR withObjCType:@encode(nByte)]] getValue:&nr];
				NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:self.LocalPlayer.CustomProperties];
				[dic setObject:self.LocalPlayer.Name forKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]];
				mCurrentlyJoinedRoom.Players = [EGMutableArray arrayWithType:NSStringFromClass([EGLoadBalancingPlayer class])];
				[mCurrentlyJoinedRoom addPlayer:[self setLocalPlayer:nr :dic]];
				NSMutableDictionary* roomProperties = [NSMutableDictionary dictionaryWithDictionary:[operationResponse objectForKey:[NSValue value:&ParameterCode::ROOM_PROPERTIES withObjCType:@encode(nByte)]]];
				NSMutableDictionary* playerProperties = [NSMutableDictionary dictionaryWithDictionary:[operationResponse objectForKey:[NSValue value:&ParameterCode::PLAYER_PROPERTIES withObjCType:@encode(nByte)]]];
				NSValue** numbers = (id*)EG_MALLOC(playerProperties.count*sizeof(NSValue*));
				NSDictionary** vals = (NSDictionary**)EG_MALLOC(playerProperties.count*sizeof(NSString*));
				[playerProperties getObjects:vals andKeys:numbers];
				for(int i=0; i<playerProperties.count; i++)
				{
					[numbers[i] getValue:&nr];
					[mCurrentlyJoinedRoom addPlayer:nr :vals[i]];
				}
				EG_FREE(numbers);
				EG_FREE(vals);
				[self readoutProperties:&roomProperties :&playerProperties :true :0];
				switch(mLastJoinType)
				{
					case JoinType::CREATE_ROOM:
						[mListener createRoomReturn:nr :roomProperties :playerProperties :operationResponse.ReturnCode :operationResponse.DebugMessage];
						break;
					case JoinType::JOIN_ROOM:
						[mListener joinRoomReturn:nr :roomProperties :playerProperties :operationResponse.ReturnCode :operationResponse.DebugMessage];
						break;
					case JoinType::JOIN_RANDOM_ROOM:
						[mListener joinRandomRoomReturn:nr :roomProperties :playerProperties :operationResponse.ReturnCode :operationResponse.DebugMessage];
						break;
					default:
						break;
				}
				break;
			}
			else
			{
				switch(operationResponse.OperationCode)
				{
					case OperationCode::CREATE_ROOM:
					{
						if(operationResponse.ReturnCode)
						{
							EGLOG(ERRORS, L"opCreateRoom failed with errorcode %d: %ls. Client is therefore staying on masterserver!", operationResponse.ReturnCode, operationResponse.DebugMessage.UTF32String);
							[mListener createRoomReturn:0 :nil :nil :operationResponse.ReturnCode :operationResponse.DebugMessage];
							break;
						}
						NSString* gameID = [operationResponse objectForKey:[NSValue value:&ParameterCode::ROOM_NAME withObjCType:@encode(nByte)]];
						if(gameID) // is only sent by the server's response, if it has not been sent with the client's request before!
						{
							[mRoomName release];
							mRoomName = [gameID retain];
						}
						[mGameserver release];
						mGameserver = [[operationResponse objectForKey:[NSValue value:&ParameterCode::ADDRESS withObjCType:@encode(nByte)]] retain];
						mState = PeerStates::DisconnectingFromMasterserver;
						[mPeer disconnect];
						mLastJoinType = JoinType::CREATE_ROOM;
					}
						break;
					case OperationCode::JOIN_ROOM:
						if(operationResponse.ReturnCode)
						{
							EGLOG(ERRORS, L"opJoinRoom failed with errorcode %d: %ls. Client is therefore staying on masterserver!", operationResponse.ReturnCode, operationResponse.DebugMessage.UTF32String);
							[mListener joinRoomReturn:0 :nil :nil :operationResponse.ReturnCode :operationResponse.DebugMessage];
							break;
						}
						[mGameserver release];
						mGameserver = [[operationResponse objectForKey:[NSValue value:&ParameterCode::ADDRESS withObjCType:@encode(nByte)]] retain];
						mState = PeerStates::DisconnectingFromMasterserver;
						[mPeer disconnect];
						mLastJoinType = JoinType::JOIN_ROOM;
						break;
					default:
						break;
				}
			}
			break;
		case OperationCode::JOIN_RANDOM_ROOM:
			if(operationResponse.ReturnCode)
			{
				EGLOG(ERRORS, L"opJoinRandomRoom failed with errorcode %d: %ls. Client is therefore staying on masterserver!", operationResponse.ReturnCode, operationResponse.DebugMessage.UTF32String);
				[mListener joinRandomRoomReturn:0 :nil :nil :operationResponse.ReturnCode :operationResponse.DebugMessage];
				break;
			}
			// store the ID of the random game, joined on the masterserver, so that we know, which game to join on the gameserver
			[mRoomName release];
			mRoomName = [[operationResponse objectForKey:[NSValue value:&ParameterCode::ROOM_NAME withObjCType:@encode(nByte)]] retain];
			[mGameserver release];
			mGameserver = [[operationResponse objectForKey:[NSValue value:&ParameterCode::ADDRESS withObjCType:@encode(nByte)]] retain];
			mState = PeerStates::DisconnectingFromMasterserver;
			[mPeer disconnect];
			mLastJoinType = JoinType::JOIN_RANDOM_ROOM;
			break;
		case OperationCode::JOIN_LOBBY:
		{
			int oldState = mState;
			mState = PeerStates::JoinedLobby;
			if(mLastLobbyJoinType == JoinType::AUTO_JOIN_LOBBY)
				[self onConnectToMasterFinished:oldState==PeerStates::AuthenticatedComingFromGameserver];
			else
				[mListener joinLobbyReturn];
		}
			break;
		case OperationCode::LEAVE_LOBBY:
			mState = PeerStates::Authenticated;
			[mListener leaveLobbyReturn];
			break;
		case OperationCode::LEAVE:
		{
			NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:self.LocalPlayer.CustomProperties];
			[dic setObject:self.LocalPlayer.Name forKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]];
			[self setLocalPlayer:-1 :dic];
			[mCurrentlyJoinedRoom removeAllPlayers];
			mState = PeerStates::DisconnectingFromGameserver;
			[mPeer disconnect];
		}
			break;
		case OperationCode::FIND_FRIENDS:
		{
			mIsFetchingFriendList = false;
			if(operationResponse.ReturnCode)
			{
				EGLOG(ERRORS, L"opFindFriends failed with errorcode %d: %ls.", operationResponse.ReturnCode, operationResponse.DebugMessage.UTF32String);
				break;
			}
			bool* pOnlineList = static_cast<bool*>(const_cast<void*>([[operationResponse objectForKey:[NSValue value:&ParameterCode::FIND_FRIENDS_RESPONSE_ONLINE_LIST withObjCType:@encode(nByte)]] CArray]));
			NSString** pRoomList = static_cast<NSString**>(const_cast<void*>([[operationResponse objectForKey:[NSValue value:&ParameterCode::FIND_FRIENDS_RESPONSE_ROOM_ID_LIST withObjCType:@encode(nByte)]] CArray]));
			for(unsigned int i=0; i<mFriendList.count; ++i)
				[mFriendList replaceObjectAtIndex:i withObject:[EGFriendInfo friendInfo:[[mFriendList objectAtIndex:i] Name] :pOnlineList[i] :pRoomList[i]]];
			mFriendListTimestamp = GETTIMEMS()?:1;
			[mListener onFindFriendsResponse];
		}
			break;
		case OperationCode::LOBBY_STATS:
		{
			if(operationResponse.ReturnCode)
			{
				EGLOG(ERRORS, L"opLobbyStats failed with errorcode %d: %ls.", operationResponse.ReturnCode, operationResponse.DebugMessage.UTF32String);
				break;
			}
			
			EGArray* names = [operationResponse objectForKey:[NSValue value:&ParameterCode::LOBBY_NAME withObjCType:@encode(nByte)]];
			EGArray* types = [operationResponse objectForKey:[NSValue value:&ParameterCode::LOBBY_TYPE withObjCType:@encode(nByte)]];
			EGArray* peers = [operationResponse objectForKey:[NSValue value:&ParameterCode::PEER_COUNT withObjCType:@encode(nByte)]];
			EGArray* rooms = [operationResponse objectForKey:[NSValue value:&ParameterCode::ROOM_COUNT withObjCType:@encode(nByte)]];

            EGMutableArray* res = [EGMutableArray arrayWithType:NSStringFromClass([EGLobbyStatsResponse class])];

			if(names)
			{
				for(int i=0; i<names.count; ++i)
				{
					nByte type = 0;
					int peerCount = 0;
					int roomCount = 0;
					[[types objectAtIndex:i] getValue:&type];
					[[peers objectAtIndex:i] getValue:&peerCount];
					[[rooms objectAtIndex:i] getValue:&roomCount];
					[res addObject:[[EGLobbyStatsResponse alloc] initLobbyStatsResponse:[names objectAtIndex:i] :type :peerCount : roomCount]];
				}
			}
			else if(mLobbyStatsList) // may be nil if we got response on request w/o lobbies before next one with lobbies
			{
				for(int i=0; i<mLobbyStatsList.count; ++i)
				{
					int peerCount = 0;
					int roomCount = 0;
					if(i < peers.count)
						[[peers objectAtIndex:i] getValue:&peerCount];
					if(i < rooms.count)
                        [[rooms objectAtIndex:i] getValue:&roomCount];
                    EGLobbyStatsResponse *s = [mLobbyStatsList objectAtIndex:i];
					[res addObject:[EGLobbyStatsResponse lobbyStatsResponse :s.Name :s.Type :peerCount :roomCount]];
				}
			}
			if([mListener respondsToSelector:@selector(onLobbyStatsResponse:)])
				[mListener onLobbyStatsResponse:res];
		}
			break;
		case OperationCode::GET_REGIONS:
		{
			if(operationResponse.ReturnCode)
			{
				EGLOG(ERRORS, L"GetRegions failed with errorcode %d: %ls.", operationResponse.ReturnCode, operationResponse.DebugMessage.UTF32String);
				break;
			}
			EGArray* availableRegions = [EGArray arrayWithArray:[operationResponse objectForKey:[NSValue value:&ParameterCode::REGION withObjCType:@encode(nByte)]]];
			EGArray* availableRegionServers = [EGArray arrayWithArray:[operationResponse objectForKey:[NSValue value:&ParameterCode::ADDRESS withObjCType:@encode(nByte)]]];
			if(mUseDefaultRegion)
			{
				mSelectedRegion=[availableRegions objectAtIndex:0];
				[mPeer opAuthenticate:mAppID :mAppVersion :SEND_AUTHENTICATE_ENCRYPTED :self.LocalPlayer.Name :mAuthenticationValues :mAutoLobbyStats :mSelectedRegion];
			}
			else
			{
				if([mListener respondsToSelector:@selector(onAvailableRegions::)])
					[mListener onAvailableRegions:availableRegions :availableRegionServers];
			}
		}
			break;
		case OperationCode::RPC:
			{
				if(operationResponse.ReturnCode)
					EGLOG(ERRORS, L"WebRpc failed with errorcode %d: %ls.", operationResponse.ReturnCode, operationResponse.DebugMessage.UTF32String);
				int returnCode = 0;
				[[operationResponse objectForKey:[NSValue value:&ParameterCode::RPC_CALL_RET_CODE withObjCType:@encode(nByte)]] getValue:&returnCode];
				NSString* uriPath = [operationResponse objectForKey:[NSValue value:&ParameterCode::URI_PATH withObjCType:@encode(nByte)]];
				id returnData = [operationResponse objectForKey:[NSValue value:&ParameterCode::RPC_CALL_PARAMS withObjCType:@encode(nByte)]];
				[mListener webRpcReturn:operationResponse.ReturnCode :operationResponse.DebugMessage :uriPath :returnCode :returnData];
			}
			break;			
		default:
			break;
	}
}

- (void) onStatusChanged:(int)statusCode
{
	switch(statusCode)
	{
		case 0:
			break;
		case StatusCode::CONNECT:
		{
			if(mState == PeerStates::ConnectingToNameserver)
			{
				EGLOG(INFO, L"connected to nameserver");
				mState = PeerStates::ConnectedToNameserver;
			}
			else if(mState == PeerStates::ConnectingToGameserver)
			{
				EGLOG(INFO, L"connected to gameserver");
				mState = PeerStates::ConnectedToGameserver;
			}
			else
			{
				EGLOG(INFO, L"connected to masterserver");
				mState = mState==PeerStates::Connecting?PeerStates::Connected:PeerStates::ConnectedComingFromGameserver;
			}
			if(SEND_AUTHENTICATE_ENCRYPTED)
				[mPeer establishEncryption];
			else if(mState == PeerStates::ConnectedToNameserver)
				[mPeer opGetRegions:false :mAppID];
			else
				[mPeer opAuthenticate:mAppID :mAppVersion :false :self.LocalPlayer.Name :mAuthenticationValues :mAutoLobbyStats]; // secret is encrypted anyway
			break;

		}
			break;
		case StatusCode::DISCONNECT:
		{
			if(mState == PeerStates::DisconnectingFromNameserver)
			{
				[mPeer connect:mMasterserver];
				mState = PeerStates::Connecting;
			}
			else if(mState == PeerStates::DisconnectingFromMasterserver)
			{
				[mPeer connect:mGameserver];
				mState = PeerStates::ConnectingToGameserver;
			}
			else if(mState == PeerStates::DisconnectingFromGameserver)
			{
				[mPeer connect:(NSString*)mMasterserver];
				mState = PeerStates::ConnectingToMasterserver;
			}
			else
			{
				mState = PeerStates::PeerCreated;
				[mListener disconnectReturn];
			}
		}
			break;
		case StatusCode::ENCRYPTION_ESTABLISHED:
			if(mState == PeerStates::ConnectedToNameserver)
				[mPeer opGetRegions:true :mAppID];
			else
				[mPeer opAuthenticate:mAppID :mAppVersion :true :self.LocalPlayer.Name :mAuthenticationValues :mAutoLobbyStats];
			break;
		case StatusCode::ENCRYPTION_FAILED_TO_ESTABLISH:
			[self handleConnectionFlowError:mState :statusCode :@"Encryption failed to establish"];
			break;
		// cases till next break should set mDisconnectedCause below			
		case StatusCode::EXCEPTION:
		case StatusCode::EXCEPTION_ON_CONNECT:
		case StatusCode::INTERNAL_RECEIVE_EXCEPTION:
		case StatusCode::TIMEOUT_DISCONNECT:
		case StatusCode::DISCONNECT_BY_SERVER:
		case StatusCode::DISCONNECT_BY_SERVER_USER_LIMIT:
		case StatusCode::DISCONNECT_BY_SERVER_LOGIC:
			[mListener connectionErrorReturn:statusCode];
			if(mPeer.Peerstate != PeerState::DISCONNECTED && mPeer.Peerstate != PeerState::DISCONNECTING)
				[self disconnect];
			break;
		case StatusCode::SEND_ERROR:
			[mListener clientErrorReturn:statusCode];
			break;
		case StatusCode::QUEUE_OUTGOING_RELIABLE_WARNING:
		case StatusCode::QUEUE_OUTGOING_UNRELIABLE_WARNING:
		case StatusCode::QUEUE_OUTGOING_ACKS_WARNING:
		case StatusCode::QUEUE_SENT_WARNING:
			[mListener warningReturn:statusCode];
			break;
		case LoadBalancing::ErrorCode::OPERATION_INVALID:
		case LoadBalancing::ErrorCode::INTERNAL_SERVER_ERROR:
			[mListener serverErrorReturn:statusCode];
			break;
		default:
			EGLOG(ERRORS, L"received unknown status-code from server");
			break;
	}
	// above cases starting from StatusCode::EXCEPTION till next break should set mDisconnectedCause here
	switch(statusCode)
	{
		case StatusCode::DISCONNECT_BY_SERVER_USER_LIMIT:
			mDisconnectedCause = DisconnectCause::DISCONNECT_BY_SERVER_USER_LIMIT;
			break;
		case StatusCode::EXCEPTION_ON_CONNECT:
			mDisconnectedCause = DisconnectCause::EXCEPTION_ON_CONNECT;
			break;
		case StatusCode::DISCONNECT_BY_SERVER:
			mDisconnectedCause = DisconnectCause::DISCONNECT_BY_SERVER;
			break;
		case StatusCode::DISCONNECT_BY_SERVER_LOGIC:
			mDisconnectedCause = DisconnectCause::DISCONNECT_BY_SERVER_LOGIC;
			break;
		case StatusCode::TIMEOUT_DISCONNECT:
			mDisconnectedCause = DisconnectCause::TIMEOUT_DISCONNECT;
			break;
		case StatusCode::EXCEPTION:
		case StatusCode::INTERNAL_RECEIVE_EXCEPTION:
			mDisconnectedCause = DisconnectCause::EXCEPTION;
			break;
	}
}

- (void) onEvent:(EGEventData*)eventData
{
	EGLOG(INFO, [eventData toString].UTF32String); // don't print out the payload here, as that can get too expensive for big events
	switch(eventData.Code)
	{
		case EventCode::ROOM_LIST:
		{
			[mRoomList release];
			NSDictionary* roomList = [eventData objectForKey:[NSValue value:&ParameterCode::ROOM_LIST withObjCType:@encode(nByte)]];
			NSString** keys = new NSString*[roomList.count];
			NSDictionary** vals = new NSDictionary*[roomList.count];
			[roomList getObjects:vals andKeys:keys];
			mRoomList = [[NSMutableDictionary alloc] initWithCapacity:roomList.count];
			for(int i=0; i<roomList.count; i++)
				[mRoomList setObject:[self createRoom:keys[i] :vals[i]] forKey:keys[i]];
			delete[] keys;
			delete[] vals;
			if([mListener respondsToSelector:@selector(onRoomListUpdate)])
				[mListener onRoomListUpdate];
		}
			break;
		case EventCode::ROOM_LIST_UPDATE:
		{
			NSDictionary* roomListUpdate = [eventData objectForKey:[NSValue value:&ParameterCode::ROOM_LIST withObjCType:@encode(nByte)]];
			EGArray* keys = [EGArray arrayWithArray:roomListUpdate.allKeys];
			for(int i=0; i<keys.count; i++)
			{
				NSDictionary* val = [roomListUpdate objectForKey:[keys objectAtIndex:i]];
				bool removed = false;
				[(NSValue*)[val objectForKey:[NSValue value:&Properties::Room::REMOVED withObjCType:@encode(nByte)]] getValue:&removed];
				if(removed) // remove room
					[mRoomList removeObjectForKey:[keys objectAtIndex:i]];
				else
				{
					EGLoadBalancingRoom* room = [mRoomList objectForKey:[keys objectAtIndex:i]];
					if(room) // update room (only entries, which have been changed, have been sent)
						[room cacheProperties:val];
					else // add room
						[mRoomList setObject:[self createRoom:[keys objectAtIndex:i] :val] forKey:[keys objectAtIndex:i]];
				}
			}
			if([mListener respondsToSelector:@selector(onRoomListUpdate)])
				[mListener onRoomListUpdate];
		}
			break;
		case EventCode::APP_STATS:
			[[eventData objectForKey:[NSValue value:&ParameterCode::PEER_COUNT withObjCType:@encode(nByte)]] getValue:&mPeerCount];
			[[eventData objectForKey:[NSValue value:&ParameterCode::ROOM_COUNT withObjCType:@encode(nByte)]] getValue:&mRoomCount];
			[[eventData objectForKey:[NSValue value:&ParameterCode::MASTER_PEER_COUNT withObjCType:@encode(nByte)]] getValue:&mMasterPeerCount];
			if([mListener respondsToSelector:@selector(onAppStatsUpdate)])
				[mListener onAppStatsUpdate];
			break;
		case EventCode::LOBBY_STATS:
			{
				EGArray* names = [eventData objectForKey:[NSValue value:&ParameterCode::LOBBY_NAME withObjCType:@encode(nByte)]];
				EGArray* types = [eventData objectForKey:[NSValue value:&ParameterCode::LOBBY_TYPE withObjCType:@encode(nByte)]];
				EGArray* peers = [eventData objectForKey:[NSValue value:&ParameterCode::PEER_COUNT withObjCType:@encode(nByte)]];
				EGArray* rooms = [eventData objectForKey:[NSValue value:&ParameterCode::ROOM_COUNT withObjCType:@encode(nByte)]];

                EGMutableArray* res = [EGMutableArray arrayWithType:NSStringFromClass([EGLobbyStatsResponse class])];
                
				for(int i=0; i<names.count; ++i)
				{
					nByte type = 0;
					int peerCount = 0;
					int roomCount = 0;
					[[types objectAtIndex:i] getValue:&type];
					[[peers objectAtIndex:i] getValue:&peerCount];
					[[rooms objectAtIndex:i] getValue:&roomCount];
					[res addObject:[[EGLobbyStatsResponse alloc] initLobbyStatsResponse:[names objectAtIndex:i] :type :peerCount : roomCount]];
				}
				if([mListener respondsToSelector:@selector(onLobbyStatsUpdate:)])
					[mListener onLobbyStatsUpdate:res];
			}
			break;
			
		case EventCode::JOIN:
		{
			EGLOG(INFO, L"%ls", [eventData toString:true :true].UTF32String);
			int nr = -1;
			[(NSValue*)[eventData objectForKey:[NSValue value:&ParameterCode::PLAYERNR withObjCType:@encode(nByte)]] getValue:&nr];
			NSDictionary* props = [eventData objectForKey:[NSValue value:&ParameterCode::PLAYER_PROPERTIES withObjCType:@encode(nByte)]];
			EGLoadBalancingPlayer* player = [mCurrentlyJoinedRoom getPlayerForNumber:nr];
			if(player)
			{
				[player setIsInactive:false];
				[player cacheProperties:props];
			}
			else
			{
				player = [mCurrentlyJoinedRoom createPlayer:nr :props];
				if(nr != self.LocalPlayer.Number)
					[mCurrentlyJoinedRoom addPlayer:player];
			}
			[mListener joinRoomEventAction:nr :[eventData objectForKey:[NSValue value:&ParameterCode::PLAYER_LIST withObjCType:@encode(nByte)]] :player];
		}
			break;
		case EventCode::LEAVE:
		{
			int nr = -1;
			bool isInactive = false;
			[(NSValue*)[eventData objectForKey:[NSValue value:&ParameterCode::PLAYERNR withObjCType:@encode(nByte)]] getValue:&nr];
			[(NSValue*)[eventData objectForKey:[NSValue value:&ParameterCode::IS_INACTIVE withObjCType:@encode(nByte)]] getValue:&isInactive];
			if(isInactive)
			{
				EGLoadBalancingPlayer* player = [mCurrentlyJoinedRoom getPlayerForNumber:nr];
				if(player)
					player.IsInactive = nr;
				else
					EGLOG(WARNINGS, L"EventCode::LEAVE - player %d, who is leaving the room, has not been found in list of players, who are currently in the room", nr);
			}
			else
			{
				if(![mCurrentlyJoinedRoom removePlayer:nr])
					EGLOG(WARNINGS, L"EventCode::LEAVE - player %d, who is leaving the room, has not been found in list of players, who are currently in the room", nr);
			}
			[mListener leaveRoomEventAction:nr :isInactive];
		}
			break;
		case EventCode::PROPERTIES_CHANGED:
		{
			int target = 0;
			[(NSValue*)[eventData objectForKey:[NSValue value:&ParameterCode::TARGET_PLAYERNR withObjCType:@encode(nByte)]] getValue:&target];
			NSMutableDictionary* roomProperties = nil;
			NSMutableDictionary* playerProperties = nil;
			if(target)
				playerProperties = [eventData objectForKey:[NSValue value:&ParameterCode::PROPERTIES withObjCType:@encode(nByte)]];
			else
				roomProperties = [eventData objectForKey:[NSValue value:&ParameterCode::PROPERTIES withObjCType:@encode(nByte)]];
			[self readoutProperties:&roomProperties :&playerProperties :false :target];
			if(playerProperties && [mListener respondsToSelector:@selector(onPlayerPropertiesChange::)])
				[mListener onPlayerPropertiesChange:target :playerProperties];
			else if([mListener respondsToSelector:@selector(onRoomPropertiesChange:)])
				[mListener onRoomPropertiesChange:roomProperties];
		}
			break;
		case EventCode::CACHE_SLICE_CHANGED:
		{
			int cacheSliceIndex = 0;
			[(NSValue*)[eventData objectForKey:[NSValue value:&ParameterCode::CACHE_SLICE_INDEX withObjCType:@encode(nByte)]] getValue:&cacheSliceIndex];

			if([mListener respondsToSelector:@selector(onCacheSliceChanged:)])
				[mListener onCacheSliceChanged:cacheSliceIndex];
			break;
		}
		default: // custom events are forwarded to the custom room code
		{
			int nr = 0;
			[(NSValue*)[eventData objectForKey:[NSValue value:&ParameterCode::PLAYERNR withObjCType:@encode(nByte)]] getValue:&nr];
			// custom event data is inside an inner hash
			[mListener customEventAction:nr :eventData.Code :[eventData objectForKey:[NSValue value:&ParameterCode::DATA withObjCType:@encode(nByte)]]];
		}
			break;
	}
}

- (void) debugReturn:(int)debugLevel :(NSString*)string
{
	[mListener debugReturn:debugLevel :string];
}



// protecteds

- (EGLoadBalancingMutablePlayer*) createMutablePlayer:(int)number :(NSDictionary*)properties
{
	return [EGLoadBalancingMutablePlayer loadBalancingPlayer:number :properties :self.CurrentlyJoinedRoom :self];
}

- (id) createRoom:(NSString*)name :(NSDictionary*)properties
{
	return [EGLoadBalancingRoom loadBalancingRoom:name :properties];
}

- (id) createMutableRoom:(NSString*)name :(NSDictionary*)properties :(EGArray*)propsListedInLobby :(int)playerTtl :(int)emptyRoomTtl
{
	return [EGLoadBalancingMutableRoom loadBalancingRoom:name :properties :self :propsListedInLobby :playerTtl :emptyRoomTtl];
}



// internals

- (bool) opSetPropertiesOfPlayer:(int)playerNr :(NSDictionary*)properties
{
	if(!self.IsInGameRoom)
		return false;
	return [mPeer opSetPropertiesOfPlayer:(int)playerNr :(NSDictionary*)properties];
}

- (bool) opSetPropertiesOfRoom:(NSDictionary*)properties
{
	if(!self.IsInGameRoom)
		return false;
	return [mPeer opSetPropertiesOfRoom:(NSDictionary*)properties];
}

- (bool) opSetPropertiesOfRoom:(NSDictionary*)properties :(bool)webForward
{
	if(!self.IsInGameRoom)
		return false;
	return [mPeer opSetPropertiesOfRoom:(NSDictionary*)properties :webForward];
}



// privates

- (bool) IsOnGameServer
{
	return mState >= PeerStates::ConnectingToGameserver && mState < PeerStates::ConnectingToMasterserver;
}

- (EGLoadBalancingMutablePlayer*) setLocalPlayer:(EGLoadBalancingMutablePlayer*)localPlayer
{
	if(mLocalPlayer == localPlayer)
		return mLocalPlayer;
	[mLocalPlayer release];
	return mLocalPlayer = [localPlayer retain];
}

- (EGLoadBalancingMutablePlayer*) setLocalPlayer:(int)number :(NSDictionary*)properties
{
	return self.LocalPlayer = [self createMutablePlayer:number :properties];
}

- (void) readoutProperties:(NSMutableDictionary**)pRoomProperties :(NSMutableDictionary**)pPlayerProperties :(bool)multiplePlayers :(int)targetPlayerNr
{
	if(pRoomProperties && *pRoomProperties)
	{
		[mCurrentlyJoinedRoom cacheProperties:*pRoomProperties];
		*pRoomProperties = [EGLoadBalancingPeer stripKeysWithNullValues:[EGLoadBalancingPeer stripToCustomProperties:*pRoomProperties]];
	}

	if(pPlayerProperties && *pPlayerProperties && (*pPlayerProperties).count)
	{
		EGArray* players = multiplePlayers?[EGArray arrayWithArray:[*pPlayerProperties allValues]]:nil;
		EGArray* playerNrs = multiplePlayers?[EGArray arrayWithArray:[*pPlayerProperties allKeys]]:nil;
		for(int i=0; i<(multiplePlayers?(*pPlayerProperties).count:1); ++i)
		{
			NSDictionary* props = multiplePlayers?[players objectAtIndex:i]:*pPlayerProperties;
			for(int j=0; j<mCurrentlyJoinedRoom.Players.count; ++j)
			{
				int tmp;
				if(multiplePlayers)
					[[playerNrs objectAtIndex:i] getValue:&tmp];
				else
					tmp = targetPlayerNr;
				if(((EGLoadBalancingPlayer*)[mCurrentlyJoinedRoom.Players objectAtIndex:j]).Number == tmp)
					[(EGLoadBalancingPlayer*)[mCurrentlyJoinedRoom.Players objectAtIndex:j] cacheProperties:props];
			}
		}

		if(multiplePlayers)
		{
			for(NSUInteger i=0; i<(*pPlayerProperties).count; ++i)
			{
				id key = [[*pPlayerProperties allKeys] objectAtIndex:i];
				[*pPlayerProperties setObject:[EGLoadBalancingPeer stripKeysWithNullValues:[EGLoadBalancingPeer stripToCustomProperties:[*pPlayerProperties objectForKey:key]]] forKey:key];
			}
		}
		else
			*pPlayerProperties = [EGLoadBalancingPeer stripKeysWithNullValues:[EGLoadBalancingPeer stripToCustomProperties:*pPlayerProperties]];
	}
}

- (void) handleConnectionFlowError:(int)oldState :(int)errorCode :(NSString* const)errorString
{
	if(oldState == PeerStates::ConnectedToGameserver || oldState == PeerStates::AuthenticatedOnGameServer || oldState == PeerStates::Joining)
	{
		mCachedErrorCodeFromGameServer = errorCode;
		[mCachedErrorStringFromGameServer release];
		mCachedErrorStringFromGameServer = [errorString retain];
		mState = PeerStates::DisconnectingFromGameserver;
		[mPeer disconnect];
		// response to app has to wait until back on master
	}
	else
	{
		mState = PeerStates::Disconnecting;
		[mPeer disconnect];
		[mListener connectReturn:errorCode :errorString];
	}
}

- (void) onConnectToMasterFinished:(bool)comingFromGameserver
{
	if(comingFromGameserver)
	{
		if(mCachedErrorCodeFromGameServer)
		{
			switch(mLastJoinType)
			{
				case JoinType::CREATE_ROOM:
					[mListener createRoomReturn:0 :nil :nil :mCachedErrorCodeFromGameServer :mCachedErrorStringFromGameServer];
					break;
				case JoinType::JOIN_ROOM:
					[mListener joinRoomReturn:0 :nil :nil :mCachedErrorCodeFromGameServer :mCachedErrorStringFromGameServer];
					break;
				case JoinType::JOIN_RANDOM_ROOM:
					[mListener joinRandomRoomReturn:0 :nil :nil :mCachedErrorCodeFromGameServer :mCachedErrorStringFromGameServer];
					break;
				default:
					EGLOG(ERRORS, L"unexpected cached join type value");
					break;
			}
			mCachedErrorCodeFromGameServer = LoadBalancing::ErrorCode::OK;
			[mCachedErrorStringFromGameServer release];
			mCachedErrorStringFromGameServer = nil;
		}
		else
			[mListener leaveRoomReturn:0 :nil];
	}
	else
		[mListener connectReturn:0 :nil];
}

@end