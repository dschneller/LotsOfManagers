//
//  CDTask.m
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTask.h"

@implementation CDTask


-(void)execute {
// abstract method 
}

/** cancel task and all of its commands */
-(void)cancel {
	
}


-(BOOL)isEqual:(id)other {
	if(self == other){
		return YES;
	}
	if(!other || ![other isKindOfClass:[self class]])
    {
        return NO;
    }
	CDTask *o = (CDTask *)other;
	return [self.taskId isEqualToString:o.taskId];
}

@end
