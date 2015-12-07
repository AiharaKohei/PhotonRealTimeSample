/* Exit Games Photon - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#include "Photon-cpp/inc/OperationResponse.h"
#import "Photon-objc/inc/EGOperationResponse.h"

@interface EGOperationResponse ()

- (EGOperationResponse*) initWithCppOperationResponse:(const ExitGames::Photon::OperationResponse&)operationResponse NS_DESIGNATED_INITIALIZER;
+ (EGOperationResponse*) operationResponseWithCppOperationResponse:(const ExitGames::Photon::OperationResponse&)operationResponse;

@end