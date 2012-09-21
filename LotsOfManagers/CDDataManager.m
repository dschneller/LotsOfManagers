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

@implementation CDDataManager
{
    NSArray* _queryResultAllDocuments;
    NSArray* _queryResultInboxOnly;
    
    NSMutableDictionary* _queuedTasks;
    NSOperationQueue* _dataRetrievelAsyncOperationQueue;
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
        _dataRetrievelAsyncOperationQueue = [[NSOperationQueue alloc] init];
        _dataRetrievelAsyncOperationQueue.maxConcurrentOperationCount = 1;
        
        _queuedTasks = [NSMutableDictionary dictionaryWithCapacity:10];
        
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

- (void) cancelTaskIdWithPrefix:(NSString*)prefix
{
    NSLog(@"Cancelling tasks with prefix %@", prefix);
        @synchronized(_queuedTasks)
        {
            int oldLength = _queuedTasks.count;
            for (NSString* taskId in _queuedTasks.keyEnumerator)
            {
                if ([taskId hasPrefix:prefix])
                {
                    NSOperation* op = [_queuedTasks objectForKey:taskId];
                    [op cancel];
                    [_queuedTasks removeObjectForKey:taskId];
                }
            }
            int newLength = _queuedTasks.count;
            NSLog(@"Removed %d tasks", oldLength - newLength);
        }
    
}


- (void) retrieveElementCountForTaskId:(NSString*)taskId
{
        @synchronized(_queuedTasks)
        {
            if ([_queuedTasks objectForKey:taskId])
            {
                NSLog(@"Ignoring task with id %@, because one is already queued", taskId);
                return;
            }
            
            NSBlockOperation* op = [[NSBlockOperation alloc] init];
            [op addExecutionBlock:^{
                NSLog(@">>> Count for taskId %@", taskId);
                [NSThread sleepForTimeInterval:0.8f];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendOutCountNotifications:taskId];
                });
                [_queuedTasks removeObjectForKey:taskId];
                NSLog(@"<<< Count for taskId %@", taskId);
            }];
            [_queuedTasks setObject:op forKey:taskId];
            [_dataRetrievelAsyncOperationQueue addOperation:op];
        }
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

}
  
- (void) retrieveDocumentsInRange:(NSRange)range forTaskId:(NSString*)taskId
{
        @synchronized(_queuedTasks)
        {
            if ([_queuedTasks objectForKey:taskId])
            {
                NSLog(@"Discarding task with id %@, because one is already queued", taskId);
                return;
            }
            
            NSLog(@"Requesting data for range %d - %d", range.location, range.location + range.length);
            NSBlockOperation* op = [[NSBlockOperation alloc] init];
            [op addExecutionBlock:^{
                NSLog(@">>> Retrieve for taskId %@", taskId);
                [NSThread sleepForTimeInterval:1.5f];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendOutDocumentNotifications:range forTaskId:taskId];
                });
                [_queuedTasks removeObjectForKey:taskId];
                NSLog(@"<<< Retrieve for taskId %@", taskId);
            }];
            [_queuedTasks setObject:op forKey:taskId];
            [_dataRetrievelAsyncOperationQueue addOperation:op];
        }
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
    
}

@end
