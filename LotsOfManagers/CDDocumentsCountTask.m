//
//  CDDocumentsCountTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsCountTask.h"


@implementation CDDocumentsCountTask


-(void)execute {
	[self.documentsCountCommand execute];
}

-(void)cancel {
	[self.documentsCountCommand cancel];
}

- (void) processCommandResult:(CDCommand *)command result:(id)result message:(NSString *)message {
	if (command.isFinished) { // command finished notify with result
		[self.delegate cdTaskDidFinished]; //task is finished it should be removed from the queue
		[[NSNotificationCenter defaultCenter] postNotificationName:ELEMENT_COUNT_RETRIEVED_NOTIFICATION object:((CDDocumentsCountCommand *)command).count userInfo:nil];
	}
}

@end
