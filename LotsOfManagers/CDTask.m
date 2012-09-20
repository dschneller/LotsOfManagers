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


-(BOOL)isEqual:(id)object {
	if(self == object){
		return YES;
	}
	if(!object || ![object isKindOfClass:[self class]])
    {
        return NO;
    }
	CDTask *other = (CDTask *)object;
	return [self.taskId isEqualToString:other.taskId];
}

@end
