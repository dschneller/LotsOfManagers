//
//  CDCommand.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDCommand : NSObject

-(void)execute;
-(void)didFinishWithResult:(id)result;

@end
