/* Exit Games Photon LoadBalancing - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import <Foundation/NSData.h>
#include "Common-cpp/inc/defines.h"
#import "Common-objc/inc/EGBase.h"

@interface EGAuthenticationValues : EGBase

@property (readonly) nByte Type;
@property (readonly) NSString* Parameters;
@property (readonly) NSData* Data;
@property (readonly, copy) NSString* Secret;

- (instancetype) initWithType:(nByte)type;
- (instancetype) initWithTypeAndParameters:(nByte)type :(NSString*)parameters;
- (instancetype) initWithTypeParametersAndData:(nByte)type :(NSString*)parameters :(NSData*)data NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithData:(const NSData*)data NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithUsernameAndToken:(NSString*)username :(NSString*)token;
- (instancetype) initWithUsernameTokenAndData:(NSString*)username :(NSString*)token :(const NSData*)data NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithParameters:(NSString*)parameters;
- (instancetype) initWithParametersAndData:(NSString*)parameters :(NSData*)data NS_DESIGNATED_INITIALIZER;
+ (instancetype) authenticationValues;
+ (instancetype) authenticationValuesWithType:(nByte)type;
+ (instancetype) authenticationValuesWithTypeAndParameters:(nByte)type :(NSString*)parameters;
+ (instancetype) authenticationValuesWithTypeParametersAndData:(nByte)type :(NSString*)parameters :(NSData*)data;
+ (instancetype) authenticationValuesWithData:(const NSData*)data;
+ (instancetype) authenticationValuesWithUsernameAndToken:(NSString*)username :(NSString*)token;
+ (instancetype) authenticationValuesWithUsernameTokenAndData:(NSString*)username :(NSString*)token :(const NSData*)data;
+ (instancetype) authenticationValuesWithParameters:(NSString*)parameters;
+ (instancetype) authenticationValuesWithParametersAndData:(NSString*)parameters :(NSData*)data;

@end