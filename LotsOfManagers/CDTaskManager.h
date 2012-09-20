//
//  CDTaskManager.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDTask.h"

@interface CDTaskManager : NSObject

@property(nonatomic, strong, readonly) NSMutableArray *queuedTasks;

-(void)addTask:(CDTask *)task;
+(id) instance;

@end
