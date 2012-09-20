//
//  CDDataRepository.h
//  LotsOfManagers
//
//  Created by Marko Cicak on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDDataRepository : NSObject

// all documents
@property NSArray *documents;

+(CDDataRepository*)instance;

@end
