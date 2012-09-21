//
//  AbstractEntity.m
//  CenterDevice
//
//  Created by Marko Cicak on 8/10/12.
//
//

#import "AbstractEntity.h"

@implementation AbstractEntity

@synthesize name = _name;

-(id)init
{
    if(self = [super init]) {
        _name = [NSString string];
    }
    
    return self;
}

-(NSString*)description
{
    return self.name;
}

@end
