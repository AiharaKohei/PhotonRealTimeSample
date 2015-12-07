/* Exit Games Photon - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#include "Photon-cpp/inc/TrafficStats.h"
#import "Photon-objc/inc/EGTrafficStats.h"

@interface EGTrafficStats ()

- (instancetype) initWithCppTrafficStats:(const ExitGames::Photon::TrafficStats&)ts NS_DESIGNATED_INITIALIZER;
+ (instancetype) trafficStatsWithCppTrafficStats:(const ExitGames::Photon::TrafficStats&)ts;

@end