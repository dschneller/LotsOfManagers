//
//  CDDocumentsCountCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentsCountCommand.h"
//#import "CDDataRepository.h"

@implementation CDDocumentsCountCommand


-(void)execute {
    [self performBlock:^{
        [self callDataRepository];
    } afterDelay:2.5f];
}

-(void)didFinishWithResult:(id)result {
	self.finished = YES;
	[self.delegate processCommandResult:self result:result message:@""];
}


-(void)callDataRepository {
	//_count =
	[self didFinishWithResult:_count];
}

@end
