//
//  CDTaskBuilder.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDTask.h"

/**
 * CDTaskBuilder responsible for creating tasks.
 *
 */

@interface CDTaskBuilder : NSObject

+(id) instance;

//create task whose responsability is to retrieve number of documents
-(CDTask *)createCountTask;

//create task for documents metadata retrieving which are in provided range
-(CDTask *)createDocumentsMetadataTaskInRange:(NSRange)range;

@end
