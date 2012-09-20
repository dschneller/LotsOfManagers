//
//  CDDocumentsCountTask.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTask.h"
#import "CDDocumentsCountCommand.h"

@class CDCommand;

@interface CDDocumentsCountTask : CDTask <CommandResult>

@property (nonatomic, assign) NSUInteger count;

@property (nonatomic, strong) CDDocumentsCountCommand *documentsCountCommand;

@end
