//
//  CDDocumentStackModel.h
//  AQGridViewTests
//
//  Created by Daniel Schneller on 10.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractEntity.h"

@interface CDDocumentStackModel : NSObject

@property (nonatomic, strong) AbstractEntity *entity;
@property (nonatomic, strong) UIImage*   posterImage;
@property (nonatomic, strong) NSMutableArray* entities;
@property (nonatomic, strong) UIImage* frameImage;

-(NSUInteger)numberOfItems;

@end
