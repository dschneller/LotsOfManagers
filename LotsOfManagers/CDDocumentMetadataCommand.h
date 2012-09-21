//
//  CDDocumentMetadataCommand.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCommand.h"

@interface CDDocumentMetadataCommand : CDCommand

@property (nonatomic, readwrite) NSRange range;

@end
