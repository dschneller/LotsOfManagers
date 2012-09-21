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
        _queuedTasks = [NSMutableArray arrayWithCapacity:10];
        
        NSMutableArray* preparedAllDocs = [NSMutableArray arrayWithCapacity:1000];
        NSMutableArray* preparedInboxDocs = [NSMutableArray arrayWithCapacity:200];
        for (int i=0; i<1000; i++)
        {
            CDDocument* doc = [[CDDocument alloc] init];
            doc.filename = [NSString stringWithFormat:@"Filename %d", i];
            doc.author = [NSString stringWithFormat:@"Author %d", i];
            doc.documentId = [NSString stringWithFormat:@"DocId %d", i];
            
            [preparedAllDocs addObject:doc];
            if (i % 5 == 0)
            {
                [preparedInboxDocs addObject:doc];
            }
        }
        
        _queryResultAllDocuments = [NSArray arrayWithArray:preparedAllDocs];
        _queryResultInboxOnly = [NSArray arrayWithArray:preparedInboxDocs];
    }
    return self;
}

- (void) retrieveElementCountForTaskId:(NSString*)taskId
{
    @synchronized(_queuedTasks)
    {
        if ([_queuedTasks containsObject:taskId])
        {
            NSLog(@"Discarding task with id %@, because one is already queued", taskId);
            return;
        }
        
        [_queuedTasks addObject:taskId];
    }
    
    
    [self performSelector:@selector(sendOutCountNotifications:) withObject:taskId afterDelay:0.5f];
}

- (void) sendOutCountNotifications:(NSString*)taskId
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:taskId forKey:@"taskId"];
    
    if ([@"count.all" isEqualToString:taskId])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ELEMENT_COUNT_RETRIEVED_NOTIFICATION
                                                            object:[NSNumber numberWithUnsignedInteger:_queryResultAllDocuments.count]
                                                          userInfo:userInfo];
    }
    else if ([@"count.inbox" isEqualToString:taskId])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ELEMENT_COUNT_RETRIEVED_NOTIFICATION
                                                            object:[NSNumber numberWithUnsignedInteger:_queryResultInboxOnly.count]
                                                          userInfo:userInfo];
    }
    [_queuedTasks removeObject:taskId];

}

- (void) retrieveDocumentsInRange:(NSRange)range forTaskId:(NSString*)taskId
{
    @synchronized(_queuedTasks)
    {
        if ([_queuedTasks containsObject:taskId])
        {
            NSLog(@"Discarding task with id %@, because one is already queued", taskId);
            return;
        }
        
        [_queuedTasks addObject:taskId];
    }
    
    [self performBlock:^{
        [self sendOutDocumentNotifications:range forTaskId:taskId];
    } afterDelay:2.5f];
    
}


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

- (void) sendOutDocumentNotifications:(NSRange)range forTaskId:(NSString*) taskId
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:taskId forKey:@"taskId"];
    [userInfo setValue:[NSNumber numberWithInteger:range.location] forKey:@"range"];
    
    if ([taskId hasPrefix:@"docs.all"])
    {
        if(range.location+range.length > _queryResultAllDocuments.count)range.length=_queryResultAllDocuments.count - range.location;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DOCUMENTS_RETRIEVED_NOTIFICATION
                                                            object:[_queryResultAllDocuments subarrayWithRange:range]
                                                          userInfo:userInfo];
    }
    else if ([@"docs.inbox" isEqualToString:taskId])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:DOCUMENTS_RETRIEVED_NOTIFICATION
                                                            object:[_queryResultInboxOnly subarrayWithRange:range]
                                                          userInfo:userInfo];
    }
    
    [_queuedTasks removeObject:taskId];
}




@end
