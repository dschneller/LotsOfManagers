//
//  CDDocumentsCountTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsCountTask.h"
#import "CDDocumentsCount.h"

@implementation CDDocumentsCountTask


-(void)execute {
    if (!self.isCancelRequested)
    {
        NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> COUNT TASK RUNNING <<<<<<<<<<<<<<<<<<<<<<");        
        [self.documentsCountCommand execute];
    }
}

-(void)cancel {
    [super cancel];
	[self.documentsCountCommand cancel];
}

- (void) processCommandResult:(CDCommand *)command result:(id)result message:(NSString *)message {
	if (command.isFinished) { // command finished notify with result
		[self.delegate cdTaskDidFinish:self]; //task is finished it should be removed from the queue
		dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ELEMENT_COUNT_RETRIEVED_NOTIFICATION
                                                                object:((CDDocumentsCount *) result).hits
                                                              userInfo:nil];
        });
	}
}

@end
