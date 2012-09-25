//
//  CDDocumentsCountCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsCountCommand.h"
#import "CDDataRepository.h"

@implementation CDDocumentsCountCommand


-(void)execute {
    [self callDataRepository];
}

-(void)didFinishWithResult:(id)result {
	self.finished = YES;
	[self.delegate processCommandResult:self result:result message:@""];
}


-(void)callDataRepository {
    [NSThread sleepForTimeInterval:0.5f];
	_count = @([[CDDataRepository instance].documents count]);
	[self didFinishWithResult:_count];
}

@end
