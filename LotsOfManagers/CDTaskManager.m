//
//  CDTaskManager.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTaskManager.h"

@interface CDTaskManager ()

@property(nonatomic, strong) NSMutableDictionary *family2task2operation;

@end

@implementation CDTaskManager
{
    NSMutableDictionary* _family2operationqueue;
}


+ (id) instance
{
    static CDTaskManager* __sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CDTaskManager alloc] init];
    });
    return __sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
		_family2task2operation    = [NSMutableDictionary dictionary];
        _family2operationqueue    = [NSMutableDictionary dictionary];
    }
    return self;
}


-(void)addTask:(CDTask *)task {
    NSOperationQueue* familyQueue;
    @synchronized(_family2operationqueue)
    {
        familyQueue = _family2operationqueue[task.taskFamily];
        if (!familyQueue)
        {
            NSLog(@"Initially creating new OperationQueue for task family %@", task.taskFamily);
            familyQueue = [[NSOperationQueue alloc] init];
            familyQueue.maxConcurrentOperationCount = 1;
            _family2operationqueue[task.taskFamily] = familyQueue;
        }
    }
    
	@synchronized(_family2task2operation)
    {
        NSMutableDictionary* task2op = _family2task2operation[task.taskFamily];
        if (! task2op)
        {
            task2op = [NSMutableDictionary dictionary];
			_family2task2operation[task.taskFamily] = task2op;
        }
        
        if (task2op[task])
        {
            NSLog(@"Discarding task with id %@, because one is already queued", task.taskId);
            return;
        }
        task.delegate = self; //used to inform the task manager when the task is done with its job.
        
        NSBlockOperation* operation = [[NSBlockOperation alloc] init];
        [operation addExecutionBlock:^{
            NSLog(@"task executing : %@", task.taskId);
            [task execute];
        }];
        task2op[task] = operation;
        [familyQueue addOperation:operation];
    }
}

-(void)cancelTasks:(id<NSFastEnumeration>)collection
{
	for (CDTask* task in collection)
	{
		[self cancelTask:task];
	}
}

-(void)cancelTask:(CDTask*)task
{
	@synchronized(_family2task2operation)
    {
        NSDictionary* task2operation = _family2task2operation[task.taskFamily];
        NSOperation* op = task2operation[task];
        
        if (!op)
        {
//            NSLog(@"Cannot cancel task id %@, because there is no operation known for it", task.taskId);
            return;
        }
        [task cancel];
        [self removeTask:task];
    }
}



#pragma mark -
#pragma mark CDTaskDelegate

-(void)cdTaskDidFinish:(CDTask*)task {
	[self removeTask:task];
}


-(void)removeTask:(CDTask*)task {
    NSMutableDictionary* task2op = _family2task2operation[task.taskFamily];
    if (! task2op)
    {
//        NSLog(@"Cannot remove task id %@, because there is no operation known for it", task.taskId);
//		return;
    }

    @synchronized(task2op)
    {
        NSOperation* op = task2op[task];
        if (op)
        {
            [op cancel];
            [task2op removeObjectForKey:task];
            NSLog(@"task removed from queue : %@", task.taskId);
        }
    }
}


#pragma mark -
#pragma mark CommandResultDelegate

- (void) processCommandResult:(CDCommand *)command result:(id)result message:(NSString *)message {
	if (command.originatingTask.isCancelRequested) {
		//nothing to do
		NSLog(@"Result from taskId :%@ is ignored", command.originatingTask.taskId);
	}else {
		[command.originatingTask processCommandResult:command result:result message:message];
	}
}

- (void)processFailedResult:(CDCommand *)command result:(id)result message:(NSString *)message error:(NSError *)error
{
	if (command.originatingTask.isCancelRequested) {
		//nothing to do
		NSLog(@"Failure from taskId :%@ is ignored", command.originatingTask.taskId);
	}else {
		[command.originatingTask processFailedResult:command result:result message:message error:error];
	}
}

@end
