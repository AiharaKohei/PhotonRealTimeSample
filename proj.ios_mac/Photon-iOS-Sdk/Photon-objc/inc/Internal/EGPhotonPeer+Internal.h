/* Exit Games Photon - objC Client Lib
 * Copyright (C) 2004-2015 by Exit Games GmbH. All rights reserved.
 * http://www.exitgames.com
 * mailto:developer@exitgames.com
 */

#pragma once

#import "Photon-objc/inc/EGPhotonPeer.h"

@interface EGPhotonPeer ()

@property (readonly) ExitGames::Photon::PhotonPeer* Implementation;
@property (readonly) id<EGPhotonListener> InternalListener;

- (instancetype) initWithPhotonListener:(id<EGPhotonListener>)listener :(nByte)connectionProtocol :(bool)useLitePeer NS_DESIGNATED_INITIALIZER;

@end