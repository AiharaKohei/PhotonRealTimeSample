/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>
#import "Common-objc/inc/EGBase.h"

@class EGLoadBalancingClient;
@class EGLoadBalancingMutableRoom;

@interface EGLoadBalancingPlayer : EGBase

@property (readonly) int Number;
@property (readonly, copy) NSString* Name;
@property (readonly, copy) NSDictionary* CustomProperties;
@property (readonly) bool IsInactive;

- (instancetype) init NS_UNAVAILABLE;
+ (instancetype) new NS_UNAVAILABLE;
-(NSString*) toString:(bool)withTypes :(bool)withCustomProperties;

@end



@interface EGLoadBalancingMutablePlayer : EGLoadBalancingPlayer
{
@private
	EGLoadBalancingClient* mLoadBalancingClient;
}

@property (readwrite, copy) NSString* Name;
@property (readonly) bool IsMasterClient;

- (void) mergeCustomProperties:(NSDictionary*)customProperties;
- (void) addCustomProperty:(NSString*)key :(id)value;
- (void) addCustomProperties:(NSDictionary*)customProperties;
- (void) removeCustomProperty:(NSString*)key;
- (void) removeCustomProperties:(NSString**)keys :(NSUInteger)count;

@end