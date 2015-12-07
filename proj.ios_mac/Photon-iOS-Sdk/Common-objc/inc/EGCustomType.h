/* Exit Games Common - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#include "Common-cpp/inc/defines.h"
#import "Common-objc/inc/EGToString.h"

@protocol EGCustomType <NSObject, EGToString>

@property (readonly) nByte TypeCode;

- (instancetype) initWithCustomType:(const id<EGCustomType>)toCopy;

- (void) cleanup;
- (bool) compare:(const id<EGCustomType>)other;
- (void) duplicate:(id<EGCustomType> const)retVal;
- (void) deserialize:(const nByte*)pData :(short)length;
- (short) serialize:(nByte*)retVal;

@end