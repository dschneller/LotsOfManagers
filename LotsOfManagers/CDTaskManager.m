//
//  CDTaskManager.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTaskManager.h"

@interface CDTaskManager ()

@property(nonatomic, strong) NSMutableDictionary *operationForTasksPerFamily;

@end

@implementation CDTaskManager
{
    NSMutableDictionary* _operationQueuesPerFamily;
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
		_operationForTasksPerFamily = [NSMutableDictionary dictionary];
        _operationQueuesPerFamily = [NSMutableDictionary dictionary];
    }
    return self;
}


-(void)addTask:(CDTask *)task {
    NSOperationQueue* familyQueue;
    @synchronized(_operationQueuesPerFamily)
    {
        familyQueue = _operationQueuesPerFamily[task.taskFamily];
        if (!familyQueue)
        {
            NSLog(@"Initially creating new OperationQueue for task family %@", task.taskFamily);
            familyQueue = [[NSOperationQueue alloc] init];
            familyQueue.maxConcurrentOperationCount = 1;
            _operationQueuesPerFamily[task.taskFamily] = familyQueue;
        }
    }
    
	@synchronized(_operationForTasksPerFamily)
    {
        NSMutableDictionary* operationsPerTask = _operationForTasksPerFamily[task.taskFamily];
        if (! operationsPerTask)
        {
            operationsPerTask = [NSMutableDictionary dictionary];
        }
        
        if (operationsPerTask[task])
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
        operationsPerTask[task] = operation;
        [familyQueue addOperation:operation];
    }
}

-(void)cancelTask:(CDTask*)task
{
    NSMutableDictionary* operationsPerTask = _operationQueuesPerFamily[task.taskFamily];
    if (! operationsPerTask)
    {
        NSLog(@"Cannot cancel task id %@, because there is no operation known for it", task.taskId);
    }

	@synchronized(operationsPerTask)
    {
        NSOperation* op = operationsPerTask[task];
        if (!op)
        {
            NSLog(@"Cannot cancel task id %@, because there is no operation known for it", task.taskId);
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
    NSMutableDictionary* operationsPerTask = _operationForTasksPerFamily[task.taskFamily];
    if (! operationsPerTask)
    {
        NSLog(@"Cannot cancel task id %@, because there is no operation known for it", task.taskId);
    }

    @synchronized(operationsPerTask)
    {
        NSOperation* op = operationsPerTask[task];
        if (op)
        {
            [op cancel];
            [operationsPerTask removeObjectForKey:task];
            NSLog(@"task removed from queue : %@", task.taskId);
        }
    }
}


@end
