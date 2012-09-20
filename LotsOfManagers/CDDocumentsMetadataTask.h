//
//  CDDocumentsMetadataTask.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTask.h"
#import "CDDocumentMetadataCommand.h"

@interface CDDocumentsMetadataTask : CDTask

@property(nonatomic, assign) NSUInteger row;
@property(nonatomic, assign) NSUInteger offset;

@property(nonatomic, strong) CDDocumentMetadataCommand *command;

@end
