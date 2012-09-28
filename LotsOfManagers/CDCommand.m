//
//  CDCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDCommand.h"
#import "CDConfiguration.h"
#import "CDDocument.h"
#import "CDDocumentSearchResult.h"
#define ACCESS_TOKEN_HARD_CODED @"8e962e00-f7ec-488c-b924-ed04ed4ae242"

@implementation CDCommand

-(void)execute {

}

-(void)didFinishWithResult:(id)result {
	//nothing to do
}


-(void)cancel {
	//abstract method
}


- (void)requestWillPrepareForSend:(RKRequest *)request
{
	NSString* allAcceptedTypes = [[self getAcceptedContentTypes] componentsJoinedByString:@", "];
	request.additionalHTTPHeaders = @{ WS_ACCEPT : allAcceptedTypes };
}


+(RKObjectManager *) sharedObjectManagerInstance {
	
	static RKObjectManager* __sharedInstance;
	static dispatch_once_t onceToken;
	@synchronized (self) {
			if (__sharedInstance == nil) {
		dispatch_once(&onceToken, ^{
#if DEBUG
		//				RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
//			            RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
#endif
			__sharedInstance = [RKObjectManager managerWithBaseURLString:[CDConfiguration sharedConfig].webServiceURL];
			__sharedInstance.client.cachePolicy = RKRequestCachePolicyNone;
			__sharedInstance.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
			__sharedInstance.client.requestQueue = [RKRequestQueue newRequestQueueWithName:@"CDRQ"];
			__sharedInstance.client.requestQueue.concurrentRequestsLimit = 1;
			__sharedInstance.client.authenticationType = RKRequestAuthenticationTypeOAuth2;
	#warning get the real access token and set it as define value
			__sharedInstance.client.OAuth2AccessToken = ACCESS_TOKEN_HARD_CODED;
			[__sharedInstance.mappingProvider addObjectMapping:[self cdDocumentSearchResultMapping]];
		});
		}
	}
    return __sharedInstance;
}


+(void) setAuthorization {
	RKClient *client = [CDCommand sharedObjectManagerInstance].client;
	client.authenticationType = RKRequestAuthenticationTypeOAuth2;
	client.OAuth2AccessToken = ACCESS_TOKEN_HARD_CODED;
	[CDCommand sharedObjectManagerInstance].client = client;
}


-(NSArray*) getAcceptedContentTypes
{
	return @[WS_APP_JSON];
}


#pragma mark - 
#pragma mark  RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	//nothing to do
}



#pragma mark - 
#pragma mark Mapping Rest to Model

+(RKObjectMapping *)cdDocumentMapping
{
	RKObjectMapping *cdDocumentMapping = [RKObjectMapping mappingForClass:[CDDocument class]];
	[cdDocumentMapping mapKeyPath:@"filename"     toAttribute:@"filename"];
	[cdDocumentMapping mapKeyPath:@"id"			  toAttribute:@"documentId"];
    [cdDocumentMapping mapKeyPath:@"author"       toAttribute:@"author"];
	return cdDocumentMapping;
}

+(RKObjectMapping *)cdDocumentSearchResultMapping {
	RKObjectMapping *cdDocumentSearchResultMapping = [RKObjectMapping mappingForClass:[CDDocumentSearchResult class]];
	[cdDocumentSearchResultMapping mapKeyPath:@"hits" toAttribute:@"hits"];
	[cdDocumentSearchResultMapping mapKeyPath:@"documents" toRelationship:@"documents" withMapping:[self cdDocumentMapping]];
	return cdDocumentSearchResultMapping;
}


@end
