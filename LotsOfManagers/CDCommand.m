//
//  CDCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDCommand.h"
#import "CDConfiguration.h"
#import "CDDocumentsCount.h"
#import "CDDocument.h"

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


+(RKObjectManager *) sharedObjectManagerInstance {
	
	static RKObjectManager* __sharedInstance;
	static dispatch_once_t onceToken;
	@synchronized (self) {
			if (__sharedInstance == nil) {
		dispatch_once(&onceToken, ^{
#if DEBUG
		//				RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
		//	            RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelDebug);
#endif
			__sharedInstance = [RKObjectManager managerWithBaseURLString:[CDConfiguration sharedConfig].webServiceURL];
			__sharedInstance.client.cachePolicy = RKRequestCachePolicyNone;
			__sharedInstance.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
			__sharedInstance.client.requestQueue = [RKRequestQueue newRequestQueueWithName:@"CDRQ"];
			__sharedInstance.client.requestQueue.concurrentRequestsLimit = 1;
			__sharedInstance.client.authenticationType = RKRequestAuthenticationTypeOAuth2;
	#warning get the real access token and set it as define value
			__sharedInstance.client.OAuth2AccessToken = ACCESS_TOKEN_HARD_CODED;
			[self setDocumentsCountMappping];
			[self setDocumentMetadataMapping];
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

+ (void)addAccept {
	[[CDCommand sharedObjectManagerInstance].client.HTTPHeaders setValue:WS_ALL_MEDIA_TYPE forKey:WS_ACCEPT];
}

#pragma mark - 
#pragma mark  RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
	//nothing to do
}


#pragma mark - 
#pragma mark Mapping Rest to Model

+(void)setDocumentsCountMappping {
	[[self sharedObjectManagerInstance].mappingProvider addObjectMapping:[self cdDocumentsCountMapping]];
}

+(void)setDocumentMetadataMapping {
	//[[self sharedObjectManagerInstance].mappingProvider addObjectMapping:[self cdDocumentMetadataMapping]];
	[[self sharedObjectManagerInstance].mappingProvider setMapping:[self cdDocumentMetadataMapping] forKeyPath:@"documents"];
	[[self sharedObjectManagerInstance].mappingProvider setMapping:[self cdDocumentsCountMapping] forKeyPath:@"hits"];

}


+(RKObjectMapping *)cdDocumentsCountMapping {
	RKObjectMapping *cdDocumentsCountMapping = [RKObjectMapping mappingForClass:[CDDocumentsCount class]];
	[cdDocumentsCountMapping mapKeyPath:kWSDocumentsCount   toAttribute:kDocumentsCount];
	[cdDocumentsCountMapping mapKeyPath:kWSDocuments toAttribute:kWSDocuments];
	return cdDocumentsCountMapping;
}


+(RKObjectMapping *)cdDocumentMetadataMapping {
	RKObjectMapping *cdDocumentMetadataMapping = [RKObjectMapping mappingForClass:[CDDocument class]];
	[cdDocumentMetadataMapping mapKeyPath:@"filename"     toAttribute:@"filename"];
	[cdDocumentMetadataMapping mapKeyPath:@"id"			  toAttribute:@"documentId"];
    [cdDocumentMetadataMapping mapKeyPath:@"author"       toAttribute:@"author"];
	return cdDocumentMetadataMapping;
}


@end
