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
		return YES;
	}
	return NO;
}

@end
