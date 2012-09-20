//
//  CDTask.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDTask;

@protocol CDTaskDelegate <NSObject>

-(void)cdTaskDidFinished;

@end

@interface CDTask : NSObject

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, assign, getter = isFinished) BOOL finished;
@property (nonatomic, weak) id <CDTaskDelegate> delegate; //used to inform task manager that it is finished its job, and that task manager can proceed other task

-(void)execute;
-(void)cancel;

@end
