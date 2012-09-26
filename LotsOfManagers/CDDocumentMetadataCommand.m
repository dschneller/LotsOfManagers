//
//  CDDocumentMetadataCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentMetadataCommand.h"
#import "CDDataRepository.h"
#import "CDDocument.h"
#import "CDDocumentSearchResult.h"

@implementation CDDocumentMetadataCommand

-(void)execute {
	[super execute];
	// URL Query Parameters
	NSLog(@"offset : %d --- rows : %d", self.range.location, self.range.length);
	NSDictionary* queryParams = @{@"q": @"",
								  @"rows" : @(self.range.length),
								  @"offset" : @(self.range.location),
								  @"data" : @"id, filename, author"};
	
	RKObjectManager *_objectManager = [CDCommand sharedObjectManagerInstance];
	
	// Final Query URL
	RKURL* url = [RKURL URLWithBaseURL:_objectManager.baseURL
						  resourcePath:kWSPathDocuments
					   queryParameters:queryParams];
	

	NSString* resourcePath = [NSString stringWithFormat:@"%@?%@", url.resourcePath, url.query];

	[_objectManager loadObjectsAtResourcePath:resourcePath
								   usingBlock:^(RKObjectLoader *loader) {
									   loader.delegate = self;
									   loader.objectMapping = [[CDCommand sharedObjectManagerInstance].mappingProvider objectMappingForClass:[CDDocumentSearchResult class]];
									   loader.targetObject = [[CDDocumentSearchResult alloc] init];
								   }];
}

-(void)cancel {
	//TODO:
	
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

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
	CDDocumentSearchResult* searchResult = (CDDocumentSearchResult*)object;
	NSDictionary *result = @{
	@"range" : @(self.range.location),
	@"hits"  : searchResult.hits,
	@"documents" : searchResult.documents
	};
	
	self.finished = YES;
	[self.delegate processCommandResult:self result:result message:@""];
}
	


- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error{
	[super objectLoader:objectLoader didFailWithError:error];
	NSLog(@"Object loader failed to load the collection due to an error: %@ userInfo: %@", error, [error userInfo]);
}


@end
