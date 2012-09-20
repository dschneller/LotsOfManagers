//
//  CDTaskBuilder.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTaskBuilder.h"
#import "CDDocumentsCountTask.h"

@implementation CDTaskBuilder

+ (id) instance
{
    static CDTaskBuilder* __sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CDTaskBuilder alloc] init];
    });
    return __sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
		//custom initialization
    }
    return self;
}


-(CDTask *)createCountTask {
	CDDocumentsCountTask *task = [[CDDocumentsCountTask alloc] init];
	task.taskId = [NSString stringWithFormat:@"count.all"];
	//add command(s) to task
	return task;
}

@end
