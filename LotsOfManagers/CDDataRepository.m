//
//  CDDataRepository.m
//  LotsOfManagers
//
//  Created by Marko Cicak on 9/20/12.
//  Copyright (c) 2012 codecentric AG. All rights reserved.
//

#import "CDDataRepository.h"
#import "CDDocument.h"

#define DOCUMENTS_COUNT 1000

@implementation CDDataRepository

static CDDataRepository* instance = nil;

-(id)init
{
    self = [super init];
    if(self) {
        NSMutableArray* preparedAllDocs = [NSMutableArray arrayWithCapacity:DOCUMENTS_COUNT];
        for (int i=0; i<DOCUMENTS_COUNT; i++)
        {
            CDDocument* doc = [[CDDocument alloc] init];
            doc.filename = [NSString stringWithFormat:@"Filename %d", i];
            doc.author = [NSString stringWithFormat:@"Author %d", i];
            doc.documentId = [NSString stringWithFormat:@"DocId %d", i];
            
            [preparedAllDocs addObject:doc];
        }
        
        _documents = [NSArray arrayWithArray:preparedAllDocs];

    }
    return self;
}

+(CDDataRepository*)instance
{
    if(!instance) {
        instance = [[CDDataRepository alloc] init];
    }
    
    return instance;
}

@end
