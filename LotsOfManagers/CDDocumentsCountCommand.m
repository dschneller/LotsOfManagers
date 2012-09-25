//
//  CDDocumentsCountCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsCountCommand.h"
#import "CDDataRepository.h"
#import "CDDocumentsCount.h"

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
	

	[_objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@&offset=%d&rows=%d&data=id", url.resourcePath, url.query, 0, 1] usingBlock:^(RKObjectLoader *loader) {
		loader.targetObject = [[CDDocumentsCount alloc] init];
		loader.objectMapping = [[_objectManager mappingProvider] objectMappingForClass:[CDDocumentsCount class]];
		loader.delegate = self;
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

#pragma mark -
#pragma mark -


-(void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
	CDDocumentsCount *dcObject = [objects objectAtIndex:0];
	NSLog(@"hits : %@", dcObject.hits);
	[self didFinishWithResult:dcObject];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error{
    [super objectLoader:objectLoader didFailWithError:error];
	NSLog(@"Object loader failed to load the collection due to an error: %@ userInfo: %@", error, [error userInfo]);
}

-(void)didFinishWithResult:(id)result {
	self.finished = YES;
	[self.delegate processCommandResult:self result:result message:@""];
}


#pragma mark -
#pragma mark Call simuleted Rest

-(void)callDataRepository {
    [NSThread sleepForTimeInterval:0.5f];
	_count = @([[CDDataRepository instance].documents count]);
	[self didFinishWithResult:_count];
}

@end
