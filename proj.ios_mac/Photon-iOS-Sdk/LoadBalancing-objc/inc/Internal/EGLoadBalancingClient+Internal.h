/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "LoadBalancing-objc/inc/EGLoadBalancingClient.h"

@interface EGLoadBalancingClient ()

- (bool) opSetPropertiesOfPlayer:(int)playerNr :(NSDictionary*)properties;
- (bool) opSetPropertiesOfRoom:(NSDictionary*)properties;
- (bool) opSetPropertiesOfRoom:(NSDictionary*)properties :(bool)webForward;

@end