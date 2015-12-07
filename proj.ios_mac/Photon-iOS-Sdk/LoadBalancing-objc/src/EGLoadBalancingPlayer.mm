/* Exit Games Photon LoadBalancing - objC Client Lib
* Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
* http://www.exitgames.com
* mailto:developer@exitgames.com
*/

#import <Foundation/NSException.h>
#include "Common-cpp/inc/Common.h"
#import "LoadBalancing-objc/inc/EGLoadBalancingRoom.h"
#import "LoadBalancing-objc/inc/Internal/EGLoadBalancingPeer+Internal.h"
#import "LoadBalancing-objc/inc/Internal/EGLoadBalancingPlayer+Internal.h"
#import "LoadBalancing-objc/inc/Protected/EGLoadBalancingPlayer+Protected.h"

/** @file EGLoadBalancingPlayer.h */

using namespace ExitGames::LoadBalancing;
using namespace ExitGames::LoadBalancing::Internal;

@interface EGLoadBalancingPlayer ()

- (NSString*) payloadToString:(bool)withTypes :(bool)withCustomProperties;

@end



@implementation EGLoadBalancingPlayer
{
@protected
	int mNumber;
	NSMutableString* mName;
	NSMutableDictionary* mCustomProperties;
	bool mIsInactive;
	const EGLoadBalancingMutableRoom* mRoom;
}

@synthesize Number = mNumber;

- (NSString*) Name
{
	return [[mName copy] autorelease];
}

- (NSDictionary*) CustomProperties
{
	return [[mCustomProperties copyDeep] autorelease];
}

- (bool) IsInactive
{
	return mIsInactive;
}



- (instancetype) init
{
	EG_ASSERT(false, @"not implemented");
	return nil;
}

- (instancetype) initLoadBalancingPlayer:(int)number :(NSDictionary*)properties :(const EGLoadBalancingMutableRoom* const)room
{
	self = [super init];
	mNumber = number;
	mRoom = room;
	mCustomProperties = [NSMutableDictionary new];
	return [self cacheProperties:properties];
}

+ (instancetype) new
{
	EG_ASSERT(false, @"not implemented");
	return nil;
}

+ (instancetype) loadBalancingPlayer:(int)number :(NSDictionary*)properties :(const EGLoadBalancingMutableRoom* const)room
{
	return [[[self alloc] initLoadBalancingPlayer:number :properties :room] autorelease];
}

- (instancetype) cacheProperties:(NSDictionary*)properties
{
	if([properties objectForKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]])
	{
		[mName release];
		mName = [[properties objectForKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]] retain];
	}
	[mCustomProperties addEntriesFromDictionary:[EGLoadBalancingPeer stripToCustomProperties:properties]];
	mCustomProperties = [[EGLoadBalancingPeer stripKeysWithNullValues:[mCustomProperties autorelease]] retain];
	id isInactiveObj = [properties objectForKey:[NSValue value:&Properties::Player::IS_INACTIVE withObjCType:@encode(nByte)]];
	if(isInactiveObj)
		[isInactiveObj getValue:&mIsInactive];
	return self;
}

- (instancetype) setIsInactive:(bool)isInactive
{
	mIsInactive = isInactive;
	return self;
};

- (NSString*) toString:(bool)withTypes
{
	return [self toString:withTypes :false];
}

- (NSString*) toString:(bool)withTypes :(bool)withCustomProperties
{
	return [NSString stringWithFormat:@"%d={%@}", mNumber, [self payloadToString:withTypes :withCustomProperties]];
}

- (NSString*) payloadToString:(bool)withTypes :(bool)withCustomProperties
{
	NSString* res = [NSString stringWithFormat:@"name: %@", mName];
	if(withCustomProperties && mCustomProperties.count)
		res = [res stringByAppendingFormat:@", props: %@", [mCustomProperties toString:withTypes]];
	return res;
}

- (BOOL) isEqual:(id)object
{
	return [object isKindOfClass:[EGLoadBalancingPlayer class]] && self.Number == ((EGLoadBalancingPlayer*)object).Number;
}

- (NSUInteger)hash
{
	return self.Number;
}

- (void) dealloc
{
	[mCustomProperties release];
	[mName release];
	[super dealloc];
}

@end



@implementation EGLoadBalancingMutablePlayer

- (NSString*) Name
{
	return [[mName copy] autorelease];
}

- (void) setName:(NSMutableString*)name
{
	if(mName == name)
		return;
	[mName release];
	[mLoadBalancingClient opSetPropertiesOfPlayer:mNumber :[NSDictionary dictionaryWithObject:mName=[name copy] forKey:[NSValue value:&Properties::Player::PLAYERNAME withObjCType:@encode(nByte)]]];
}

- (bool) IsMasterClient
{
	return mRoom?mNumber==mRoom.MasterClientID:false;
}



- (instancetype) initLoadBalancingPlayer:(int)number :(NSDictionary*)properties :(const EGLoadBalancingMutableRoom* const)room
{
	EG_ASSERT(false, @"not implemented");
	return nil;
}

- (instancetype) initLoadBalancingPlayer:(int)number :(NSDictionary*)properties :(const EGLoadBalancingMutableRoom* const)room :(EGLoadBalancingClient*)client
{
	self = [super initLoadBalancingPlayer:number :properties: room];
	mLoadBalancingClient = client;
	return self;
}

+ (instancetype) loadBalancingPlayer:(int)number :(NSDictionary*)properties :(const EGLoadBalancingMutableRoom* const)room
{
	EG_ASSERT(false, @"not implemented");
	return nil;
}

+ (instancetype) loadBalancingPlayer:(int)number :(NSDictionary*)properties :(const EGLoadBalancingMutableRoom* const)room :(EGLoadBalancingClient*)client
{
	return [[[self alloc] initLoadBalancingPlayer:number :properties :room :client] autorelease];
}

- (void) mergeCustomProperties:(NSDictionary*)customProperties
{
	if(mCustomProperties == customProperties)
		return;
	NSDictionary* stripDict = [EGLoadBalancingPeer stripToCustomProperties:customProperties];
	if(!stripDict.count)
		return;
	NSDictionary* oldDict = [[mCustomProperties copyDeep] autorelease];
	[mCustomProperties addEntriesFromDictionary:stripDict];
	mCustomProperties = [[EGLoadBalancingPeer stripKeysWithNullValues:[mCustomProperties autorelease]] retain];
	if(![mCustomProperties isEqual:oldDict])
		[mLoadBalancingClient opSetPropertiesOfPlayer:mNumber :stripDict];	
}

- (void) addCustomProperty:(NSString*)key :(id)value
{
	[self addCustomProperties:[NSDictionary dictionaryWithObject:value forKey:key]];
}

- (void) addCustomProperties:(NSDictionary*)customProperties
{
	[self mergeCustomProperties:[EGLoadBalancingPeer stripKeysWithNullValues:customProperties]];
}

- (void) removeCustomProperty:(NSString*)key
{
	[self removeCustomProperties:&key :1];
}

- (void) removeCustomProperties:(NSString**)keys :(NSUInteger)count
{
	NSNull** vals = new NSNull*[count];
	for(NSUInteger i=0; i<count; i++)
		vals[i] = [NSNull null];
	[self mergeCustomProperties:[NSDictionary dictionaryWithObjects:vals forKeys:keys count:count]];
	delete[] vals;
}

- (void) cleanCustomProperties
{
	[mCustomProperties removeAllObjects];
}
@end