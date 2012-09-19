//
//  NSObject+PerformBlockAfterDelay.h
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformBlockAfterDelay)

- (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay;

@end
