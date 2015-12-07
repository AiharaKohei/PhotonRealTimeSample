/* Exit Games Photon LoadBalancing - objC Client Lib
* Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
* http://www.exitgames.com
* mailto:developer@exitgames.com
*/

#include "LoadBalancing-cpp/inc/Enums/CustomAuthenticationType.h"
#import "LoadBalancing-objc/inc/Internal/EGAuthenticationValues+Internal.h"

/** @file EGAuthenticationValues.h */

using namespace ExitGames::LoadBalancing;

@implementation EGAuthenticationValues
{
@private
	nByte mType;
	NSString* mParameters;
	NSData* mData;
	NSString* mSecret;
}

@synthesize Type = mType;
@synthesize Parameters = mParameters;
@synthesize Data = mData;
@synthesize Secret = mSecret;



- (instancetype) init
{
	return [self initWithType:ExitGames::LoadBalancing::CustomAuthenticationType::NONE];
}

- (instancetype) initWithType:(nByte)type
{
	return [self initWithTypeAndParameters:type :@""];
}

- (instancetype) initWithTypeAndParameters:(nByte)type :(NSString*)parameters
{
	return [self initWithTypeParametersAndData:type :parameters :[NSData data]];
}

- (instancetype) initWithTypeParametersAndData:(nByte)type :(NSString*)parameters :(NSData*)data
{
	self = [super init];
	mType = type;
	mParameters = [parameters copy];
	mData = [data copy];
	return self;
}

- (instancetype) initWithData:(const NSData*)data
{
	self = [super init];
	mType = CustomAuthenticationType::CUSTOM;
	mData = [data copy];
	return self;
}

- (instancetype) initWithUsernameAndToken:(NSString*)username :(NSString*)token
{
	return [self initWithUsernameTokenAndData:username :token :[NSData data]];
}

- (instancetype) initWithUsernameTokenAndData:(NSString*)username :(NSString*)token :(const NSData*)data
{
	self = [super init];
	mType = CustomAuthenticationType::CUSTOM;
	mParameters = [[NSString alloc] initWithFormat:@"username=%@&token=%@", username, token];
	mData = [data copy];
	return self;
}

- (instancetype) initWithParameters:(NSString*)parameters
{
	return [self initWithParametersAndData:parameters :[NSData data]];
}

- (instancetype) initWithParametersAndData:(NSString*)parameters :(NSData*)data
{
	self = [super init];
	mType = CustomAuthenticationType::CUSTOM;
	mParameters = [parameters copy];
	mData = [data copy];
	return self;
}

+ (instancetype) authenticationValues
{
	return [[self new] autorelease];
}

+ (instancetype) authenticationValuesWithType:(nByte)type
{
	return [[[self alloc] initWithType:type] autorelease];
}

+ (instancetype) authenticationValuesWithTypeAndParameters:(nByte)type :(NSString*)parameters
{
	return [[[self alloc] initWithTypeAndParameters:type :parameters] autorelease];
}

+ (instancetype) authenticationValuesWithTypeParametersAndData:(nByte)type :(NSString*)parameters :(NSData*)data
{
	return [[[self alloc] initWithTypeParametersAndData:type :parameters :data] autorelease];
}

+ (instancetype) authenticationValuesWithData:(const NSData*)data
{
	return [[[self alloc] initWithData:data] autorelease];
}

+ (instancetype) authenticationValuesWithUsernameAndToken:(NSString*)username :(NSString*)token
{
	return [[[self alloc] initWithUsernameAndToken:username :token] autorelease];
}

+ (instancetype) authenticationValuesWithUsernameTokenAndData:(NSString*)username :(NSString*)token :(const NSData*)data
{
	return [[[self alloc] initWithUsernameTokenAndData:username :token :data] autorelease];
}

+ (instancetype) authenticationValuesWithParameters:(NSString*)parameters
{
	return [[[self alloc] initWithParameters:parameters] autorelease];
}

+ (instancetype) authenticationValuesWithParametersAndData:(NSString*)parameters :(NSData*)data
{
	return [[[self alloc] initWithParametersAndData:parameters :data] autorelease];
}

- (NSString*) toString:(bool)withTypes
{
	return [NSString stringWithFormat:@"{%d %@ %@ %@}", (int)self.Type, [self.Parameters toString:withTypes], [self.Data toString:withTypes], [self.Secret toString:withTypes]];
}

- (void) dealloc
{
	[mData release];
	[mParameters release];
	[super dealloc];
}

@end