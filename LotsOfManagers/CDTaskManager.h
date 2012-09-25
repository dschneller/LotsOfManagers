//
//  CDTaskManager.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDTask.h"

@interface CDTaskManager : NSObject <CDTaskDelegate>

-(void)addTask:(CDTask *)task;
-(void)cancelTask:(CDTask*)task;
+(id) instance;


@end
