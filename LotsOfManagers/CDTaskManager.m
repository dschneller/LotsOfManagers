//
//  CDTaskManager.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTaskManager.h"

@interface CDTaskManager ()

@property(nonatomic, strong, readwrite) NSMutableDictionary *allLightTasks;

@end

@implementation CDTaskManager
{
    NSOperationQueue* _lightOperationQueue;
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
		_allLightTasks = [NSMutableDictionary dictionary];
        _lightOperationQueue = [[NSOperationQueue alloc] init];
        _lightOperationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}


-(void)addTask:(CDTask *)task {
	@synchronized(_allLightTasks)
    {
        if ([_allLightTasks objectForKey:task])
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
        [_allLightTasks setObject:operation forKey:task];
        [_lightOperationQueue addOperation:operation];
    }
}

-(void)cancelTask:(CDTask*)task
{
	@synchronized(_allLightTasks)
    {
        NSOperation* op = [_allLightTasks objectForKey:task];
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
    @synchronized(_allLightTasks)
    {
        NSOperation* op = [_allLightTasks objectForKey:task];
        if (op)
        {
            [op cancel];
            [_allLightTasks removeObjectForKey:task];
            NSLog(@"task removed from queue : %@", task.taskId);
        }
    }
}


@end
