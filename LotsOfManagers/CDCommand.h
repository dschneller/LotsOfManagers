//
//  CDCommand.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+PerformBlockAfterDelay.h"

@class CDCommand;

@protocol CDCommandResult <NSObject>

- (void) processCommandResult:(CDCommand *)command result:(id)result message:(NSString *)message;

@end

@interface CDCommand : NSObject

@property(nonatomic, weak) id<CDCommandResult> delegate;

@property(nonatomic, assign, getter = isFinished) BOOL finished;

-(void)execute;
-(void)didFinishWithResult:(id)result;
-(void)cancel;

@end


