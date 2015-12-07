/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "Common-objc/inc/EGArray.h"
#import "LoadBalancing-objc/inc/EGLoadBalancingPlayer.h"

@interface EGLoadBalancingRoom : EGBase

@property (readonly, retain) NSString* Name;
@property (readonly) nByte PlayerCount;
@property (readonly) nByte MaxPlayers;
@property (readonly) bool IsOpen;
@property (readonly, copy) NSDictionary* CustomProperties;
@property (readonly) int PlayerTtl;
@property (readonly) int EmptyRoomTtl;

- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;
- (NSString*) toString:(bool)withTypes :(bool)withCustomProperties;

@end



@interface EGLoadBalancingMutableRoom : EGLoadBalancingRoom
{
@private
	EGLoadBalancingClient* mLoadBalancingClient;
	bool mIsVisible;
	EGMutableArray* mPlayers;
	int mMasterClientID;
	EGMutableArray* mPropsListedInLobby;
}

@property (readwrite) nByte MaxPlayers;
@property (readwrite) bool IsOpen;
@property (readwrite) bool IsVisible;
@property (readonly, copy) EGArray* Players;
@property (readonly) int MasterClientID;
@property (readwrite, copy) EGArray* PropsListedInLobby;
@property (readwrite, copy) EGArray* PropsListedInLobbyWithWebForward;
@property (readwrite) int PlayerTtl;
@property (readwrite) int EmptyRoomTtl;

- (EGLoadBalancingPlayer*) getPlayerForNumber:(int)playerNumber;
- (void) mergeCustomProperties:(NSDictionary*)customProperties; // = false
- (void) mergeCustomProperties:(NSDictionary*)customProperties :(bool)webForward;
- (void) addCustomProperty:(NSString*)key :(id)value; // = false
- (void) addCustomProperty:(NSString*)key :(id)value :(bool)webForward;
- (void) addCustomProperties:(NSDictionary*)customProperties; // = false
- (void) addCustomProperties:(NSDictionary*)customProperties :(bool)webForward;
- (void) removeCustomProperty:(NSString*)key; // = false
- (void) removeCustomProperty:(NSString*)key :(bool)webForward;
- (void) removeCustomProperties:(NSString**)keys :(NSUInteger)count; // = false
- (void) removeCustomProperties:(NSString**)keys :(NSUInteger)count :(bool)webForward;
- (NSString*) toString:(bool)withTypes :(bool)withCustomProperties :(bool)withPlayers;

@end