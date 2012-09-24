//
//  CDConfiguration.h
//  CenterDevice
//
//  Created by Daniel Schneller on 25.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WS_CONFIG_URL_KEY @"serviceurl"
#define WS_CONFIG_HOST_KEY @"host"
#define WS_CONFIG_PORT_KEY @"port"
#define WS_CONFIG_PROTOCOL_KEY @"protocol"


#define WS_CONFIG_OAUTH_PROTOCOL @"oauth2-protocol"
#define WS_CONFIG_OAUTH_HOST @"oauth2-host"
#define WS_CONFIG_OAUTH_PORT @"oauth2-port"

#define WS_CONFIG_OAUTH_AUTH_URL @"oauth2-auth-url"
#define WS_CONFIG_OAUTH_TOKEN_URL @"oauth2-token-url"


@interface CDConfiguration : NSObject

@property (nonatomic, readonly) NSString* webServiceProtocol;
@property (nonatomic, readonly) NSString* webServiceHost;
@property (nonatomic, readonly) NSString* webServicePort;
@property (nonatomic, readonly) NSString* webServiceApiPath;
@property (nonatomic, readonly) NSString* webServiceURL;
@property (nonatomic, readonly) NSString* oauthTokenURL;
@property (nonatomic, readonly) NSString* oauthAuthURL;

+ (CDConfiguration*) sharedConfig;
- (id) objectForKey:(id)key;

@end
