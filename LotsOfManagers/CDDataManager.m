//
//  CDDataManager.m
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDataManager.h"
#import "CDDocument.h"
#import "NSObject+PerformBlockAfterDelay.h"
#import "CDTaskBuilder.h"

@implementation CDDataManager
{
    NSArray* _queryResultAllDocuments;
    NSArray* _queryResultInboxOnly;
    
    NSMutableArray* _queuedTasks;
}

+ (id) instance
{
    static CDDataManager* __sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CDDataManager alloc] init];
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

#pragma mark - Retrieve data

- (void)retrieveElementCount {
	// create task, add task to task manager
	CDTask *task = [[CDTaskBuilder instance] createCountTask];
	[[CDTaskManager instance] addTask:task];
}

- (void)retrieveDocumentsInRange:(NSRange)range {
	// create task, add task to task manager
	CDTask *task = [[CDTaskBuilder instance] createDocumentsMetadataTaskInRange:range];
	[[CDTaskManager instance] addTask:task];
}


@end
