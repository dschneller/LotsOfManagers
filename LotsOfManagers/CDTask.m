//
//  CDTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTask.h"

@implementation CDTask


-(void)execute {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

/** cancel task and all of its commands */
-(void)cancel {
	self.cancelRequested = YES;
}

-(id)copyWithZone:(NSZone *)zone
{
    CDTask* new_instance = [[[self class] allocWithZone:zone] init];
    new_instance->_cancelRequested = _cancelRequested;
    new_instance->_delegate = _delegate;
    new_instance->_taskId = _taskId;
    new_instance->_finished = _finished;

    return new_instance;
}

-(BOOL)isEqual:(id)other {
	if(self == other){
		return YES;
	}
	if(!other || ![other isKindOfClass:[self class]])
    {
        return NO;
    }
	CDTask *o = (CDTask *)other;
	return [self.taskId isEqualToString:o.taskId];
}

@end
