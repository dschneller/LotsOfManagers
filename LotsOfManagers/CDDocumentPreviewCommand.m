//
//  CDDocumentPreviewCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/25/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentPreviewCommand.h"
#import "CDPreview.h"

@implementation CDDocumentPreviewCommand

static NSString* kWSPathDocument = @"/document";

- (void) execute {
	RKObjectManager *objectManager = [CDCommand sharedObjectManagerInstance];

	// Perform a HTTP GET
    NSString* versionParam = (self.version > 0) ? versionParam = [NSString stringWithFormat:@";version=%d", self.version] : @"";
    NSUInteger waitTime = 20;
    [objectManager.client get:[NSString stringWithFormat:@"%@/%@;preview=%@;pages=%d%@?wait-for-generation=%d",
												kWSPathDocument, self.documentId, self.resolution, self.page, versionParam, waitTime]
									  delegate:self];
}


-(void)cancel {
	[[[RKClient sharedClient] requestQueue] cancelRequestsWithDelegate:self];	
}

-(NSArray*) getAcceptedContentTypes
{
	return @[WS_IMAGE_JPG, WS_IMAGE_PNG];
}


- (NSDictionary*) getAdditionalHttpHeaders
{
	return @{WS_ACCEPT: WS_IMAGE_PNG};
}

#pragma mark -
#pragma mark RKObjectLoaderDelegate

- (void)request:(RKRequest *)request didLoadResponse:(RKResponse *)response
{
	if ([response isOK]) { //200

		if ([response.MIMEType isEqualToString:WS_IMAGE_PNG])
        {
			if ([CDPreview savePNGData:response.body
							forDocument:self.documentId
								version:self.version
								   page:self.page
						 withResolution:self.resolution])
			{
				UIImage *image = [UIImage imageWithData:response.body];
				[self.delegate processCommandResult:self result:image message:@""];
			}
			else
			{
				NSLog(@"Did not schedule preview UI update for document %@, because CDPreview returned NO from savePNGData:forDocument", self.documentId);
			}
        }
		
	}
    else if ([response isNoContent])
    {
        // preview is not done (yet) for this document. This is expected an ok, next refresh might be luckier.
		[self.delegate processCommandResult:self result:nil message:@"No preview (yet)"];
    }
    else {
		NSLog(@"*****Process Unsuccessful response is missing*******");
//		[self.delegate processUnsuccessfulResponse:response request:request];
	}
}

@end
