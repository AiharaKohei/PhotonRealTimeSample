/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "LoadBalancing-objc/inc/EGLoadBalancingPeer.h"

@interface EGLoadBalancingPeer ()

+ (NSMutableDictionary*) stripToCustomProperties:(NSDictionary*)properties;
+ (NSMutableDictionary*) stripKeysWithNullValues:(NSDictionary*)orig;
- (EGMutableDictionary*) opCreateRoomImplementation:(NSString*)gameID :(bool)isVisible :(bool)isOpen :(nByte)maxPlayers :(NSDictionary*)customRoomProperties :(NSDictionary*)customLocalPlayerProperties :(EGArray*)propsListedInLobby :(NSString*)lobbyName :(nByte)lobbyType :(int)playerTtl :(int)emptyRoomTtl;
- (EGMutableDictionary*) opJoinRoomImplementation:(NSString*)gameID :(NSDictionary*)customLocalPlayerProperties :(bool)createIfNotExists :(int)playerNumber :(int)cacheSliceIndex :(int)playerTtl :(int)emptyRoomTtl;

@end