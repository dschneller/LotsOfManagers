//
//  CDTaskManager.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDTask.h"
#import "CDCommand.h"

@interface CDTaskManager : NSObject <CDTaskDelegate, CDCommandResult>

-(void)addTask:(CDTask *)task;
-(void)cancelTask:(CDTask*)task;
-(void)cancelTasks:(id<NSFastEnumeration>)collectionOfTasks;

+(id) instance;


@end
