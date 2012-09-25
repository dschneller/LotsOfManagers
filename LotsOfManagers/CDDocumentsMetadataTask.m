//
//  CDDocumentsMetadataTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsMetadataTask.h"

@implementation CDDocumentsMetadataTask
{
	BOOL _done;
}


-(NSString *)description {
	return @"docs.all";
}


-(void)doYourThing {
	[self.documentsMetadataCommand execute];
}

-(void)cancelYourThing {
	[self.documentsMetadataCommand cancel];
}

-(BOOL)processYourThing:(CDCommand *)command result:(id)result message:(NSString *)message
{
	if (command.isFinished) { // command finished notify with result
		NSMutableDictionary *dict = (NSMutableDictionary *)result;
		dict[@"taskId"] = self.taskId;
		[self.delegate cdTaskDidFinish:self]; //task is finished it should be removed from the queue
        dispatch_async(dispatch_get_main_queue(), ^{
//			[[NSNotificationCenter defaultCenter] postNotificationName:ELEMENT_COUNT_RETRIEVED_NOTIFICATION object:<#(id)#>]
            [[NSNotificationCenter defaultCenter] postNotificationName:DOCUMENTS_RETRIEVED_NOTIFICATION object:dict userInfo:nil];
        });
		return YES;
	}
	return NO;
}


@end
