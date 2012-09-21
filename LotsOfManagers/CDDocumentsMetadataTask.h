//
//  CDDocumentsMetadataTask.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTask.h"
#import "CDDocumentMetadataCommand.h"

@class CDCommand;

@interface CDDocumentsMetadataTask : CDTask <CDCommandResult>

@property(nonatomic, assign) NSUInteger row;
@property(nonatomic, assign) NSUInteger offset;

@property(nonatomic, strong) CDDocumentMetadataCommand *documentsMetadataCommand;

@end
