//
//  CDDocumentSearchResult.h
//  LotsOfManagers
//
//  Created by Predrag Karic on 9/24/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDDocumentSearchResult : NSObject

@property(nonatomic, strong) NSNumber *hits;
@property(nonatomic, strong) NSMutableArray *documents;

@end
