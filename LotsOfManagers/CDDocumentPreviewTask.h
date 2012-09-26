//
//  CDDocumentPreviewTask.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/25/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDTask.h"
#import "CDDocumentPreviewCommand.h"

@interface CDDocumentPreviewTask : CDTask

@property(nonatomic, strong) CDDocumentPreviewCommand *documentPreviewCommand;

@end
