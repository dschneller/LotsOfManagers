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
	
	[_objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@", url.resourcePath, url.query]
									 delegate:self];
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
	
#pragma mark -
#pragma mark -
	
	
-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
//	NSLog(@"objects : %@", objects);
//	for (CDDocument *doc in objects) {
//		NSLog(@"doc id : %@", doc);
//	}
	[self didFinishWithResult:objects];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error{
	[super objectLoader:objectLoader didFailWithError:error];
	NSLog(@"Object loader failed to load the collection due to an error: %@ userInfo: %@", error, [error userInfo]);
}

-(void)didFinishWithResult:(id)result {
	self.finished = YES;
	NSMutableDictionary *documents = [[NSMutableDictionary alloc] init];
    [documents setValue:[NSNumber numberWithInteger:self.range.location] forKey:@"range"];
	[documents setValue:result forKey:@"documents"];
	[self.delegate processCommandResult:self result:documents message:@""];
}


-(void)callDataRepository {
    [NSThread sleepForTimeInterval:2.5f];
	NSRange offset = self.range;
	if(self.range.location + self.range.length > [[CDDataRepository instance].documents count]) {
		NSUInteger length = [[CDDataRepository instance].documents count] - self.range.location;
		 offset = NSMakeRange(self.range.location, length);
	}
	self.range = offset;
	[self didFinishWithResult:[[CDDataRepository instance].documents subarrayWithRange:offset]];
}



@end
