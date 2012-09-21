//
//  CDDataManager.h
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDDataManager : NSObject

+ (id) instance;
- (void) retrieveDocumentsInRange:(NSRange)range
                        forTaskId:(NSString*)taskId;
- (void) retrieveElementCountForTaskId:(NSString*)taskId;
- (void) cancelTaskIdWithPrefix:(NSString*)taskIdPrefix;

@end
