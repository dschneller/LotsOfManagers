//
//  CDDocumentsMetadataTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsMetadataTask.h"

@implementation CDDocumentsMetadataTask

-(NSString *)description {
	return @"docs.all";
}


-(void)execute {
	[self.documentsMetadataCommand execute];
}

-(void)cancel {
	[self.documentsMetadataCommand cancel];
}

- (void) processCommandResult:(CDCommand *)command result:(id)result message:(NSString *)message {
	if (command.isFinished) { // command finished notify with result
		NSMutableDictionary *dict = (NSMutableDictionary *)result;
	    [dict setValue:self.taskId forKey:@"taskId"];
		[self.delegate cdTaskDidFinished]; //task is finished it should be removed from the queue
		[[NSNotificationCenter defaultCenter] postNotificationName:DOCUMENTS_RETRIEVED_NOTIFICATION object:dict userInfo:nil];
	}
}

@end
