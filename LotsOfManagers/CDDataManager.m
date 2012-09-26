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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePreviewLoaded:)
													 name:TASK_PREVIEW_LOADED_NOTIFICATION
												   object:nil];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Retrieve data

- (CDTask*)retrieveElementCount {
	// create task, add task to task manager
	CDTask *task = [[CDTaskBuilder instance] createCountTask];
	[[CDTaskManager instance] addTask:task];
    return task;
}

- (CDTask*)retrieveDocumentsInRange:(NSRange)range {
	// create task, add task to task manager
	CDTask *task = [[CDTaskBuilder instance] createDocumentsMetadataTaskInRange:range];
	[[CDTaskManager instance] addTask:task];
    return task;
}

- (CDTask*)retrievePreviewForDocument:(CDDocument*)doc page:(NSUInteger)page resolution:(NSString*)res version:(NSUInteger)version
{
	CDTask *task = [[CDTaskBuilder instance] createPreviewTaskForDocument:doc page:page resolution:res version:version];
	[[CDTaskManager instance] addTask:task];
	return task;
}

- (void)handlePreviewLoaded:(NSNotification*)notification
{
	UIImage* image = notification.object;
	
	NSLog(@"Data manager was informed about preview being available for document id %@", notification.userInfo[@"documentId"]);
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:DATAMGR_PREVIEW_LOADED_NOTIFICATION object:image userInfo:notification.userInfo];
	});
}

- (void)cancelTask:(CDTask*)task
{
    [[CDTaskManager instance] cancelTask:task];
}


- (void)cancelTasks:(id<NSFastEnumeration>)collectionOfTasks {
	for (CDTask *task in collectionOfTasks) {
		[self cancelTask:task];
	}
}

@end
