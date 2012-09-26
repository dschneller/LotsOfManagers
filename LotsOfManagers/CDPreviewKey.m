//
//  CDPreviewKey.m
//  CenterDevice
//
//  Created by Daniel Schneller on 02.08.12.
//
//

#import "CDPreviewKey.h"

@implementation CDPreviewKey

@synthesize resolution = _resolution;
@synthesize page = _page;

- (id)initWithPage:(NSUInteger)page resolution:(NSString*)res
{
    self = [super init];
    if (self) {
        _resolution = [res copy];
        _page = [NSNumber numberWithUnsignedInteger:page];
    }
    return self;
}


-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
    {
        return NO;
    }
    CDPreviewKey* other = (CDPreviewKey*)object;
    return [other.resolution isEqualToString:self.resolution]
        && [other.page isEqualToNumber:self.page];
}

-(NSUInteger)hash
{
    return self.page.hash * 11 + self.resolution.hash * 3;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"[Pg %@, Res %@]", self.page, self.resolution];
}

-(id)copyWithZone:(NSZone *)zone {
    CDPreviewKey* copy = [[CDPreviewKey alloc] initWithPage:[self.page unsignedIntegerValue]
                                                 resolution:self.resolution];
    return copy;
}


@end
