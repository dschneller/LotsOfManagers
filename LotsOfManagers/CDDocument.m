//
//  CDDocument.m
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocument.h"

@implementation CDDocument

-(NSString *)description {
	return  [NSString stringWithFormat:@"[cddocument id: %@; filename: %@; author: %@; version:%d]", _documentId, _filename, _author, _version];
}

@end
