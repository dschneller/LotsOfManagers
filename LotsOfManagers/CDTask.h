//
//  CDTask.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCommandResult.h"

@protocol CDTaskDelegate;


@interface CDTask : NSObject <NSCopying, CDCommandResult>

@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *taskFamily;
@property (nonatomic, assign, getter = isFinished) BOOL finished;
@property (nonatomic, assign, getter = isCancelRequested) BOOL cancelRequested;
@property (nonatomic, weak) id <CDTaskDelegate> delegate; //used to inform task manager that it is finished its job, and that task manager can proceed another task
@property (nonatomic, strong) NSCondition* doneCondition;
@property (nonatomic, assign) BOOL done;

-(void)execute;
-(void)cancel;

-(void)doYourThing;
-(void)cancelYourThing;
-(BOOL)processYourThing:(CDCommand*)command result:(id)result message:(NSString*)message;
-(BOOL)processYourFailure:(CDCommand *)command result:(id)result message:(NSString *)message error:(NSError*)error;

@end

@protocol CDTaskDelegate <NSObject>

-(void)cdTaskDidFinish:(CDTask*)task;

@end
