//
//  CDDocumentStackModel.m
//  AQGridViewTests
//
//  Created by Daniel Schneller on 10.07.12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDocumentStackModel.h"

@implementation CDDocumentStackModel

@synthesize entity      = _entity;
@synthesize posterImage = _posterImage;
@synthesize entities    = _entities;
@synthesize frameImage  = _frameImage;

-(id) init
{
    if(self = [super init])
    {
        _entities = [NSMutableArray array];
    }
    
    return self;
}

- (NSUInteger) numberOfItems
{
    return [self.entities count];
}

@end
