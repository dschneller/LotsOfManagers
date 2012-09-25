//
//  CDDocumentsCountTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsCountTask.h"

@implementation CDDocumentsCountTask



-(void)doYourThing {
	[self.documentsCountCommand execute];
}

-(void)cancelYourThing {
	[self.documentsCountCommand cancel];
}


- (BOOL) processYourThing:(CDCommand*)command result:(id)result message:(NSString*)message
{
	if (command.isFinished) { // command finished notify with result
		NSNumber* hits = (NSNumber*)result;
		
		dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ELEMENT_COUNT_RETRIEVED_NOTIFICATION
                                                                object:hits
                                                              userInfo:nil];
        });
		[self.delegate cdTaskDidFinish:self]; //task is finished it should be removed from the queue
		return YES;
	}
	return NO;
}

@end
