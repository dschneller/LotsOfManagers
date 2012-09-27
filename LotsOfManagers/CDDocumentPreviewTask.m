//
//  CDPreviewTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/25/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentPreviewTask.h"

@implementation CDDocumentPreviewTask

-(void)doYourThing
{
	[self.documentPreviewCommand execute];
}

-(void)cancelYourThing
{
	[self.documentPreviewCommand cancel];
}

-(BOOL)processYourThing:(CDCommand *)command result:(id)result message:(NSString *)message
{
	UIImage* image = (UIImage*)result;
	if (image)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:TASK_PREVIEW_LOADED_NOTIFICATION
															object:image
														  userInfo:@{@"preview-availability": @"available",
		 @"documentId" : self.documentPreviewCommand.documentId,
		 @"version" : @(self.documentPreviewCommand.version),
		 @"page" : @(self.documentPreviewCommand.page),
		 @"resolution" : self.documentPreviewCommand.resolution}];
	}
return YES;
}

-(BOOL)processYourFailure:(CDCommand *)command result:(id)result message:(NSString *)message error:(NSError *)error
{
#warning Handle failed preview request, e. g. notify UI in a special way, so it can display an error placejolder or something.
	NSLog(@"Preview request failed for documentId: %@. Message: %@", self.documentPreviewCommand.documentId, message);
	return YES;
}

@end
