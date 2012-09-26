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
#import "CDDocument.h"

@interface CDDataManager : NSObject

+ (id) instance;
- (CDTask*)retrieveDocumentsInRange:(NSRange)range;
- (CDTask*)retrieveElementCount;
- (CDTask*)retrievePreviewForDocument:(CDDocument*)doc page:(NSUInteger)page resolution:(NSString*)res version:(NSUInteger)version;
- (void)cancelTask:(CDTask*)task;
- (void)cancelTasks:(id<NSFastEnumeration>)collectionOfTasks;
@end
