//
//  CDDataManager.h
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDTask.h"
#import "CDTaskManager.h"

@interface CDDataManager : NSObject

+ (id) instance;
- (CDTask*)retrieveDocumentsInRange:(NSRange)range;
- (CDTask*)retrieveElementCount;
- (void)cancelTask:(CDTask*)task;

@end
