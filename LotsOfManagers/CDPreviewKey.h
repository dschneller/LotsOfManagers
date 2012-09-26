//
//  CDPreviewKey.h
//  CenterDevice
//
//  Created by Daniel Schneller on 02.08.12.
//
//

#import <Foundation/Foundation.h>

@interface CDPreviewKey : NSObject <NSCopying>

@property (nonatomic, readonly) NSString* resolution;
@property (nonatomic, readonly) NSNumber* page;


- (id)initWithPage:(NSUInteger)page resolution:(NSString*)res;

@end
