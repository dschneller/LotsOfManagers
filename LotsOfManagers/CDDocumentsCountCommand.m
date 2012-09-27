//
//  CDDocumentsCountCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsCountCommand.h"
#import "CDDataRepository.h"
#import "CDDocumentSearchResult.h"

@implementation CDDocumentsCountCommand


-(void)execute {
	[super execute];
	// URL Query Parameters
    NSDictionary* queryParams = [NSDictionary dictionaryWithKeysAndObjects:@"q", @"",nil];
	RKObjectManager *_objectManager = [CDCommand sharedObjectManagerInstance];	
    // Final Query URL
    RKURL* url = [RKURL URLWithBaseURL:_objectManager.baseURL
                          resourcePath:kWSPathDocuments
                       queryParameters:queryParams];
	NSString* resourcePath = [NSString stringWithFormat:@"%@?%@&offset=%d&rows=%d&data=id", url.resourcePath, url.query, 0, 1];
	[_objectManager loadObjectsAtResourcePath:resourcePath
								   usingBlock:^(RKObjectLoader *loader) {
									   loader.delegate = self;
									   loader.objectMapping = [[CDCommand sharedObjectManagerInstance].mappingProvider objectMappingForClass:[CDDocumentSearchResult class]];

									   loader.targetObject = [[CDDocumentSearchResult alloc] init];
								   }];
}


-(void)cancel {
	[[[RKClient sharedClient] requestQueue] cancelRequestsWithDelegate:self];	
}


#pragma mark -
#pragma mark RKObjectLoaderDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	if ([response isSuccessful]) {
		//nothing to do
	}else {
		NSLog(@"Response is not successful : %@", response.bodyAsString);
	}
}


-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
	CDDocumentSearchResult* result = (CDDocumentSearchResult*)object;
	
	NSNumber* hits = result.hits;
	self.finished = YES;
	[self.delegate processCommandResult:self result:hits message:@""];
	
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error{
    [super objectLoader:objectLoader didFailWithError:error];
	NSLog(@"Object loader failed to load the collection due to an error: %@ userInfo: %@", error, [error userInfo]);
}

@end
