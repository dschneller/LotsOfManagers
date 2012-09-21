//
//  CDDocumentsCountCommand.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDCommand.h"

@interface CDDocumentsCountCommand : CDCommand

@property(nonatomic, strong) NSNumber *count;

@end
