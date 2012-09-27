//
//  CDTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTask.h"

@implementation CDTask


-(id)init
{
	if (self = [super init])
	{
		_doneCondition = [[NSCondition alloc] init];
	}
	return self;
}

-(void)execute {
	if (!self.cancelRequested)
	{
		NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>> TASK START [%@] %@ >>>>>>>>>>>>>>>>>>>>>>", self.taskFamily, self.taskId);
		[self.doneCondition lock];

		[self doYourThing];
		
		while (!_done) {
			NSLog(@">>> TASK WAITING FOR DONE CONDITION %@", self.taskId);
			[self.doneCondition wait];
		}
		[self.doneCondition unlock];
		NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<< TASK END   [%@] %@ <<<<<<<<<<<<<<<<<<<<<<", self.taskFamily, self.taskId);

	}
}

-(void)cancel {
	NSLog(@">>> TASK REQUESTED TO CANCEL %@", self.taskId);
	[self.doneCondition lock];
	self.cancelRequested = YES;

	[self cancelYourThing];
	
	_done = YES;
	[self.doneCondition signal];
	[self.doneCondition unlock];
	
}


-(void)doYourThing
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(void)cancelYourThing
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL)processYourThing:(CDCommand *)command result:(id)result message:(NSString *)message
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL)processYourFailure:(CDCommand *)command result:(id)result message:(NSString *)message error:(NSError*)error
{
//	@throw [NSException exceptionWithName:NSInternalInconsistencyException
//								   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
//										   NSStringFromSelector(_cmd)]
//								 userInfo:nil];
	return YES;
}


- (void) processCommandResult:(CDCommand *)command result:(id)result message:(NSString *)message {
	[self.doneCondition lock];
	
	if ([self processYourThing:command result:result message:message])
	{
		_done = YES;
		[self.doneCondition signal];
	}
	
	[self.doneCondition unlock];
}

- (void) processFailedResult:(CDCommand *)command result:(id)result message:(NSString *)message error:(NSError*)error {
	[self.doneCondition lock];
	
	if ([self processYourFailure:command result:result message:message error:error])
	{
		_done = YES;
		[self.doneCondition signal];
	}
	
	[self.doneCondition unlock];
}


-(id)copyWithZone:(NSZone *)zone
{
    CDTask* new_instance = [[[self class] allocWithZone:zone] init];
    new_instance->_cancelRequested = _cancelRequested;
    new_instance->_delegate = _delegate;
    new_instance->_taskId = _taskId;
    new_instance->_finished = _finished;
    new_instance->_taskFamily = _taskFamily;
	new_instance->_doneCondition = _doneCondition;

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
	return [self.taskId isEqualToString:o.taskId] && [self.taskFamily isEqualToString:o.taskFamily];
}

-(NSUInteger)hash
{
    return [self.taskId hash] * [self.taskFamily hash];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[CDTask: %@/%@]",self.taskFamily,self.taskId];
}


@end
