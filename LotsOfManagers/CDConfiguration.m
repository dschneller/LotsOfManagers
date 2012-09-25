//
//  CDConfiguration.m
//  CenterDevice
//
//  Created by Daniel Schneller on 25.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDConfiguration.h"

#define WS_CONFIG_FILE @"WebServiceConfig-Mantest.plist"
#define WS_CONFIG_FILE_PROD @"WebServiceConfig-PROD.plist"

@interface CDConfiguration ()
@property (nonatomic, strong) NSDictionary* configValues;
@end

@implementation CDConfiguration
{
    NSString* _serverUrl;
    NSString* _oauthAuthUrl;
    NSString* _oauthAuthTokenUrl;
}

+ (CDConfiguration*)sharedConfig
{
    static CDConfiguration* __sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CDConfiguration alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:WS_CONFIG_FILE_PROD ofType:nil];
        __sharedInstance.configValues = [NSDictionary dictionaryWithContentsOfFile:path];
    });
    return __sharedInstance;
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id) objectForKey:(id)key
{
    return [self.configValues objectForKey:key];
}

- (NSString *)webServiceProtocol
{
    return [self.configValues objectForKey:WS_CONFIG_PROTOCOL_KEY];
}

- (NSString *)webServiceHost
{
    return [self.configValues objectForKey:WS_CONFIG_HOST_KEY];
}

- (NSString *)webServicePort
{
    return [self.configValues objectForKey:WS_CONFIG_PORT_KEY];
}

- (NSString *)webServiceApiPath
{
    return [self.configValues objectForKey:WS_CONFIG_URL_KEY];
}

- (NSString *)oauthAuthURL
{
    if (_oauthAuthUrl == nil)
    {
        NSString* proto = [self.configValues objectForKey:WS_CONFIG_OAUTH_PROTOCOL];
        NSString* host  = [self.configValues objectForKey:WS_CONFIG_OAUTH_HOST];
        NSString* port  = [self.configValues objectForKey:WS_CONFIG_OAUTH_PORT];
        NSString* path  = [self.configValues objectForKey:WS_CONFIG_OAUTH_AUTH_URL];
        _oauthAuthUrl = [NSString stringWithFormat:@"%@://%@:%@%@", proto, host, port, path];
    }
    return _oauthAuthUrl;
#if DEBUG
    NSLog(@"OAuth Authorization-URL is: %@", _oauthAuthUrl);
#endif
}

- (NSString *)oauthTokenURL
{
    if (_oauthAuthTokenUrl == nil)
    {
        NSString* proto = [self.configValues objectForKey:WS_CONFIG_OAUTH_PROTOCOL];
        NSString* host  = [self.configValues objectForKey:WS_CONFIG_OAUTH_HOST];
        NSString* port  = [self.configValues objectForKey:WS_CONFIG_OAUTH_PORT];
        NSString* path  = [self.configValues objectForKey:WS_CONFIG_OAUTH_TOKEN_URL];
        _oauthAuthTokenUrl = [NSString stringWithFormat:@"%@://%@:%@%@", proto, host, port, path];
#if DEBUG
        NSLog(@"OAuth Token-URL is: %@", _oauthAuthTokenUrl);
#endif
    }
    return _oauthAuthTokenUrl;
}

- (NSString *)webServiceURL
{
    if (_serverUrl == nil)
    {
        _serverUrl = [NSString stringWithFormat:@"%@://%@:%@%@", self.webServiceProtocol,
                      self.webServiceHost, self.webServicePort, self.webServiceApiPath];
#if DEBUG
        NSLog(@"REST URL is: %@", _serverUrl);
#endif
    }
    return _serverUrl;
}



@end
