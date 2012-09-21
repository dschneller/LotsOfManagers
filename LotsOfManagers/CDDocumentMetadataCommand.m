//
//  CDDocumentMetadataCommand.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentMetadataCommand.h"
#import "CDDataRepository.h"

@implementation CDDocumentMetadataCommand

-(void)execute {
    [self callDataRepository];
}

-(void)didFinishWithResult:(id)result {
	self.finished = YES;
	NSMutableDictionary *documents = [[NSMutableDictionary alloc] init];
    [documents setValue:[NSNumber numberWithInteger:self.range.location] forKey:@"range"];
	[documents setValue:result forKey:@"documents"];
	[self.delegate processCommandResult:self result:documents message:@""];
}


-(void)callDataRepository {
    [NSThread sleepForTimeInterval:2.5f];
	NSRange offset = self.range;
	if(self.range.location + self.range.length > [[CDDataRepository instance].documents count]) {
		NSUInteger length = [[CDDataRepository instance].documents count] - self.range.location;
		 offset = NSMakeRange(self.range.location, length);
	}
	self.range = offset;
	[self didFinishWithResult:[[CDDataRepository instance].documents subarrayWithRange:offset]];
}



@end
