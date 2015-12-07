/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "LoadBalancing-objc/inc/EGLoadBalancingRoom.h"

@interface EGLoadBalancingRoom ()

- (instancetype) initLoadBalancingRoom:(NSString*)name :(NSDictionary*)properties;
+ (instancetype) loadBalancingRoom:(NSString*)name :(NSDictionary*)properties;

@end



@interface EGLoadBalancingMutableRoom ()

- (instancetype) initLoadBalancingRoom:(NSString*)name :(NSDictionary*)properties NS_UNAVAILABLE;
+ (instancetype) loadBalancingRoom:(NSString*)name :(NSDictionary*)properties NS_UNAVAILABLE;
- (instancetype) initLoadBalancingRoom:(NSString*)name :(NSDictionary*)properties :(EGLoadBalancingClient*)client :(EGArray*)propsListedInLobby :(int)playerTtl :(int)emptyRoomTtl NS_DESIGNATED_INITIALIZER;
+ (instancetype) loadBalancingRoom:(NSString*)name :(NSDictionary*)properties :(EGLoadBalancingClient*)client :(EGArray*)propsListedInLobby :(int)playerTtl :(int)emptyRoomTtl;
- (EGLoadBalancingPlayer*) createPlayer:(int)number :(NSDictionary*)properties;

@end