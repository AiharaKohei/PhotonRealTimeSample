/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#include "LoadBalancing-cpp/inc/Internal/Enums/Properties/Player.h"
#import "LoadBalancing-objc/inc/EGLoadBalancingPlayer.h"

@interface EGLoadBalancingPlayer ()

- (instancetype) cacheProperties:(NSDictionary*)properties;
- (instancetype) setIsInactive:(bool)isInactive;

@end



@interface EGLoadBalancingMutablePlayer ()

- (void) cleanCustomProperties;

@end