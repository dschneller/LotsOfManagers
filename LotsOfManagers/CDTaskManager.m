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
        
        [_queuedTasks addObject:task];
    }
}


-(void)removeTask {
	if ([_queuedTasks objectAtIndex:0] != nil) {
		[_queuedTasks removeObjectAtIndex:0];
	}
}

@end
