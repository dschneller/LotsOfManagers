//
//  CDDocumentPreviewCommand.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/25/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDCommand.h"

@interface CDDocumentPreviewCommand : CDCommand

@property (nonatomic, copy) NSString* documentId;
@property (nonatomic, copy) NSString* resolution;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger version;


@end
