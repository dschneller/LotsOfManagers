//
//  CDTask.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDTask : NSObject

@property (nonatomic, strong) NSString *taskId;

-(void)execute;
-(void)cancel;

@end
