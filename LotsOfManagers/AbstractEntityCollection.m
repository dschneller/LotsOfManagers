//
//  AbstractEnityCollection.m
//  CenterDevice
//
//  Created by Predrag Karic on 8/20/12.
//
//

#import "AbstractEntityCollection.h"

@implementation AbstractEntityCollection

@synthesize assigned = _assigned;

- (id)init
{
    self = [super init];
    if (self) {
        _assigned = NO;
    }
    return self;
}

@end
