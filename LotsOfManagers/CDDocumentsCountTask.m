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
		[[NSNotificationCenter defaultCenter] postNotificationName:@"documents.count.retrieved" object:((CDDocumentsCountCommand *)command).count userInfo:nil];
	}
}

@end
