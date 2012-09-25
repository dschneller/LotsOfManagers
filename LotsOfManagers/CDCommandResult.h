//
//  CDCommandResult.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/24/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDCommand;

@protocol CDCommandResult <NSObject>

- (void) processCommandResult:(CDCommand *)command result:(id)result message:(NSString *)message;

@end

