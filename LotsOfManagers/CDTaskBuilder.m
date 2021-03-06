//
//  CDTaskBuilder.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTaskBuilder.h"
#import "CDDocumentsCountTask.h"
#import "CDDocumentsCountCommand.h"
#import "CDDocumentsMetadataTask.h"
#import "CDDocumentMetadataCommand.h"
#import "CDDocumentPreviewTask.h"
#import "CDDocumentPreviewCommand.h"
#import "CDTaskManager.h"

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

// Create count task.
-(CDTask *)createCountTask {
	CDDocumentsCountTask *task = [[CDDocumentsCountTask alloc] init];
    task.taskFamily = @"simple";
	task.taskId = [NSString stringWithFormat:@"count.all"];
	CDDocumentsCountCommand *command = [[CDDocumentsCountCommand alloc] init];
	command.originatingTask = task;
	command.delegate = [CDTaskManager instance];
	task.documentsCountCommand = command;
	return task;
}

// create documents metadata task.
-(CDTask *)createDocumentsMetadataTaskInRange:(NSRange)range {
	CDDocumentsMetadataTask *task = [[CDDocumentsMetadataTask alloc] init];
    task.taskFamily = @"simple";
	task.taskId = [NSString stringWithFormat:@"%@_%d", [task description], range.location];
	CDDocumentMetadataCommand *command = [[CDDocumentMetadataCommand alloc] init];
	command.originatingTask = task;
	command.delegate = [CDTaskManager instance];
	command.range = range;
	task.documentsMetadataCommand = command;
	return task;
}

-(CDTask*) createPreviewTaskForDocument:(CDDocument *)doc page:(NSUInteger)page resolution:(NSString *)res version:(NSUInteger)version
{
	CDDocumentPreviewTask *task = [[CDDocumentPreviewTask alloc] init];
	task.taskFamily = @"preview";
	task.taskId = [NSString stringWithFormat:@"preview-doc%@-p%d-res%@-v%d", doc.documentId, page, res, version];
	CDDocumentPreviewCommand *command = [[CDDocumentPreviewCommand alloc] init];
	command.originatingTask = task;
	command.delegate = [CDTaskManager instance];
	command.documentId = doc.documentId;
	command.resolution = res;
	command.page = page;
	command.version = version;
	task.documentPreviewCommand = command;
	return task;
}

@end
