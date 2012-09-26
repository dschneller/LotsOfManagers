//
//  CDDocument.h
//  LotsOfManagers
//
//  Created by Daniel Schneller on 18.09.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDDocument : NSObject

@property (nonatomic, copy) NSString* filename;
@property (nonatomic, copy) NSString* author;
@property (nonatomic, copy) NSString* documentId;
@property (nonatomic, assign) NSInteger version;


@end
