//
//  CDTaskManager.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTaskManager.h"

@interface CDTaskManager ()

@property(nonatomic, strong, readwrite) NSMutableArray *queuedTasks;

@end

@implementation CDTaskManager

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
		_queuedTasks = [NSMutableArray array];
    }
    return self;
}


-(void)addTask:(CDTask *)task {
	@synchronized(_queuedTasks)
    {
        if ([_queuedTasks containsObject:task])
        {
            NSLog(@"Discarding task with id %@, because one is already queued", task.taskId);
            return;
        }
		task.delegate = self; //used to inform the task manager when the task is done with its job.
        [_queuedTasks addObject:task];
		if (_queuedTasks.count == 1) {
			NSLog(@"task executing : %@", ((CDTask *)[_queuedTasks objectAtIndex:0]).taskId);
			[task execute];
		}
    }
}


-(void)removeTask {
	if ([_queuedTasks objectAtIndex:0] != nil) {
		NSLog(@"task removed from queue : %@", ((CDTask *)[_queuedTasks objectAtIndex:0]).taskId);
		[_queuedTasks removeObjectAtIndex:0];
	}
}



#pragma mark -
#pragma mark CDTaskDelegate

-(void)cdTaskDidFinished {
	[self removeTask];
	if (_queuedTasks.count > 0) {
		CDTask *task = [_queuedTasks objectAtIndex:0];
		[task execute];
		NSLog(@"task executing : %@", ((CDTask *)[_queuedTasks objectAtIndex:0]).taskId);
	}
}

@end
